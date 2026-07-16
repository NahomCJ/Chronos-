# API Gateway

**Responsibility:** Boots the CHRONOS FastAPI server, registers CORS middleware, mounts all routers, and exposes a `/health` liveness probe.

**Depends on:** `core/logger.py`, `routers/payment_authorization/router.py`

## Contracts

**Input:**
```bash
uvicorn main:app --reload
```

**Output (GET /health):**
```json
{"status": "ok"}
```

**Registered Routes:**

| Method | Path | Router |
|--------|------|--------|
| GET | `/health` | inline (`main.py`) |
| POST | `/api/authorize-payment` | `routers/payment_authorization/router.py` |

## Test Command
```bash
curl http://localhost:8000/health
```
