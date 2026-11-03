# Chapter 2 — Turbo Settings (The Ones That Actually Matter)

Ollama has dozens of knobs. Four of them earn their keep. Set these, measure
with the stopwatch, and you've done 90% of the tuning most people will ever
need.

The rest of this chapter explains each one in plain English, then shows how to
set them so they **persist** (survive reboots) on Linux and macOS.

## The Big Four

### 1. `OLLAMA_KEEP_ALIVE` — the warm-engine setting

The model's "stay loaded" timer. Default: 5 minutes of quiet, then unload.
Set it higher and repeated questions stay fast.

```bash
# Values: 10m, 1h, 24h... or -1 to keep loaded until you stop Ollama
OLLAMA_KEEP_ALIVE=1h ollama serve
```

Also per-request in the API: `"keep_alive": "1h"`. Details and the RAM
tradeoff (a warm model *occupies memory the whole time*) in Chapter 3.

### 2. `num_ctx` — the context window (the quiet speed killer)

How many tokens the model "keeps in mind." Every token of context you reserve
costs memory and compute **even if you never use it**. App defaults vary but
are often generous; everyday Q&A rarely needs more than you're actually
saying.

Practical settings:

| Use case | Suggested `num_ctx` |
|----------|---------------------|
| Quick Q&A, rewrites, summaries of a page | 2048 |
| Summarizing multi-page docs | 8192 |
| RAG with a big pile of retrieved text | 8192–16384 |

Per-request example:

```bash
curl -s http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Summarize: water is wet and useful.",
  "options": {"num_ctx": 2048}
}'
```

Or per-model defaults (one-time):

```bash
ollama run llama3.2:3b
>>> /set parameter num_ctx 2048
>>> /save llama3.2-3b-turbo
```

### 3. `OLLAMA_FLASH_ATTENTION` — free speed, with one caveat

Enables a faster attention implementation. In recent Ollama versions it's a
speed/memory win on supported hardware, but combinations of model + quant +
GPU can be finicky, and on some older setups it changed nothing or produced
weird repeats. **Turn it on, run the stopwatch chapter; if numbers don't
improve, turn it off.** Nothing here is precious—this is the "try it"
category.

```bash
OLLAMA_FLASH_ATTENTION=1 ollama serve
```

Note: turning this on usually matters most *together* with the next setting,
KV cache quantization.

### 4. `OLLAMA_KV_CACHE_TYPE` — half the memory, none the wiser

The KV cache is the model's short-term scratchpad; its size grows with
`num_ctx`. You can store it at lower precision:

- `q8_0` (default when flash attention is on in recent versions): ~87% of the
  size of full precision — nearly free, do this.
- `q4_0`: ~48% of the size — halves scratchpad memory, small quality cost.
  Great when memory is tight (laptops, Pi).

```bash
OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 ollama serve
```

Rules of thumb: `q8_0` when unsure; `q4_0` when every byte counts (small VRAM
GPU or 8GB RAM machine).

## Low-traffic extras (nice, not required)

- `OLLAMA_NUM_PARALLEL=1` — one request at a time = smallest RAM footprint
  (each parallel slot multiplies context memory). Defaults vary; if you're a
  single user, 1 is plenty.
- `OLLAMA_MAX_LOADED_MODELS=1` — stop juggling two models in RAM. Speeds you
  up by never having two half-loads compete for memory.

## Making settings stick (the permanent version)

Environment variables typed on the `ollama serve` command line vanish when you
close the terminal. To make them permanent:

**Most Linux distros (systemd):**

```bash
sudo systemctl edit ollama
```

Add:

```ini
[Service]
Environment="OLLAMA_KEEP_ALIVE=1h"
Environment="OLLAMA_NUM_PARALLEL=1"
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="OLLAMA_KV_CACHE_TYPE=q8_0"
```

Then:

```bash
sudo systemctl restart ollama
systemctl show ollama | grep OLLAMA_   # confirm they took
```

**macOS:** the menu-bar app reads Settings → there's no env-var box in some
versions, so simplest is to quit the app and start from a terminal with the
vars, or use launchctl's `setenv`. If that feels like too much, the
per-request `"keep_alive"` and `options.num_ctx` routes work everywhere and
need zero setup — I lean on those in the scripts.

## The honest checklist

Set the Big Four, then measure (`scripts/bench-ollama.sh`). Keep what wins:

- [ ] `OLLAMA_KEEP_ALIVE` raised → first-token time on 2nd question
- [ ] `num_ctx` tightened → tok/s up, memory down
- [ ] `OLLAMA_FLASH_ATTENTION=1` →(tok/s up? keep it / no change? drop it)
- [ ] `OLLAMA_KV_CACHE_TYPE=q8_0` → memory down, answers unchanged

Next: **Chapter 3 — Cache Reuse**, the art of never paying the same tax twice.
