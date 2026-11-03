# STATUS.md — The Local AI Speed & Polish Handbook

_Last updated: 2026-11-03_

## What was built

A complete companion handbook to the *Local AI Handbook* (which covers setup,
not speed). This one makes a working Ollama install **fast**, in beginner-friendly
plain English:

- **9 markdown chapters in `docs/`** (00-start-here → 08-month-refresh-ritual),
  covering:
  - The 10-minute quick win
  - Diagnosing slowness (cold start vs throughput vs memory pressure)
  - Turbo settings (`OLLAMA_KEEP_ALIVE`, `num_ctx`, `OLLAMA_FLASH_ATTENTION`,
    `OLLAMA_KV_CACHE_TYPE`, plus persistence via systemd override)
  - Cache reuse (model pinning, prompt-prefix reuse, warm-up habit)
  - Smaller-model shortcuts (the 1B/3B/7B ladder and the "pairing habit")
  - CPU vs GPU pinning (`ollama ps`, splits, `taskset`, laptops / Raspberry Pi
    5 / Apple Silicon)
  - Quantization in plain English (q4_K_M vs q5 vs q8, honest tradeoff tables)
  - **The hotel-AI speed test** — four stopwatch events (cold check-in, warm
    wake-up, follow-up, big luggage) with an honest scorecard template
  - The month-refresh ritual (15-minute checklist)
- **3 tested bash scripts in `scripts/`** (bash + curl + standard Unix tools;
  no installs beyond Ollama):
  - `bench-ollama.sh` — per-model timing (approx TTFT, tokens/s, totals),
    `--warmup` to pin a model, `--save FILE` to log results
  - `hotel-speed-test.sh` — the four-event stopwatch battery + scorecard,
    `--out FILE` to append cards
  - `perf-set-check.sh` — settings/loaded-models/memory/disk at a glance
- **Static website in `site/`** — a polished dark-theme single-page version of
  the whole book (`index.html` + `styles.css`), openable directly in any
  browser or served with any static server.
- **README.md** (project guide + credit to Asdale Dynamics, LLC) and
  **LICENSE** (MIT, copyright line exactly `Copyright (c) 2026 Asdale Dynamics, LLC`).

## How to run it

- **Read the book:** start with `docs/00-start-here.md`, or open
  `site/index.html` in a browser.
- **Time a model:** `bash scripts/bench-ollama.sh llama3.2:3b`
- **Full speed test:** `bash scripts/hotel-speed-test.sh llama3.2:3b --out scorecard.txt`
- **Settings glance:** `bash scripts/perf-set-check.sh`
- Scripts talk to Ollama at `http://localhost:11434` by default; override with
  `OLLAMA_HOST=http://host:port`. If Ollama isn't running, the scripts exit
  cleanly with the exact fix instead of failing halfway.

## Verification results

- `bash -n` syntax check passes on all three scripts.
- **Full end-to-end run verified** against a local mock Ollama API server
  (test-only, not shipped): `bench-ollama.sh`, `hotel-speed-test.sh` (all four
  events + scorecard + `--out` append), and `perf-set-check.sh` all pass.
- **Graceful fallback verified:** with no server reachable, each script prints
  a friendly diagnostic (check install → start server → host flag) and exits
  non-zero; model-not-found errors are surfaced clearly.
- HTML validated with a tag-balance checker (no mismatched tags); site served
  locally via `python3 -m http.server` and all pages/assets returned 200;
  all internal `docs/…` and `scripts/…` references in README/docs/site point to
  files that exist.
- Secret/keys scan of all files: clean (no API keys, secrets, or personal data).
- JSON parsing tolerates both compact (real Ollama) and spaced JSON.
- bash 5.2, GNU coreutils; scripts also use only curl/awk/grep/sed — portable
  across Linux/macOS (macOS caveat: `taskset` and `systemctl` are Linux-only and
  guarded/documented as such).

## Known gaps

- **No live Ollama run in this environment** — Ollama itself was not installed
  here, so timing numbers in the book are typical published-appraisal figures,
  not numbers measured on this machine. The scripts are fully tested against a
  protocol-faithful mock; run the hotel test on your own hardware for your
  numbers (that is, by design, the point of the book).
- The "follow-up" event in the script emulates conversation reuse via a shared
  prompt prefix (the API is stateless); interactive `ollama run` chat sessions
  get the same effect automatically — both are explained in chapter 7.
- systemd persistence instructions assume systemd; macOS persistence uses
  launchctl/terminal-launch notes rather than a tested launchd plist.
- `scripts/perf-set-check.sh` memory glance via `free -h` on Linux, `vm_stat`
  note on macOS; no Windows/cygwin variant.
- No test suite beyond the scripts' built-in graceful checks; could later add a
  `make check` or CI workflow (kept out per "no installs/publishing" scope).
