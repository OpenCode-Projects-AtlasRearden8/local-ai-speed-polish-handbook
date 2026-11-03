# Chapter 7 — The Hotel-AI Speed Test (Stopwatches, Honest Scorecards)

Here's the thing about "feels faster": feelings are terrible measuring tools.
This chapter gives you a stopwatch-and-scorecard test you can run on any
machine, with no installs beyond Ollama. It's called the **hotel-AI speed
test** because it borrows the four things a front desk at a hotel cares about:

1. **Check-in** — how long until a brand-new guest gets served?
2. **Wake-up** — you phoned ahead; did they remember? (Warm vs cold start)
3. **Follow-up** — "and one more thing..." (cached conversation speed)
4. **Big luggage** — can they handle it without breaking a sweat? (Large prompt)

You can run it by hand with a kitchen timer, or let the included script run it
for you (same events, same questions, one scorecard):

```bash
bash scripts/hotel-speed-test.sh llama3.2:3b
```

## The four events (run by hand version)

Use any stopwatch. Each test: note **time to first word** (TTFT) and **total
time**.

### Event 1 — Cold check-in

Quit Ollama (or wait 6+ minutes after unloading), then start it and ask:

> "In one paragraph, explain what a hotel front desk does."

This measures a *fully cold* interaction: server start + model load + first
answer. Expect the biggest, most shameless number of the session. (On a
typical laptop with an 8B: 20–60+ seconds. With a 3B: often under 10.)

### Event 2 — Wake-up call (warm check)

Immediately ask a *different* question:

> "In one paragraph, explain what a hotel concierge does."

Same model, now warm. The gap between Event 1 and Event 2 is what keep-alive
buys you. Write both down.

### Event 3 — The follow-up

Right after Event 2, in the same chat:

> "Could you make that more formal?"

Cached conversation ⇒ this should be the *snappiest* event. If it isn't, your
prompt cache is being broken somehow (Chapter 3's cache rules).

### Event 4 — Big luggage submits a form

Ask a question with a genuinely large prompt — paste a few pages of text
(transcript, article, policy doc) followed by one short question:

> "Based ONLY on the text above, list three rules about check-out times."

This stresses prompt processing. Big-luggage time is where `num_ctx` and KV
cache settings earn their keep (Chapters 2 and 6).

## The honest scorecard

Copy this into a note and fill it in. Do this **before and after every tuning
change** — one change at a time.

```
HOTEL-AI SPEED TEST — <date> — <machine> — <model + quant>

Event                        TTFT (s)   Total (s)   Notes
1. Cold check-in             ____       ____
2. Warm check-in             ____       ____
3. Follow-up (same chat)     ____       ____
4. Big luggage (long prompt) ____       ____

Verdict (tick what changed vs last card):
[ ] Check-in improved  → keep-alive / model size / quant helped
[ ] Wake-up ≈ instant → warm cache is doing its job
[ ] Follow-up fastest  → prompt cache intact
[ ] Big luggage OK     → context settings healthy
One thing I changed this session: ______________________
```

## The rules (so the numbers mean something)

1. **One change between scorecards.** Two changes muddle everything.
2. **Same prompts, same order, same machine state, same time of day if you
   can** (thermals and background apps lie).
3. **Two cold runs if it's your first time** — first-ever runs include disk
   caching warmth; the second tells the truer story.
4. **Write it down.** A scorecard you can't compare is a story, not a test.
5. **Honesty over flattery.** "No improvement" is a *result*, not a failure.
   Plenty of settings don't help your hardware. Crossing them out is progress.

## Running it automatically

The script runs all four events against Ollama's API and prints the scorecard
for you. It will politely refuse to run if Ollama isn't up (and remind you how
to warm up), because half-finished benchmarks are worse than a shrug:

```bash
bash scripts/hotel-speed-test.sh llama3.2:3b          # defaults
bash scripts/hotel-speed-test.sh llama3.1:8b -o card  # save scorecard to card
```

Next: **Chapter 8 — The Month-Refresh Ritual** (keeping the polish polished).
