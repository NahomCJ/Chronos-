# Migrate Kevin from OpenAI SDK to Ollama Python SDK

**Sprint goal:** Replace the OpenAI compatibility shim with the native Ollama SDK to unlock thinking mode control, `keep_alive`, and proper timeouts. Target: cut Kevin's avg response time from ~13s to ~5-7s.

**Estimated effort:** 2.5h total

---

## Why This Matters

Kevin currently calls Qwen3.5 through `openai.OpenAI(base_url="...ollama/v1")` — a compatibility layer. This forces:

1. **Qwen's thinking mode is always ON** — adds ~20s of hidden reasoning per call. The `/v1` compat layer has no way to set `think=False`. Kevin currently parses `<think>` tags manually (lines 155-161 in kevin.py) as a workaround.
2. **No timeout** — OpenAI SDK defaults to 600s. A stuck Ollama request blocks for 10 minutes.
3. **No `keep_alive`** — Model gets unloaded between idle periods, causing cold-start latency.
4. **Dummy API key hack** — `api_key="ollama"` because the SDK requires it but Ollama ignores it.

The Ollama Python SDK is purpose-built for this. It exposes `think`, `keep_alive`, `options` (num_ctx, temperature), and returns `response.message.thinking` directly — no tag parsing needed.

---

## Dependency Diagram

```
TASK 1: Install ollama SDK + update client
     ↓
TASK 2: Rewrite _llm_chat() tool loop
     ↓
TASK 3: Update tools.py format (minor)
     ↓
TASK 4: Update kevin_cli.py debug output
     ↓
TASK 5: Run promptfoo suite — validate 18/18
```

All tasks are sequential (same file, same engineer).

---

## Files Changed

| File | Change |
|------|--------|
| `services/conversational_ai/kevin.py` | Replace OpenAI client with Ollama client, rewrite `_llm_chat()` |
| `services/conversational_ai/tools.py` | Tool format stays OpenAI-compatible (Ollama accepts both) — no change needed |
| `scripts/kevin_cli.py` | Update debug output to use `response.message.thinking` instead of parsed tags |
| `.env` | Add `KEVIN_OLLAMA_HOST` (replaces `KEVIN_LLM_BASE_URL`) |
| `tests/promptfoo/kevin_provider.js` | No change (hits FastAPI, not Ollama directly) |

---

### 👤 CLAUDE — The Engine Surgeon (2.5h)
**Your Role:** Swap Kevin's LLM communication layer from OpenAI-compat to native Ollama without changing any external behavior. Same API contract, faster responses.

---

#### TASK 1: Install Ollama SDK + Replace Client (15min)

**What to build:**
Replace `openai.OpenAI` with `ollama.Client` in `_get_client()`. Remove the dummy API key hack.

**Current code (kevin.py:45-56):**
```python
from openai import OpenAI
_client = OpenAI(
    base_url=KEVIN_LLM_BASE_URL,
    api_key="ollama",
)
```

**Target code:**
```python
from ollama import Client
_client = Client(host=KEVIN_OLLAMA_HOST)
```

**Changes:**
- `pip install ollama` in `.venv`
- Rename env var: `KEVIN_LLM_BASE_URL` → `KEVIN_OLLAMA_HOST` (default: `http://localhost:11434`)
- Remove `/v1` suffix — Ollama SDK uses its own endpoints
- Remove `api_key="ollama"` hack

**Done when:**
- [x] `ollama` package installed in `.venv`
- [x] `_get_client()` returns an `ollama.Client` instance
- [x] Env var `KEVIN_OLLAMA_HOST` documented in `.env`

---

#### TASK 2: Rewrite `_llm_chat()` Tool Loop (1h)

**What to build:**
Rewrite the core tool-calling loop to use `client.chat()` instead of `client.chat.completions.create()`. Add `think` parameter control and `keep_alive`.

**The big performance win:** Disable thinking for tool-routing iterations (iteration 1-2), enable only for the final user-facing response. This cuts ~20s per tool-routing call.

**Current call (kevin.py:144-149):**
```python
response = client.chat.completions.create(
    model=KEVIN_MODEL,
    messages=messages,
    tools=TOOL_DEFINITIONS,
    tool_choice="auto",
)
```

**Target call:**
```python
response = client.chat(
    model=KEVIN_MODEL,
    messages=messages,
    tools=TOOL_DEFINITIONS,
    think=False,          # No thinking for tool routing — saves ~20s
    keep_alive="10m",     # Keep model loaded between requests
    options={
        "num_ctx": 8192,
        "temperature": 0.7,
    },
)
```

**Key API differences to handle:**

| Aspect | OpenAI SDK (current) | Ollama SDK (target) |
|--------|---------------------|---------------------|
| Response content | `response.choices[0].message.content` | `response.message.content` |
| Tool calls | `response.choices[0].message.tool_calls` | `response.message.tool_calls` |
| Tool call name | `tool_call.function.name` | `tool_call.function.name` (same) |
| Tool call args | `json.loads(tool_call.function.arguments)` (string) | `tool_call.function.arguments` (already a dict) |
| Thinking | Manual `<think>` tag parsing | `response.message.thinking` (native field) |
| Token usage | `response.usage.prompt_tokens` | `response.prompt_eval_count` |
| Appending assistant msg | `messages.append(choice.message)` (OpenAI obj) | `messages.append(response.message)` (Ollama obj) |
| Tool result msg | `{"role": "tool", "tool_call_id": id, "content": json}` | `{"role": "tool", "content": json}` |

