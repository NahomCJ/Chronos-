# Onboarding — Full-Stack Developer

**Role:** Bridge between the Panther AI backend (owned by Martín) and the CHRONOS mobile app.

**Start date:** 2026-04-15

---

## Mission

Integrate the capabilities that are already LIVE in the backend into the mobile app. Nothing else. You are not building AI, you are not designing features, you are not touching the classifier or the risk engine. You make the existing backend reach the user's phone.

---

## Scope

### You own
- Everything inside the mobile app repo (once located — see Discovery phase).
- The HTTP client, auth layer, state management, and UI screens that consume backend endpoints.
- The contract of "what mobile expects from backend" — you write it down, Martín confirms it.

### You integrate (LIVE backend capabilities)
- `POST /api/authorize-payment` — payment authorization + BNPL risk.
- `POST /api/kevin/chat` — Kevin chat assistant.
- `GET /api/transactions` + `GET /api/transactions/{id}` + `PATCH /api/transactions/{id}` — transaction list + user feedback loop.

### You DO NOT touch
- `services/` — any Python service (classifier, risk, BNPL, banking, Kevin engine).
- `routers/` — any FastAPI router. If you need a new endpoint, you ask Martín.
- The transaction classifier, the regex dictionary, the BERT model, the taxonomy.
- `/api/insights/*` — these endpoints return mock data. Parked until backend migrates them to real data. Do not wire them to UI.
- `/webhooks/plaid/transactions` — server-to-server webhook. Not your problem.
- Shopping Assistant and Health Metrics features — Martín is building those. You will integrate them later, not now.

### Golden rule
If you feel the urge to "quickly fix something in the backend", stop and ping Martín in `#blockers`. The backend is a contract, not a shared codebase.

---

## Phase 1 — Discovery (days 1-3)

Before writing a single line of integration code, you need answers to four questions. This is your first sprint. See `tasks/SPRINT_INTEGRATION.md` for the tickets (D-1 to D-4).

**Why Discovery first:** Martín currently has zero contact with the mobile team. You are the bridge — start by building the bridge.

---

## Phase 2 — Integration (day 4+)

Once Discovery is reported and Martín green-lights the stack, move into the Integration tickets (I-1 to I-4). Full backlog in `tasks/SPRINT_INTEGRATION.md`.

---

## How we work together

### Daily report — Slack `#dev-updates`
Post once a day, end of day. Format:

```
✅ Done:
- [what you shipped today]

⚠️ Affects others: None / [what you changed that touches Martín's work]

🔜 Tomorrow:
- [what you'll ship tomorrow]
```

### Blockers — Slack `#blockers`
Any blocker goes here immediately, do not wait for the daily. A blocker is anything that stops you from making progress for more than 30 minutes.

### Decisions
If you need a decision from Martín (stack choice, endpoint contract, architectural call), write it in `#blockers` with three lines: **Context**, **Options**, **Recommendation**. You get an answer within the day.

### Progress tracking
`tasks/SPRINT_INTEGRATION.md` contains your checklist. Move tickets `[ ] → [/] → [x]` as you work. No silent progress. Martín reads this file to know where you are.

---

## Required reading (day 1, in order)

1. `CLAUDE.md` — project vision, stack, golden rules.
2. `docs/PantherAI/TransactionClassifier/README.md` — what the classifier does (context, not code you'll touch).
3. `docs/PantherAI/TransactionClassifier/ARCHITECTURE.md` — the 3-tier pipeline.
4. `tasks/SPRINT_INTEGRATION.md` — your backlog.
5. `main.py` — read it once to see how routers are wired. Do not edit.

---

## Local setup

```bash
# 1. Clone the repo and enter it
cd "CHRONOS"

# 2. Activate the virtual environment (already exists at project root)
source .venv/bin/activate

# 3. Run the backend locally
uvicorn main:app --reload

# 4. Verify it's up
curl http://localhost:8000/health
# Expected: {"status": "ok"}

# 5. Explore the interactive API docs
open http://localhost:8000/docs
```

If any of the above fails, ping `#blockers`. Do not debug `.venv` yourself.

### Sanity checks before Phase 2

Before starting Integration, confirm you can hit each LIVE endpoint from curl:

```bash
# Kevin chat
curl -X POST http://localhost:8000/api/kevin/chat \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user_marcus", "message": "what is my balance?"}'

# Transactions
curl "http://localhost:8000/api/transactions?user_id=user_marcus&days=30"

# Payment authorization
curl -X POST http://localhost:8000/api/authorize-payment \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user_marcus", "amount": 120, "merchant": "Amazon"}'
```

The exact request/response schemas are in `http://localhost:8000/docs` (FastAPI auto-generated). Use that as your source of truth, not this document.

---

## Known backend gaps (context, not your job to fix)

Martín is working on a parallel Foundation sprint to address these. Do not block on them — use the workarounds below until Martín ships the real thing.

| Gap | Workaround for now | Real fix |
|---|---|---|
| No auth | Pass `X-User-Id: user_marcus` header (placeholder) | JWT middleware (Martín, Foundation sprint) |
| No `/v1/` prefix | Call `/api/...` directly | Versioning rollout (Martín) |
| CORS open `*` | Fine for local dev | Locked to known origins (Martín) |
| No rate limiting | Fine for dev; do not stress-test Ollama | Middleware (Martín) |

**Critical:** wrap every HTTP call in a single `apiClient` module with one place where the base URL, headers, and auth token are injected. When Martín ships JWT, you change one line. If you scatter `fetch()` calls across components, you will regret it in two weeks.

---

## Definition of Done (per ticket)

A ticket is done when:
1. The code is merged to the mobile repo's main branch.
2. The flow works end-to-end against the local backend (screen → HTTP call → response → UI update).
3. You have a short Loom or screenshot of the flow working on a real device or simulator.
4. The ticket checkbox in `SPRINT_INTEGRATION.md` is `[x]`.
5. The daily report mentions it under ✅ Done.

No "I pushed it, should work" without verification. Ever.

---

## Who to ask for what

- **Backend contracts, endpoint behavior, new endpoints needed:** Martín, `#blockers`.
- **Mobile stack decisions, UI, state management, local tooling:** you own these. Decide and document.
- **Product / feature scope:** Martín, `#blockers`. Do not design features yourself.

Welcome aboard.
