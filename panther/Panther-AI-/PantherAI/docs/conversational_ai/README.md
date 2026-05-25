# Conversational AI (Kevin)

**Responsibility:** Financial chat assistant that answers user questions using real banking data via LLM tool calling, with 3-layer defense against cross-user data leakage.

**Depends on:** `services/banking/mock_api.py`, `services/risk_assessment/risk_assesment.py`, `ollama` SDK, Qwen 3.5 model

## Contracts

**Input:**
```json
{
  "user_id": "user_marcus",
  "message": "Can I afford $500?",
  "conversation_history": [{"role": "user", "content": "..."}],
  "history_user_id": "user_marcus"
}
```

**Output:**
```json
{
  "response": "I'd be careful with that $500...",
  "tools_called": ["check_affordability"],
  "context_used": {"balance": 1600.0, "risk_level": "HIGH"},
  "conversation_history": {
    "user_id": "user_marcus",
    "messages": [{"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}]
  },
  "mode": "llm"
}
```

## Security: Cross-User Data Protection (3 Layers)

| Layer | Trigger | Defense | Type |
|-------|---------|---------|------|
| **1** | `history_user_id != user_id` | Strip entire history | Deterministic |
| **2** | `history_user_id` is None + history exists | Redact `$X` amounts from assistant messages via regex | Structural |
| **3** | Always | User identity embedded in system prompt + fresh-data rules | Prompt-based |

Callers MUST pass `history_user_id` to get Layer 1 protection. Without it, Layer 2 fires as fallback — safe but degrades multi-turn context.

## Files

| File | Role |
|------|------|
| `services/conversational_ai/kevin.py` | Core chat function + LLM tool loop |
| `services/conversational_ai/tools.py` | Tool definitions + executor (wraps Sprint 0 services) |
| `services/conversational_ai/nlp_utils.py` | Amount extraction (used by mock fallback only) |
| `routers/kevin_chat/router.py` | FastAPI endpoint: `POST /api/kevin/chat` |
| `scripts/kevin_cli.py` | Interactive terminal client |

## Test Command

```bash
pytest tests/test_kevin_chat.py -v
cd tests/promptfoo && npx promptfoo eval --no-cache
```
