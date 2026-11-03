# The Local AI Speed & Polish Handbook

**Make your sluggish local AI feel snappy.** This is the speed companion to the
*Local AI Handbook* (which covers getting Ollama set up). Once it works, this
manual makes it *fast*: turbo settings, cache reuse, smaller-model shortcuts,
CPU vs GPU pinning, quantization in plain English, and a monthly refresh ritual
that keeps the polish from wearing off.

By Dylan Asdale — AI explained like a friend would: plain English, step by
step, never condescending. Published by **Asdale Dynamics, LLC**.

## Who this is for

- You already have Ollama running (or you're 20 minutes from it via the
  *Local AI Handbook*).
- Your local AI answers... eventually. You'd like it to answer *now*.
- You want honest numbers, not vibes. That's why there's a stopwatch test.

## What's inside

| File | What it covers |
|------|----------------|
| `docs/00-start-here.md` | The 10-minute quick win |
| `docs/01-why-is-it-slow.md` | Diagnose before you tune |
| `docs/02-turbo-settings.md` | The env vars and options that matter |
| `docs/03-cache-reuse.md` | Keep the model loaded; reuse context |
| `docs/04-smaller-models.md` | The 1B/3B/7B shortcut ladder |
| `docs/05-cpu-vs-gpu-pinning.md` | Laptops, Pis, and where the work happens |
| `docs/06-quantization-plain-english.md` | Q4 vs Q5 vs Q8, honest tradeoffs |
| `docs/07-hotel-ai-speed-test.md` | The stopwatches-and-scorecard test |
| `docs/08-month-refresh-ritual.md` | The monthly tune-up checklist |
| `scripts/` | Tested helper scripts |
| `site/` | A static HTML version you can open in any browser |

## Quick start

1. Skim `docs/00-start-here.md` and do the 10-minute quick win.
2. Run the speed test: `bash scripts/hotel-speed-test.sh` (see
   `docs/07-hotel-ai-speed-test.md` for the scorecard).
3. Open `site/index.html` in your browser for the friendly web version.

## The scripts

No installs beyond Ollama itself. Everything is plain `bash` and standard Unix
tools. If Ollama isn't running or isn't installed, the scripts tell you so
nicely and give you the exact commands to fix it — they never half-fail.

- `scripts/bench-ollama.sh` — times first-token and full-answer speed for a
  model, before/after tuning.
- `scripts/hotel-speed-test.sh` — runs the full "hotel-AI" stopwatch battery
  (first check-in, wake-up, follow-up, big-luggage test) and prints a
  scorecard.
- `scripts/perf-set-check.sh` — shows your current speed-relevant settings in
  one glance.

## Hardware tested against

Scripts are written and syntax-tested on Linux (they also run on macOS with
standard tools). The CPU/GPU chapter covers typical laptops, an older PC, and a
Raspberry Pi 5. You don't need any specific hardware to benefit.

## License & credit

MIT licensed — see `LICENSE`. Copyright (c) 2026 Asdale Dynamics, LLC.
This handbook is published by **Asdale Dynamics, LLC**, Dylan Asdale's
company for beginner-friendly AI books, guides, and practical tools.

*A companion to the Local AI Handbook, by Dylan Asdale (dylanasdale.github.io).*
