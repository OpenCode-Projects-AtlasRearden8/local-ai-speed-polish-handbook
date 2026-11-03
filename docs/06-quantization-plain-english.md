# Chapter 6 — Quantization in Plain English

Quantization sounds like a math word. It isn't, really. Here's the whole idea
in one sentence:

> **Quantization = storing the model with fewer decimal places.**

A model is millions/billions of little numbers (weights). They're usually
stored precisely: 16-bit or 32-bit numbers. Quantization rounds those numbers
to coarser values so the whole model takes less disk space, less RAM, less GPU
memory — and becomes faster, because there's less data to shove around.

## The GGUF letter-number codes, decoded

You'll see names like `llama3.1:8b-instruct-q4_K_M`. The `q4_K_M` part is the
recipe. Decode it like this:

- **`q4`, `q5`, `q8`** = "4-bit", "5-bit", "8-bit" — roughly how many bits per
  number, on average. **Lower = smaller + faster + slightly dumber.**
- **`K`/`S`** = a modern smarter-quantization family (K-quants). "More
  efficient rounding," not a size.
- **`M` / `S` / `L`** = a version letter inside that family: Larger = more
  careful rounding for the same bit-count. **`M` is the everyday sweet spot.**

So `q4_K_M` ("Q4KM" in older names) reads: *4-bit K-quant, medium care*. If
this is all you learn about quants, that's the one to buy.

## The honest tradeoff table

Same 8B model, three quants, one table:

| Quant | ~Size (8B) | Speed feel | Quality feel | Who it's for |
|-------|-----------|------------|--------------|--------------|
| q4_K_M | ~4.7 GB | Fast | "Good" — noticeably fine for everyday chat/summaries | Laptops, Pis, GPUs |
| q5_K_M | ~5.7 GB | Slightly slower | Slightly sharper on tricky wording/reasoning | When memory allows |
| q8_0 | ~8.5 GB | Slightly slower still | Hard to tell from full precision without side-by-sides | When memory is easy and you want max quality |
| q2/q3 | ~2–3.5 GB | fastest of all |Gets chatty/confidently-wrong; don't rush here | Only when nothing else fits |

Two rules nobody tells you clearly:

1. **Below q4, quality drops fast.** Above q5, quality gains get tiny. The
   useful dial is *q4 → q5*; most everything else at the extremes is overkill
   either way.
2. **A smaller model at a higher quant often beats a bigger model at a lower
   quant** at the same memory budget (e.g. 4B-q8 vs 8B-q3-feels-like-mush).
   The stopwatch and a two-question taste test settle it on *your* machine.

## Does speed actually change with quant level?

Yes, in two ways:

- **Load time** shrinks (files are smaller): fewer cold-start seconds.
- **Tokens per second** go up modestly as bits go down — the retrieval + math
  is lighter. The big jump is *which model size* you chose; quant fine-tunes
  around it. (Chapter 4 = the big dial, this chapter = the fine dial.)

## Trying quant levels in Ollama

Ollama's default tags (like `llama3.1:8b`) ship at a solid default quant
(usually q4_K_M). To grab a specific one:

```bash
ollama run llama3.1:8b-instruct-q5_K_M
ollama run llama3.2:3b-instruct-q8_0
```

Check what you've actually got:

```bash
ollama list                     # shows SIZE
ollama show llama3.2:3b         # shows quantization level
```

You can also quantize a model yourself (creating your own smaller copy) with
`ollama create` + a Modelfile's `QUANTIZE` directive — but **for most people
pulling existing quants is all you need.**

## My plain-English recommendations

| Machine | Start with |
|---------|-----------|
| 8GB RAM laptop, no GPU | 3B `q4_K_M`, `num_ctx` 2048 |
| 16GB RAM laptop | 3B `q8_0` (or 8B `q4_K_M` if patient) |
| 8GB+ VRAM GPU | 7–8B `q4_K_M`, fully on GPU (check `ollama ps`)|
| Raspberry Pi 8GB | 3B `q4_K_M`, or 1B `q8_0` for instant small stuff |

Next: **Chapter 7 — The Hotel-AI Speed Test** (stopwatches, honest scorecards).
