# End-to-End Validation Script [LIVE]

**Responsibility:** Proves the full payment pipeline (banking API → risk assessment → BNPL scoring → HTTP endpoint) works end-to-end, regardless of whether data comes from `LOCAL_MOCK_DATA` or Supabase.
**Depends on:** `services/banking/mock_api.py`, `services/risk_assessment/risk_assesment.py`, `services/bnpl_risk_scoring/bnpl_risk_scoring.py`, `main.py` (FastAPI app)

## Contracts
**Input:**
```bash
python scripts/validate_e2e.py
```
**Output (success):**
```text
🔍 Running end-to-end validation...
   Data source: LOCAL_MOCK_DATA

   ✅ get_balance("user_marcus") → 1600.0
   ✅ get_upcoming_bills("user_marcus") → [...]
   ✅ count_active_bnpls("user_marcus") → 2
   ✅ assess_payment_risk("user_marcus", 200.0) → {...}
   ✅ assess_payment_risk → risk_level valid → HIGH
   ✅ calculate_bnpl_risk_score("user_marcus", 200.0, 4) → {...}
   ✅ calculate_bnpl_risk_score → score 0-100 → score 15, HIGH
   ✅ POST /api/authorize-payment (standard) → 200, LOW
   ✅ POST /api/authorize-payment (bnpl) → 200, HIGH + HIGH
   ✅ POST /api/authorize-payment (unknown user) → 404, Unknown user: user_nonexistent

   10/10 checks passed ✅
```

**Exit codes:** `0` = all checks passed, `1` = one or more checks failed.

## Test Command
```bash
python scripts/validate_e2e.py
```
