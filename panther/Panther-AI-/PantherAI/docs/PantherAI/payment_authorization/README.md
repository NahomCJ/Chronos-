# Payment Authorization Router [LIVE]

**Responsibility:** Unified HTTP endpoint that receives a payment request, runs risk assessment (always) and BNPL scoring (if `payment_type == "bnpl"`), and returns a combined warning the mobile app can display directly.
**Depends on:** `services/risk_assessment/risk_assesment.py`, `services/bnpl_risk_scoring/bnpl_risk_scoring.py`, `core/logger.py`

## Contracts
**Input (POST `/api/authorize-payment`):**
```json
{
  "user_id": "user_marcus",
  "amount": 200.00,
  "merchant": "AMAZON",
  "payment_type": "bnpl",
  "num_payments": 4
}
```
**Output (200):**
```json
{
  "authorization_id": "uuid-v4",
  "status": "pending",
  "warning": {
    "cash_flow": {
      "is_risky": true,
      "risk_level": "HIGH",
      "warning_message": "...",
      "projected_balance": -295.99,
      "confidence": 1.0
    },
    "bnpl": {
      "score": 15,
      "risk_level": "HIGH",
      "risk_factors": ["..."],
      "recommendation": "..."
    },
    "combined_message": "..."
  }
}
```

**Error Responses:**
| Code | Condition |
|------|-----------|
| 400  | `payment_type == "bnpl"` but `num_payments` is missing |
| 404  | Unknown `user_id` (from risk assessment `ValueError`) |
| 422  | `amount <= 0`, or `num_payments` outside `[1, 36]` |

## Test Command
```bash
pytest tests/test_authorization_flow.py -v
```
