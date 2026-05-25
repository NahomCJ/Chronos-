# BNPL Risk Scoring Service [LIVE]

**Responsibility:** Calculates a continuous risk score (0–100) for a Buy-Now-Pay-Later request, evaluating affordability against free cash flow and penalizing risky behavior (multiple active BNPLs, late payments).
**Depends on:** `services/banking/mock_api.py` (`get_balance`, `get_upcoming_bills`, `get_active_bnpl_amount`, `count_active_bnpls`, `count_late_bnpl_payments`)

## Contracts
**Input:**
```python
calculate_bnpl_risk_score(user_id: str, amount: float, num_payments: int) -> BNPLRiskScoreResponse
```
**Output:**
```json
{
  "score": 82,
  "risk_level": "LOW",
  "risk_factors": ["Excellent payment history and strong cash flow."],
  "recommendation": "✅ Safe to proceed. This BNPL fits well within your budget."
}
```

**Raises:**
- `ValueError` — `amount <= 0`, `num_payments` outside `[1, 36]`, or unknown `user_id`

## Test Command
```bash
pytest tests/test_bnpl_risk_scoring.py -v
```
