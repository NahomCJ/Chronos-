# Panther Mobile API Contract

Status: [LIVE] draft contract for mobile sprint integration.

Source of truth:
- Runtime schemas: `http://localhost:8000/docs`
- Backend code: `Panther-AI-`
- Sprint scope: `tasks/SPRINT_INTEGRATION.md`

## Client Rules

- All HTTP calls go through one `apiClient` module.
- No screen calls HTTP directly.
- Base URL comes from `API_BASE_URL`.
- Placeholder auth is injected once:
  - Header: `X-User-Id: user_marcus`
  - Request/query `user_id`: `user_marcus`
- TODO marker for future auth:
  - `TODO(auth): replace X-User-Id with JWT Bearer when backend ships auth.`

## Health

`GET /health`

Response:

```json
{ "status": "ok" }
```

## Payment Authorization

`POST /api/authorize-payment`

Request:

```json
{
  "user_id": "user_marcus",
  "amount": 120,
  "merchant": "Amazon",
  "payment_type": "standard",
  "num_payments": null
}
```

BNPL request:

```json
{
  "user_id": "user_marcus",
  "amount": 500,
  "merchant": "Apple Store",
  "payment_type": "bnpl",
  "num_payments": 4
}
```

Response:

```json
{
  "authorization_id": "uuid",
  "status": "pending",
  "warning": {
    "cash_flow": {
      "is_risky": false,
      "risk_level": "LOW",
      "warning_message": "string",
      "projected_balance": 1000,
      "confidence": 0.9
    },
    "bnpl": null,
    "combined_message": "string"
  }
}
```

## Kevin Chat

`POST /api/kevin/chat`

Request:

```json
{
  "user_id": "user_marcus",
  "history_user_id": "user_marcus",
  "message": "what is my balance?",
  "conversation_history": []
}
```

Response:

```json
{
  "response": "string",
  "tools_called": ["string"],
  "context_used": {},
  "domain": "banking",
  "conversation_history": {}
}
```

Mobile security rule:
- Always set `history_user_id` to the current user.
- Never pass another user's history.

## Transactions

`GET /api/transactions?user_id=user_marcus&days=30`

Response:

```json
[
  {
    "id": "string",
    "user_id": "user_marcus",
    "merchant_name": "string",
    "amount": 12.34,
    "date": "2026-04-30",
    "subcategory": "sub_groceries",
    "category_confidence": 0.91,
    "category_source": "regex",
    "user_corrected": false
  }
]
```

`GET /api/transactions/{id}`

Returns one transaction object.

`PATCH /api/transactions/{id}`

Request:

```json
{ "subcategory": "sub_groceries" }
```

Response:

```json
{
  "id": "string",
  "subcategory": "sub_groceries",
  "user_corrected": true
}
```

## Out Of Scope

Do not wire these without a new ticket:

- `/api/insights/*`
- `/webhooks/plaid/transactions`
- Shopping Assistant endpoints
- Health Metrics endpoints
- Chronos production `/api/ai/*` replacement routes
