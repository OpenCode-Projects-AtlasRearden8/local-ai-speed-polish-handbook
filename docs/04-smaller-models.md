# Chapter 4 — Smaller-Model Shortcuts: The Ladder

The single biggest speed win available to almost everyone is not a setting.
It's a smaller model used for the right job. Most people run their biggest
model for *everything*, including questions a tiny model answers just as well,
ten times faster.

## The ladder

Think of it as a staircase from "instant" to "thoughtful." Every step down is
roughly a 2–3× speed win on the same machine.

| Rung | Size | Same-machine feel | Right job |
|------|------|-------------------|-----------|
| 1 | 0.5B–1B | Instant | Quick facts, rewrites, classification, form-filling, "make this bullet point nicer" |
| 2 | 3B | Snappy | Everyday Q&A, summaries, emails, brainstorming, most of daily use |
| 3 | 7B–8B | Comfortable | Long-form drafting, trickier reasoning, keeping more nuance |
| 4 | 13B+ | Slow (strong feelings, slow feet) | Specialist work on dedicated/GPU hardware |

Real-world examples (typical laptop CPUs):

- `llama3.2:1b` — often 30–80 tok/s: reply-by-outrun-your-reading speed
- `llama3.2:3b` — often 10–25 tok/s: typing-partner speed
- `llama3.1:8b` — often 4–10 tok/s: podcast-in-the-background speed

(Your numbers will differ. That's what the stopwatch test is for.)

## The pairing habit that actually works

Don't pick *one* model — pick a **pair**:

1. A **quick model** (1B or 3B) for the 90% of messages that are ordinary.
2. A **deep model** (7–8B) for the ones that deserve the wait.

In practice: start with the quick model. If the answer feels thin, re-ask the
deep model. Ninety percent of the time you never re-ask, and you just banked
the speed difference.

## "Distilled" and "mini" models — what those names mean

- **Distill/mini** names (`gemma3:4b`, `phi3.5`, `qwen3:1.7b`) generally mean
  "smarter per byte" — a smaller model trained to imitate a bigger one or built
  with better recipes. They're the reason 2025's 3B feels like 2023's 7B.
- Rule: any literate-looking 3B/4B today usually beats most 7B models of two
  years ago.

## The shortcut table: what to ask which

| Task | Use the ladder's |
|------|------------------|
| "Rewrite this, make it nicer" | 1B–3B |
| Summarize an article | 3B |
| "What does this word mean?" | 1B |
| Draft an email from bullet points | 3B |
| Planarize a messy 3-page brain dump | 7–8B (worth the wait) |
| "Did I already send this?"-style lookup | 1B |

## Don't shrink past the point of usefulness

Small models have small vocabularies of *ideas*. Signs you've gone too small:
answers that repeat the same sentence shape, forget constraints from two
messages ago, or confidently invent odd facts. If that starts to happen on a
task, go one rung **up**, not two.

The ladder plus the stopwatch (Chapter 7) is the whole method. When a task is
*slow*, check: am I on the right rung?
