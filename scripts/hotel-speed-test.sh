#!/usr/bin/env bash
# hotel-speed-test.sh — the "Hotel-AI" stopwatch battery from the handbook.
# Four front-desk events: cold check-in, warm wake-up, follow-up, big luggage.
# Prints an honest scorecard. Optional --out FILE appends a scorecard to FILE.
#
# Usage:
#   bash scripts/hotel-speed-test.sh MODEL [--host URL] [--out FILE] [--ctx N]
#
# Notes:
# - The by-hand version uses an interactive chat (docs/07). This script talks to
#   the API instead; its "follow-up" event emulates conversation reuse by
#   sharing a long prompt prefix between events 2 and 3 (what a cached chat
#   reuses automatically).
# - Event 1 first asks Ollama to unload the model (keep_alive 0), so the
#   cold-check-in number includes a true reload.
#
# MIT license — part of the Local AI Speed & Polish Handbook (Asdale Dynamics, LLC).
set -u

HOST="${OLLAMA_HOST:-http://localhost:11434}"
HOST="${HOST%/}"
HOST="${HOST//0.0.0.0/localhost}"
MODEL=""
OUT=""
CTX=4096

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host) HOST="$2"; shift 2 ;;
    --out)  OUT="$2"; shift 2 ;;
    --ctx)  CTX="$2"; shift 2 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) if [[ -z "$MODEL" ]]; then MODEL="$1"; else echo "Unknown extra argument: $1" >&2; exit 2; fi; shift ;;
  esac
done

if [[ -z "$MODEL" ]]; then
  echo "Usage: bash scripts/hotel-speed-test.sh MODEL [--out FILE] [--host URL] [--ctx N]"
  echo "Example: bash scripts/hotel-speed-test.sh llama3.2:3b --out scorecard.txt"
  exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "I need 'curl' to talk to Ollama, and I can't find it."
  echo "Install curl (e.g. 'sudo apt install curl') and try again."
  exit 2
fi

if ! curl -sf --max-time 3 "$HOST/api/version" >/dev/null 2>&1; then
  echo "Ollama doesn't seem to be reached at $HOST."
  echo "Start it with 'ollama serve' (or: systemctl start ollama), check the model"
  echo "exists with 'ollama list', then run this again."
  exit 1
fi

SHARED="You are the front desk of the Grand Stopwatch Hotel. Answer briefly, helpfully, and never invent hotel rules that are not in your instructions."

