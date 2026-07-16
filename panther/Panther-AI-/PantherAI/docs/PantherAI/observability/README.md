# Observability [LIVE]

**Responsibility:** Structured JSON logging and a `@contract` decorator that auto-instruments contract boundaries with call, result, and failure traces.

**Depends on:** Nothing (zero external dependencies beyond Python stdlib + `logging`).

## Contracts

**`@contract` decorator — Input (any function call):**
```python
@contract
def authorize_payment(request: PaymentRequest) -> dict:
    ...
```

**Output (JSON log lines written to stderr):**
```json
{"ts": "2026-03-06T21:00:00Z", "level": "CONTRACT", "event": "authorize_payment", "args": "...", "kwargs": "..."}
{"ts": "2026-03-06T21:00:00Z", "level": "RESULT", "event": "authorize_payment", "duration_ms": 12.34, "result_preview": "..."}
```

**`StructuredLogger` methods:**

| Method | What it logs |
|--------|--------------|
| `log.contract(fn_name, **kwargs)` | Function called — `level: CONTRACT` |
| `log.result(fn_name, duration_ms, **kwargs)` | Function returned — `level: RESULT` |
| `log.failure(fn_name, error_type, message, **kwargs)` | Function raised — `level: FAILURE` |
| `log.phase(transition, module)` | Phase change — `level: PHASE_TRANSITION` |

## Test Command
```bash
pytest tests/test_authorization_flow.py -v
# (observability is exercised implicitly — no separate test suite)
```
