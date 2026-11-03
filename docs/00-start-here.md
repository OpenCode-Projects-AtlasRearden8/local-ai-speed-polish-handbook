# Chapter 0 — Start Here: The 10-Minute Quick Win

You don't need to read the whole handbook to feel a difference. Do these four
things in order. Each one is small. Together they usually turn "sluggish" into
"snappy" on a typical laptop with Ollama.

> **The one-sentence version:** keep the model warm, shrink the context window
> to what you actually use, drop to the smallest model that still answers well,
> and time it so you can *see* the difference.

## 1. Keep the model loaded (2 minutes)

By default Ollama unloads a model from memory after **5 minutes** of quiet.
Next time you come back, it has to reload — that's usually the "first message
takes forever, then it's fine" feeling.

Fix it so models stay warm:

```bash
# Keep models loaded for an hour instead of 5 minutes (temporary, this session)
OLLAMA_KEEP_ALIVE=1h ollama serve
```

Or set it permanently for every request (see Chapter 2 for the permanent
version). Full walk-through in **Chapter 3 (Cache Reuse)**.

## 2. Shrink the context window (3 minutes)

Ollama's apps often default to large context sizes (varies by app), and the
default request from the plain "ollama run" chat needs far less than the model
pulls. Bigger context = more RAM held = slower every token, even when you never
use it.

Set a sensible floor in your requests:

```
/api/generate -> {"model": "llama3.2:3b", "prompt": "...", "options": {"num_ctx": 4096}}
```

4096 tokens covers most everyday Q&A. Details (and how to pick your own number)
in **Chapter 2**.

## 3. Try the smaller model (3 minutes)

The speed ladder, in one table:

| Model size | Feels like | Good for |
|------------|------------|----------|
| 8B | Comfortable |Drafting, long answers, deep questions |
| 3B | Snappy | Daily Q&A, summaries, rewrites |
| 1B | Instant | Quick facts, classification, autocomplete-style tasks |

Try: `ollama run llama3.2:3b` — if it answers your everyday questions well,
*that's your new daily driver,* and it's roughly 2–3× faster than an 8B on the
same hardware. Chapter 4 has the full ladder.

## 4. Time it (2 minutes)

You can't polish what you don't measure. Run:

```bash
bash scripts/bench-ollama.sh llama3.2:3b
```

Write the two numbers down (first-token delay, words-per-second). Do steps 1–3
for real. Run it again.

**That's the whole secret of this handbook:** change one thing, measure, keep
it if the number got better. The rest of the book is just more things to
change, and the honest stopwatch method to judge them.

---

Next: **Chapter 1 — Why Is It Slow?** So you stop guessing.
