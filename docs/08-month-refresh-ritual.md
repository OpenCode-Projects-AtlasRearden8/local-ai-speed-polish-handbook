# Chapter 8 — The Month-Refresh Ritual

Tuning isn't a one-time ceremony; it's a tiny maintenance habit. This is the
monthly ritual — fifteen minutes, tops, with a checklist you can do half-asleep.
Set a calendar reminder titled **"AI pit stop"** and follow along.

## The checklist

### 1. Update Ollama (2 min)

Speed fixes and model improvements ship constantly.

```bash
# Linux (most distros)
curl -fsSL https://ollama.com/install.sh | sh
# or: sudo apt upgrade ollama / brew upgrade on macOS
ollama --version
```

### 2. Look at your model shelf (3 min)

```bash
ollama list
```

Ask three questions:

- Are there models I downloaded to *try* and never touched again? → `ollama rm
  <model>`. Disk space is load time.
- Did a **newer/smaller tag** of a favorite land? (Check a model's page; e.g.
  a new `3b` might beat your old `7b`.) → pull it, run the taste test (Ch 4).
- Is my **daily driver** still the right rung? Has your use drifted?

### 3. Re-run the Hotel-AI Speed Test (5 min)

```bash
bash scripts/hotel-speed-test.sh <your-daily-driver>
```

Compare against last month's scorecard (Chapter 7's template). You're not
hunting for records; you're watching for **regressions** — a warm-up event that
used to be 2 seconds and is now 11 seconds means something changed (settings,
disk full, a background process moved in).

### 4. Glance at the health panel (3 min)

```bash
bash scripts/perf-set-check.sh     # your settings at a glance
ollama ps                          # who's loaded, and where (GPU/CPU/split)
df -h /                            # disk room? Full disks slow loads.
free -h                            # memory pressure? (Linux)
```

If `ollama ps` shows a split you didn't ask for or an unexpected CPU pin —
Chapters 5 and 6 are the repair chapters.

### 5. Prune settings drift (2 min)

Did anything get edited over the month (new `num_ctx`, someone toggled flash
attention "to try it")? Re-check the Big Four from Chapter 2 are the values
that measured *well*, not the values that felt interesting.

### 6. Log one line (0 min)

Keep a tiny log — the scorecards ARE the log:

```
2026-11-01  updated ollama; 3b re-pulled; card: check-in 9.1→8.4s, warm 1.8s. Kept.
```

One line. Future-you reads it and knows the whole story.

## The yearly deep-clean (optional, once a series of months feels good)

- Re-take Chapter 4's ladder from scratch: pull the newest 1B and 3B, and
  re-run the taste test. "Best small model" churns a few times a year, and new
  releases often leapfrog your incumbent.
- Re-consider quants if you changed hardware (new laptop/RAM/GPU).

## When a month is NOT enough

Run a mini ritual (steps 3–4 only) whenever:

- You switch machines, or install a big OS update.
- You pull a favorite model with a *different quant* than before.
- Something "feels off" (Chapter 1's diagnosis is the pre-flight check).

That's the whole discipline: **short ritual, honest stopwatches, small keeps.**
Enjoy the speed.
