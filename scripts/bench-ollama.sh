#!/usr/bin/env bash
# bench-ollama.sh — time how fast an Ollama model actually answers on YOUR machine.
# Part of the Local AI Speed & Polish Handbook (Asdale Dynamics, LLC, MIT license).
#
# Usage:
#   bash scripts/bench-ollama.sh MODEL [--prompt "text"] [--host URL] [--save FILE] [--warmup]
#
# Prints: time to first answer (approx TTFT), tokens/second, totals.
# If Ollama is not running, prints the exact fix instead of a cryptic error.
set -u

HOST="${OLLAMA_HOST:-http://localhost:11434}"
HOST="${HOST%/}"            # tolerate a trailing slash
HOST="${HOST//0.0.0.0/localhost}"   # ollama binds 0.0.0.0; curl wants a real name
PROMPT=""
MODEL=""
SAVE=""
WARMUP=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt) PROMPT="$2"; shift 2 ;;
    --host)   HOST="$2"; shift 2 ;;
    --save)   SAVE="$2"; shift 2 ;;
    --warmup) WARMUP=1; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) if [[ -z "$MODEL" ]]; then MODEL="$1"; else echo "Unknown extra argument: $1" >&2; exit 2; fi; shift ;;
  esac
done

if [[ -z "$MODEL" ]]; then
  echo "Usage: bash scripts/bench-ollama.sh MODEL [--prompt \"...\"] [--host URL] [--save FILE] [--warmup]"
  echo "Example: bash scripts/bench-ollama.sh llama3.2:3b"
  exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "I need 'curl' to talk to Ollama, and I can't find it."
  echo "Install curl (e.g. 'sudo apt install curl') and try again."
  exit 2
fi

if ! curl -sf --max-time 3 "$HOST/api/version" >/dev/null 2>&1; then
  echo "Ollama doesn't seem to be reached at $HOST."
  echo ""
  echo "Try:"
  echo "  1) Is it installed?  ->  ollama --version"
  echo "  2) Start it:         ->  ollama serve        (or: systemctl start ollama)"
  echo "  3) Different host?   ->  OLLAMA_HOST=http://host:port bash scripts/bench-ollama.sh $MODEL"
  exit 1
fi

echo "Warming up $MODEL (loaded, stay-alive 10m)..." >&2
warmup=$(curl -s --max-time 120 "$HOST/api/generate" -d "{
  \"model\": \"$MODEL\",
  \"prompt\": \"hi\",
  \"keep_alive\": \"10m\",
  \"stream\": false
}" 2>&1) || { echo "Warm-up request failed: $warmup" >&2; exit 1; }
if echo "$warmup" | grep -q '"error"'; then
  echo "Ollama said: $(echo "$warmup" | grep -oE '"error":[[:space:]]*"[^"]*"' | head -1)"
  echo "Is the model name right? Check the list with:  ollama list"
  exit 1
fi

if [[ $WARMUP -eq 1 ]]; then
  echo "Warm-up done. Model $MODEL stays loaded for 10 minutes."
  exit 0
fi

if [[ -z "$PROMPT" ]]; then
  PROMPT="Count from one to ten, then name the three most useful everyday knots. Keep it brief."
fi

echo "Benchmarking $MODEL ..."
echo "Prompt: \"$PROMPT\""
echo ""

# Escape double quotes so the prompt survives the trip into JSON.
prompt_json=$(printf '%s' "$PROMPT" | sed 's/\\/\\\\/g; s/"/\\"/g')

response=$(curl -s --max-time 600 "$HOST/api/generate" -d "{
  \"model\": \"$MODEL\",
  \"prompt\": \"$prompt_json\",
  \"options\": {\"num_ctx\": 2048},
  \"keep_alive\": \"10m\",
  \"stream\": false
}") || { echo "Benchmark request failed (timed out or connection dropped)." >&2; exit 1; }

if echo "$response" | grep -q '"error"'; then
  echo "Ollama said: $(echo "$response" | grep -oE '"error":[[:space:]]*"[^"]*"' | head -1)"
  exit 1
fi

# Parse durations (Ollama returns nanoseconds). Tolerates spaces after colons.
num() { echo "$response" | grep -oE "\"$1\":[[:space:]]*[0-9.]+" | head -1 | grep -oE '[0-9.]+'; }

TOTAL_NS=$(num total_duration)
LOAD_NS=$(num load_duration)
PEVAL_NS=$(num prompt_eval_duration)
PEVAL_N=$(num prompt_eval_count)
EVAL_NS=$(num eval_duration)
EVAL_N=$(num eval_count)

if [[ -z "$EVAL_NS" || -z "$EVAL_N" ]]; then
  echo "Could not parse Ollama's timing fields; response was:"
  echo "$response" | head -5
  exit 1
fi

# First-token estimate: load + prompt evaluation (everything before words appear).
ttft_ns=$(( ${LOAD_NS:-0} + ${PEVAL_NS:-0} ))
tok_per_s=$(awk -v n="$EVAL_N" -v ns="$EVAL_NS" 'BEGIN { if (ns == 0) print "n/a"; else printf "%.1f", n / (ns / 1e9) }')
fmt_ms() { awk -v ns="$1" 'BEGIN { printf "%.2f", ns / 1e6 }'; }
fmt_s()  { awk -v ns="$1" 'BEGIN { printf "%.2f", ns / 1e9 }'; }

report="MODEL: $MODEL"
report+="\n  First answer delay (approx TTFT): $(fmt_s "$ttft_ns") s  (load: $(fmt_s "${LOAD_NS:-0}") s, reading prompt: $(fmt_s "${PEVAL_NS:-0}") s)"
report+="\n  Generation speed:                $tok_per_s tokens/s  ($EVAL_N tokens in $(fmt_s "$EVAL_NS") s)"
report+="\n  Total wall time:                 $(fmt_s "$TOTAL_NS") s  (prompt tokens: ${PEVAL_N:-n/a})"

echo ""
echo -e "$report"

if [[ -n "$SAVE" ]]; then
  { echo -e "$report"; echo "  (bench-ollama.sh at $(date -u '+%Y-%m-%d %H:%M UTC'))"; } >> "$SAVE"
  echo ""
  echo "Appended to $SAVE"
fi

echo ""
echo "Run this again after each tuning change (one change at a time) — see docs/07-hotel-ai-speed-test.md."
