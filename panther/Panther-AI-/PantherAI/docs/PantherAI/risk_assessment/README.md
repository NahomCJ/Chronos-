# Risk Assessment Service [LIVE]

**Responsibility:** Determines if a payment will endanger a user's ability to cover upcoming bills and rent, returning a risk level (HIGH/MEDIUM/LOW), projected balance, and a human-readable warning.
**Depends on:** `services/banking/mock_api.py` (`get_balance`, `get_upcoming_bills`, `get_active_bnpl_amount`)

## Contracts
**Input:**
```python
assess_payment_risk(user_id: str, amount: float) -> RiskAssessmentResponse
```
**Output:**
```json
{
  "is_risky": true,
  "risk_level": "HIGH",
  "warning_message": "⚠️ Your Rent of $1,500.00 is due in 3 days. This payment will leave you with a negative balance of -$295.99.",
  "projected_balance": -295.99,
  "confidence": 1.0
}
```

**Raises:**
- `ValueError` — unknown `user_id` (bubbled from `mock_api.get_balance`)

## Test Command
```bash
pytest tests/test_risk_assessment.py -v
```
