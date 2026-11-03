#!/usr/bin/env bash
# perf-set-check.sh — your speed-relevant settings at a glance.
# Shows: Ollama reachability, loaded models (and where they run),
# your OLLAMA_* environment settings, and memory/disk headroom.
#
# Usage: bash scripts/perf-set-check.sh [--host URL]
#
# MIT license — part of the Local AI Speed & Polish Handbook (Asdale Dynamics, LLC).
set -u

HOST="${OLLAMA_HOST:-http://localhost:11434}"
HOST="${HOST%/}"
HOST="${HOST//0.0.0.0/localhost}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host) HOST="$2"; shift 2 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

line() { printf '%s\n' "------------------------------------------------------------"; }

echo "PERF-SET CHECK — $(date -u '+%Y-%m-%d %H:%M UTC')"
line

# 1. Is Ollama there?
if command -v curl >/dev/null 2>&1 && curl -sf --max-time 3 "$HOST/api/version" >/dev/null 2>&1; then
  v=$(curl -sf --max-time 3 "$HOST/api/version" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
  echo "Ollama:     reachable at $HOST (version ${v:-unknown})"
else
  echo "Ollama:     NOT reachable at $HOST"
  echo "            Start it:  ollama serve    (or: systemctl start ollama)"
  v=""
fi

# 2. Which models are loaded, and where do they run?
if command -v ollama >/dev/null 2>&1; then
  if ps_out=$(ollama ps 2>/dev/null | tail -n +2) && [[ -n "$ps_out" ]]; then
    echo "Ollama CLI: $(ollama --version 2>/dev/null | head -1)"
    echo ""
    echo "Loaded right now (GPU/CPU placement — see docs/05):"
    echo "$ps_out"
  else
    echo "Ollama CLI: present, but no models are currently loaded."
    echo "            Warm one up: bash scripts/bench-ollama.sh <model> --warmup"
  fi
else
  echo "Ollama CLI: not on PATH (server may still be reachable above)."
fi
line

# 3. OLLAMA_* env settings that matter for speed
echo "Speed-relevant OLLAMA_* settings (current shell):"
found=0
for var in OLLAMA_KEEP_ALIVE OLLAMA_NUM_PARALLEL OLLAMA_MAX_LOADED_MODELS \
           OLLAMA_FLASH_ATTENTION OLLAMA_KV_CACHE_TYPE OLLAMA_HOST; do
  val="${!var:-}"
  if [[ -n "$val" ]]; then
    found=1
    echo "  $var=$val"
  fi
done
[[ $found -eq 0 ]] && echo "  (none set in this shell)"
echo "  Defaults if unset: KEEP_ALIVE=5m  NUM_PARALLEL=auto  FLASH_ATTENTION=0"
line

# 4. Systemd service environment (Linux) — do the *persistent* settings match?
if [[ -d /etc/systemd/system ]] && command -v systemctl >/dev/null 2>&1; then
  svc_env=$(systemctl show ollama --property=Environment 2>/dev/null | sed 's/^Environment=//' | tr -d '"')
  echo "systemd ollama service Environment:"
  echo "  ${svc_env:-(none — defaults apply; see docs/02-turbo-settings.md to persist settings)}"
fi

# 5. Memory + disk headroom
if command -v free >/dev/null 2>&1; then
  free -h | awk '/Mem:/ {printf "Memory:     %s total / %s used / %s available\n", $2, $3, $7}'
elif command -v vm_stat >/dev/null 2>&1; then
  echo "Memory:     (macOS detected — check Activity Monitor for memory pressure.)"
fi
if command -v df >/dev/null 2>&1; then
  df -h / 2>/dev/null | awk 'NR==2 {printf "Disk (/):   %s used / %s available (%s)\n", $3, $4, $5}'
fi
line

echo "Reading guide: cold starts -> docs/03 | slow answers -> docs/02 + docs/04 |"
echo "memory pressure -> docs/06 | GPU/CPU placement -> docs/05"