**Thinking strategy per iteration:**
```python
for iteration in range(3):
    is_final = (iteration == 2)  # Last iteration
    has_tool_results = any(m.get("role") == "tool" for m in messages)

    response = client.chat(
        model=KEVIN_MODEL,
        messages=messages,
        tools=TOOL_DEFINITIONS if not is_final else None,
        think=has_tool_results,  # Think only when composing final answer with data
        keep_alive="10m",
    )
```

**Fallback response (loop exhausted, line 208-224):**
```python
response = client.chat(
    model=KEVIN_MODEL,
    messages=messages,
    think=True,       # Final response — think is fine here
    keep_alive="10m",
)
```

**Debug info update:**
- Replace `response.usage.prompt_tokens` → `response.get("prompt_eval_count")`
- Replace `response.usage.completion_tokens` → `response.get("eval_count")`
- Replace manual `<think>` tag parsing → `response.message.thinking`

**Done when:**
- [x] `_llm_chat()` uses `client.chat()` with Ollama SDK API
- [x] Thinking disabled for tool-routing calls, enabled for final response
- [x] `keep_alive="10m"` set on every call
- [x] No more `<think>` tag parsing — uses `response.message.thinking`
- [x] `tool_call.function.arguments` accessed as dict (no `json.loads`)
- [x] Debug output still works (`llm_steps` has timing, thinking, tokens)
- [x] Mock fallback (`_mock_response`) unchanged — not affected

---

#### TASK 3: Verify tools.py Compatibility (10min)

**What to check:**
The Ollama SDK accepts tool definitions in the same OpenAI format:
```python
{"type": "function", "function": {"name": ..., "description": ..., "parameters": ...}}
```

This is confirmed by Ollama docs. `TOOL_DEFINITIONS` in tools.py can stay as-is.

**One change:** In `execute_tool()`, tool arguments will now arrive as a **dict** (from Ollama SDK) instead of a JSON **string** (from OpenAI SDK). Since kevin.py already calls `json.loads(tool_call.function.arguments)` before passing to `execute_tool()`, we just remove that `json.loads` call in kevin.py — `tools.py` itself stays untouched.

**Done when:**
- [x] Verified `TOOL_DEFINITIONS` format works with Ollama SDK (no changes needed)
- [x] Confirmed `execute_tool()` receives dict args correctly

---

#### TASK 4: Update kevin_cli.py Debug Output (15min)

**What to build:**
The CLI reads `result["debug"]["llm_steps"]` to display thinking and token counts. The data structure stays the same, but the field sources change:

- `step["thinking"]` — now comes from `response.message.thinking` (cleaner, no tag parsing)
- `step["usage"]` — now uses `prompt_eval_count` / `eval_count` field names

Since kevin.py builds the `llm_steps` list and kevin_cli.py just reads it, **the CLI may not need any changes** if we keep the debug dict structure consistent in kevin.py. Verify and adjust if needed.

**Done when:**
- [x] `kevin_cli.py` displays thinking, timing, and token counts correctly
- [x] No crashes when running `python scripts/kevin_cli.py`

---

#### TASK 5: Run Promptfoo Suite — Validate 18/18 (30min)

**What to build:**
Run the existing promptfoo test suite to verify the migration didn't break anything. The tests hit the FastAPI endpoint, which calls kevin.py, which now uses Ollama SDK internally.

**Steps:**
1. Restart FastAPI server with new code
2. Run `cd tests/promptfoo && promptfoo eval --no-cache`
3. Expect 18/18 passing
4. If any fail: check if the response structure changed (e.g., `tools_called` field missing)
5. Compare response times: expect ~5-7s avg vs ~13s before

**Done when:**
- [x] `promptfoo eval` shows 18/18 passing (100%)
- [x] Average response time measurably faster (check `debug.total_duration_s`)
- [x] No regressions in tool routing, guardrails, or edge cases

---

## What Does NOT Change

- **`services/conversational_ai/tools.py`** — Tool definitions and executor stay identical
- **`routers/kevin_chat/router.py`** — API contract unchanged
- **`_mock_response()` in kevin.py** — Fallback logic untouched
- **`tests/promptfoo/kevin_tests.yaml`** — Same assertions, same test cases
- **`tests/promptfoo/kevin_provider.js`** — Hits FastAPI, not Ollama directly

## Integration Checklist

- [x] `pip install ollama` in `.venv`
- [x] `kevin.py` uses `ollama.Client` instead of `openai.OpenAI`
- [x] `think=False` on tool-routing calls, `think=True` on final response
- [x] `keep_alive="10m"` on every `client.chat()` call
- [x] No `<think>` tag parsing — use `response.message.thinking`
- [x] `tool_call.function.arguments` is dict, not JSON string
- [x] FastAPI endpoint returns same response shape
- [x] CLI debug output works
- [x] 18/18 promptfoo tests pass
- [x] Response time improved (target: ~5-7s from ~13s)
