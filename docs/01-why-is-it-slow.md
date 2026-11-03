# Chapter 1 — Why Is It Slow? (Diagnose Before You Tune)

"Tune everything" is how people waste a weekend. Instead, find the three
symptoms you actually have. Every sluggish local AI has one of these—and each
one has a different fix.

## Symptom 1: "The FIRST message takes forever, then it's fine"

That's a **cold start**. The model got unloaded from RAM (Ollama's default is
to unload after 5 minutes of quiet), so your first request pays the
loading-into-(RAM/VRAM) tax. Sometimes that's 30+ seconds; every message after
is fast.

- **Fix:** raise `OLLAMA_KEEP_ALIVE` (Chapter 3). Have a "warm-up" ping after
  long breaks.

## Symptom 2: "EVERY message is slow, even simple questions"

That's a **throughput** problem: hardware or model too heavy for what you're
asking. This is the most common one on laptops and Raspberry Pis running 8B+
models.

- The chain that produces answers (slow → fast):
  big model → smaller model → smaller model with lighter quantization →
  smaller model, lighter quant, tighter context.
- **Fix ladder:** smaller model first (biggest win), then lighter quant, then
  tighter `num_ctx` (Chapter 2, 4, 6).

## Symptom 3: "It types fast, but PAUSES mid-answer"

That's **memory pressure or CPU/GPU thrash**: the model doesn't quite fit, or
the system is swapping, or the GPU is loading/unloading layers per request.
Also can happen with very long prompts (big KV cache).

- **Fix:** smaller quant, fewer loaded layers (`num_gpu`), smaller `num_ctx`,
  check the machine isn't swapping (`free -h` / swap usage), close the 47
  browser tabs (we don't judge).

## The 60-second diagnosis: watch it load

Run with a fresh model and watch the load line:

```bash
ollama run llama3.2:3b "Why is the sky blue? One sentence."
```

Ollama prints a progress bar like `pulling manifest / loading model...` when
it's **loading**, then answers. Time with a stopwatch:

- Load bar visible for most of the wait → **Symptom 1 (cold start)**.
- No load bar, answer just types slowly → **Symptom 2 (throughput)**.
- Load bar gone, mid-answer stutters → **Symptom 3 (memory pressure)**.

## The honest test habit

Diagnosis you can feel is rarely enough to judge small changes. Chapter 7's
stopwatch test is the referee. Rule for this whole handbook:

> **One change, one stopwatch, one scorecard line. Keep what measurably won.**

## What "slow" even means (the three numbers)

1. **Time to first token (TTFT)** — how long until words start appearing.
   Dominated by model loading and prompt processing. This is what "feels
   instant" is made of.
2. **Tokens per second (tok/s)** — how fast the words flow once they start.
   Dominated by model size, quantization, and CPU/GPU.
3. **Total time** — TTFT + generation. What you actually wait for.

Tuning chapters target these in order. Now go to **Chapter 2 — Turbo
Settings**.
