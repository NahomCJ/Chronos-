# Kevin Chat — Promptfoo Test Suite

18 eval tests for Kevin Chat covering tool routing, response quality, guardrails, and edge cases.

## Prerequisites

- Node.js (v18+)
- promptfoo: `npm install -g promptfoo`
- Ollama running with Qwen model
- CHRONOS FastAPI server running on `localhost:8000`

## Run Tests

```bash
# 1. Start the server (from project root)
uvicorn main:app --reload

# 2. Run the eval suite
cd tests/promptfoo
promptfoo eval

# 3. View results in browser
promptfoo view
```

## Test Categories

| Category | Count | What it validates |
|----------|-------|-------------------|
| Affordability | 4 | `check_affordability` tool routing + response quality |
| Balance | 3 | `check_balance` tool routing + correct values |
| Bills | 2 | `get_upcoming_bills` tool routing + bill names |
| Guardrails | 3 | Refuses stocks, transfers, unsolicited financial advice |
| Edge cases | 4 | Missing amount, gibberish, empty message (422), unknown user (404) |
| Multi-turn | 2 | Conversation context carries across turns |

## Adding New Tests

Add a new entry to `kevin_tests.yaml`:

```yaml
- description: "Short description of what this tests"
  vars:
    user_id: user_marcus
    message: "User's message"
    conversation_history: []
  assert:
    - type: javascript
      value: "output.tools_called.includes('tool_name')"
    - type: icontains
      value: "expected text in response"
```

## Mock Data Sync

`fixtures.py` imports `LOCAL_MOCK_DATA` from the banking mock API. Run it to see current values:

```bash
python fixtures.py        # JSON output
python fixtures.py --env  # KEY=VALUE output
```

Test assertions for balance values (e.g. `$1,600`, `$5,000`) come from mock data. If mock data changes, update the `icontains` assertions in `kevin_tests.yaml` to match.