ask() {
  # ask LABEL PROMPT CTX KEEPALIVE -> prints one card line "label|ttft_s|total_s"
  # (human-readable detail goes to stderr)
  local label="$1" prompt="$2" rctx="$3" keep="$4" prompt_json resp reply
  prompt_json=$(printf '%s' "$prompt" | sed 's/\\/\\\\/g; s/"/\\"/g')
  resp=$(curl -s --max-time 900 "$HOST/api/generate" -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"$prompt_json\",
    \"options\": {\"num_ctx\": $rctx},
    \"keep_alive\": \"$keep\",
    \"stream\": false
  }")
  if echo "$resp" | grep -q '"error"'; then
    echo "$label: Ollama said $(echo "$resp" | grep -oE '"error":[[:space:]]*"[^"]*"' | head -1)" >&2
    return 1
  fi
  reply=$(echo "$resp" | grep -oE '"response":[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)
  local total_ns load_ns peval_ns peval_n eval_ns eval_n ttft_ns
  total_ns=$(echo "$resp" | grep -oE '"total_duration":[[:space:]]*[0-9.]+' | head -1 | grep -oE '[0-9.]+')
  load_ns=$(echo "$resp" | grep -oE '"load_duration":[[:space:]]*[0-9.]+' | head -1 | grep -oE '[0-9.]+')
  peval_ns=$(echo "$resp" | grep -oE '"prompt_eval_duration":[[:space:]]*[0-9.]+' | head -1 | grep -oE '[0-9.]+')
  peval_n=$(echo "$resp" | grep -oE '"prompt_eval_count":[[:space:]]*[0-9.]+' | head -1 | grep -oE '[0-9.]+')
  eval_ns=$(echo "$resp" | grep -oE '"eval_duration":[[:space:]]*[0-9.]+' | head -1 | grep -oE '[0-9.]+')
  eval_n=$(echo "$resp" | grep -oE '"eval_count":[[:space:]]*[0-9.]+' | head -1 | grep -oE '[0-9.]+')
  if [[ -z "$eval_ns" || -z "$eval_n" ]]; then
    echo "$label: could not read Ollama's timing fields; raw reply starts:"
    echo "$resp" | head -c 200
    echo ""
    return 1
  fi
  ttft_ns=$(( ${load_ns:-0} + ${peval_ns:-0} ))
  pretty=$(awk -v t="$ttft_ns" -v tot="$total_ns" -v en="$eval_n" -v ens="$eval_ns" 'BEGIN {
    printf "TTFT %.2fs | total %.2fs | gen %d toks in %.2fs = %.1f toks/s", t/1e9, tot/1e9, en, ens/1e9, en/(ens/1e9)
  }')
  echo "$label: $pretty" >&2
  reply_head="${reply:0:60}"
  [[ ${#reply} -gt 60 ]] && reply_head="$reply_head..."
  echo "  reply: $reply_head" >&2
  echo "$label|$ttft_ns|$total_ns"
}

unload() {
  # Politely ask Ollama to forget the model right after a one-token answer.
  curl -s --max-time 60 "$HOST/api/generate" -d "{
    \"model\": \"$MODEL\", \"prompt\": \"bye\", \"keep_alive\": 0,
    \"options\": {\"num_predict\": 1}, \"stream\": false
  }" >/dev/null
}

echo "=============================================="
echo "  HOTEL-AI SPEED TEST — $MODEL"
echo "  host: $HOST   num_ctx: $CTX"
echo "=============================================="
echo

echo "Event 1 — Cold check-in (model unloaded first)..."
unload; sleep 1
r1=$(ask "1. Cold check-in            " "$SHARED In one paragraph, explain what a hotel front desk does." "$CTX" "30m") || exit 1
echo "$r1" >&2; echo

echo "Event 2 — Wake-up call (same model, now warm)..."
r2=$(ask "2. Warm wake-up             " "$SHARED In one paragraph, explain what a hotel concierge does." "$CTX" "30m") || exit 1
echo "$r2" >&2; echo

echo "Event 3 — Follow-up (shared prompt prefix; cache at work)..."
r3=$(ask "3. Follow-up (shared prefix)" "$SHARED A traveler walks up. In paragraph form, greet them warmly and name the two things every front desk does first." "$CTX" "30m") || exit 1
echo "$r3" >&2; echo

echo "Event 4 — Big luggage (a very long prompt)..."
bigtext=$(for i in $(seq 1 220); do printf 'Hotel policy update #%d: Quiet hours remain 10pm to 7am. Front desk closes early on holidays. Pets permitted in pet-designated rooms only. Lost keys cost a duplicate fee. Late checkout may be granted to loyalty members. ' "$i"; done)
r4=$(ask "4. Big luggage (long prompt)" "$bigtext Based ONLY on the text above, in one paragraph, list three rules from it." 8192 "30m") || exit 1
echo "$r4" >&2; echo

ALLCARDS=$(printf '%s\n%s\n%s\n%s\n' "$r1" "$r2" "$r3" "$r4")

echo "=============================================="
echo "  SCORECARD — $MODEL  ($(date -u '+%Y-%m-%d %H:%M UTC'))"
echo "=============================================="
OUTFILE="${OUT:-}"
SCORECARD=$(awk -F'|' '
  /1\. Cold/  { e1=$2; e1T=$3 }
  /2\. Warm/  { e2=$2; e2T=$3 }
  /3\. Follow/{ e3=$2; e3T=$3 }
  /4\. Big/   { e4=$2; e4T=$3 }
  END {
    printf "Event                              TTFT (s)   Total (s)\n"
    printf "1. Cold check-in                  %8.2f %11.2f\n", e1/1e9, e1T/1e9
    printf "2. Warm wake-up                   %8.2f %11.2f\n", e2/1e9, e2T/1e9
    printf "3. Follow-up (shared prefix)      %8.2f %11.2f\n", e3/1e9, e3T/1e9
    printf "4. Big luggage (long prompt)      %8.2f %11.2f\n", e4/1e9, e4T/1e9
    printf "\nWarm-start bonus (cold TTFT - warm TTFT): %.2f s\n", (e1-e2)/1e9
  }' <<< "$ALLCARDS")
echo "$SCORECARD"
echo

if [[ -n "$OUTFILE" ]]; then
  echo "$SCORECARD" >> "$OUTFILE"
  echo "(Scorecard appended to $OUTFILE)"
fi
echo "Rules: one tuning change between runs, same machine state, honest numbers over flattery."
echo "Keep this card. Past cards are your only fair comparison point."
