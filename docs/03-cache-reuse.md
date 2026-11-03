# Chapter 3 — Cache Reuse: Never Pay the Same Tax Twice

Your local AI has three caches that most people never think about, and each
one can save you real seconds. This chapter is about using all three on
purpose.

## Cache 1: The model itself (the big one)

Loading a 3B model off disk takes a couple of seconds; loading an 8B on a
slower laptop can take 10–30. That's why this is Chapter 3's headline:

```bash
curl -s http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "warm up please",
  "keep_alive": "1h"
}'
```

That one request now keeps the model in memory for an hour. Your next hour of
questions skips the load entirely.

**Pin a favorite** with the CLI:

```bash
ollama run llama3.2:3b --keepalive 1h
```

**Pin everything, always** with the env var (Chapter 2 has the permanent
setup): `OLLAMA_KEEP_ALIVE=1h`.

**Un-pin temporarily** when RAM is tight: send `"keep_alive": 0` and Ollama
unloads it right after answering, freeing memory for something else. The knob
goes both ways.

## Cache 2: The prompt cache (repeated beginnings)

The KV cache (Chapter 2 mentioned it as a *memory* cost — here's its *speed*
upside): if your conversation keeps the same beginning — same system prompt,
same document you're asking about — Ollama reuses the work it already did on
those tokens instead of recomputing from scratch.

Practical consequences, in plain English:

1. **Keep the shared prefix at the front.** System prompt + big pasted
   document first, question last. If you reuse (reword or reorder) the shared
   part, you break the cache.
2. **Follow-up questions are nearly free** in the same session — the earlier
   conversation is still cached. That's not luck; that's the cache working.
3. **Different sessions, same big document?** Repeat the identical document
   text and the second session picks up where the first left off (while the
   cache is alive).

A quick feel for it: ask a long-document question twice in a row. The first
waits noticeably longer — that gap was the prompt being processed the first
time. Rewording the shared intro breaks it and you pay again.

## Cache 3: Downloads (model files)

Nothing loads faster than not loading at all. If you bounce between two models
routinely (say `3b` for work and `1b` for quick stuff), just leave *both*
pinned. The reliable way to pin is one API warm-up per model:

```bash
curl -s http://localhost:11434/api/generate -d '{"model":"llama3.2:3b","prompt":"warm","keep_alive":"1h"}' > /dev/null
curl -s http://localhost:11434/api/generate -d '{"model":"llama3.2:1b","prompt":"warm","keep_alive":"1h"}' > /dev/null
```

```bash
curl -s http://localhost:11434/api/generate -d '{"model":"llama3.2:1b","prompt":"warm","keep_alive":"1h"}' > /dev/null
```

Check what's actually in memory right now:

```bash
ollama ps
```

`PROCESSOR` column shows if it's parked on GPU, CPU, or split. `ollama ps` is
the honest mirror for Chapters 3 and 5.

## The warm-up habit (the 20-second ritual)

After a reboot, or first thing when you sit down:

```bash
bash scripts/bench-ollama.sh llama3.2:3b warmup
```

...or just one throwaway question. Then start real work. That's it.

---

Next: **Chapter 4 — Smaller-Model Shortcuts**, the biggest speed win of all.
