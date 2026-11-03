# Chapter 5 — CPU vs GPU Pinning (Laptops, Pis, and Where the Work Happens)

"Where does the model run while it answers?" — that's what this chapter
answers. The competition: CPU cores vs GPU cores vs (rarely) both. You don't
need to be a hardware person; you need to know where your model is standing
and how to move it.

## First, look: `ollama ps`

```bash
ollama ps
```

The last column (`PROCESSOR`) whispers the whole truth:

- `100% GPU` — the model + context fully fit on the GPU. Best case.
- `CPU` — running on your processor. Fine for small models, slow for big ones.
- `70%/30% CPU/GPU` — *split*: some layers ran out of GPU room and spilled to
  CPU. Splitting usually feels much slower than the percentages suggest,
  because every generated token bounce between chips.

**If you see a split you didn't ask for, that's often your #1 speed bug.** Fix:
smaller quant (Chapter 6) or fewer GPU layers (`num_gpu`) — no, that's not a
typo; running *fewer* layers on a nearly-full GPU can be faster than a split
that constantly spills.

## Laptop (CPU-only): pinning cores with `taskset`

No GPU? Your CPU still has favorites. Modern laptops have Efficiency and
Performance cores (E/P). One-time-win trick: run Ollama's generation threads on
the performance cores.

```bash
# Find performance cores (look for high max MHz)
lscpu --extended | head -30

# Example: pin all Ollama work to CPU cores 4-7 on an 8-core machine
taskset -c 4-7 ollama run llama3.2:3b "hello"
```

`taskset` is standard Linux. It only affects the process you run it on, so it
also works for a quick A/B: same model, pinned vs not, stopwatch in hand.

**Threads:** leave `num_thread` alone unless testing proves otherwise.
Ollama's default (usually physical cores) is close to ideal; oversubscribing
hurts more than helping. One honest test beats ten opinions.

## Laptop (with a GPU): keep it all on GPU

1. Model with a `q4_K_M` quant that fits whole in your VRAM (Chapter 6).
2. `ollama ps` says `100% GPU` — you've won; stop tuning, enjoy.
3. If it says split: `num_gpu` down until it's not split. Counteract with a
   smaller model/quant as needed.

Windows-on-laptop with shared graphics memory: also fine (Ollama uses the
shared VRAM), just watch for the split message.

## Raspberry Pi (5, 8GB): the pure-CPU world

A Pi has no GPU worth using for LLMs, so everything is CPU — and Pi cores are
Performance cores all around, meaning:

- Small quantized models are fine: 1B–3B at `q4` quants produce genuinely
  pleasant speeds (reading speed, not typing speed).
- Pinning to specific cores rarely helps — but *power* does: make sure
  you're not in a `ondemand`-governor thermal trip. Just run everything you
  plan to keep and let `ollama ps` show you the truth.
- For a Pi, memory is the budget: 8GB Pi comfortably holds a 3B at q4 + room
  to spare; an 8B is possible but stop-and-think territory.

```bash
# Pi-friendly daily driver after install:
ollama run llama3.2:3b --keepalive 1h
```

## Macs (Apple Silicon): the unified-memory cheat code

If you're on an M-series Mac, there's no CPU/GPU split at all — the model sits
in unified memory and everything is fast. Your speed lever is simply model
size and `num_ctx`. Skip this chapter's pinning tricks; Chapter 4 is your
whole sport.

## The decision tree (one glance)

```
ollama ps shows...        do this next
------------------------  --------------------------------------------
100% GPU                  nothing — you're done, you beautiful winner
split (e.g. 55%/45%)      smaller quant, or num_gpu down, or num_ctx down
CPU on a machine w/ GPU   check why: no VRAM? big ctx? then re-pin smaller
CPU only, no GPU          pin perf cores w/ taskset; ladder (Ch 4)
Pi                        small model + keepalive; hugs to Pi Club
```

Next: **Chapter 6 — Quantization in Plain English** (how to squeeze a big
model into small memory).
