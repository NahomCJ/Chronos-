"""
scripts/validate_e2e.py
========================
End-to-end validation for the CHRONOS payment pipeline.

Proves that mock_api → risk assessment → BNPL scoring → HTTP endpoint
all work together, regardless of whether data comes from LOCAL_MOCK_DATA
or Supabase.

Usage:
    python scripts/validate_e2e.py

Exit codes:
    0 — all checks passed
    1 — one or more checks failed
"""

import sys
from pathlib import Path

# Ensure project root is on sys.path so imports work from /scripts/
ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from services.banking.mock_api import (
    get_balance,
    get_upcoming_bills,
    count_active_bnpls,
    _using_supabase,
)
from services.risk_assessment.risk_assesment import assess_payment_risk
from services.bnpl_risk_scoring.bnpl_risk_scoring import calculate_bnpl_risk_score

from fastapi.testclient import TestClient
from main import app


# ---------------------------------------------------------------------------
# Test harness
# ---------------------------------------------------------------------------

_passed = 0
_failed = 0


def check(label: str, fn):
    """Run a single check. Print pass/fail. Never raises."""
    global _passed, _failed
    try:
        result = fn()
        print(f"   ✅ {label} → {result}")
        _passed += 1
    except Exception as e:
        print(f"   ❌ {label} → FAILED: {e}")
        _failed += 1


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def main():
    global _passed, _failed
    _passed = 0
    _failed = 0

    source = "Supabase (live)" if _using_supabase() else "LOCAL_MOCK_DATA"
    print(f"\n🔍 Running end-to-end validation...")
    print(f"   Data source: {source}\n")

    client = TestClient(app)

    # --- Layer 1: Banking API ---

    # Check 1: get_balance
    check(
        'get_balance("user_marcus")',
        lambda: get_balance("user_marcus"),
    )

    # Check 2: get_upcoming_bills
    check(
        'get_upcoming_bills("user_marcus")',
        lambda: get_upcoming_bills("user_marcus"),
    )

    # Check 3: count_active_bnpls
    check(
        'count_active_bnpls("user_marcus")',
        lambda: count_active_bnpls("user_marcus"),
    )

    # --- Layer 2: Services ---

    # Check 4: assess_payment_risk returns dict
    check(
        'assess_payment_risk("user_marcus", 200.0)',
        lambda: assess_payment_risk("user_marcus", 200.0),
    )

    # Check 5: risk_level is a valid enum value
    def _check_risk_level():
        result = assess_payment_risk("user_marcus", 200.0)
        rl = result["risk_level"]
        # Must be a valid value (enum or string)
        val = rl.value if hasattr(rl, "value") else rl
        assert val in ("HIGH", "MEDIUM", "LOW"), f"Unexpected risk_level: {val}"
        return val
    check('assess_payment_risk → risk_level valid', _check_risk_level)

    # Check 6: calculate_bnpl_risk_score returns dict
    check(
        'calculate_bnpl_risk_score("user_marcus", 200.0, 4)',
        lambda: calculate_bnpl_risk_score("user_marcus", 200.0, 4),
    )

    # Check 7: BNPL score is 0–100
    def _check_bnpl_bounds():
        result = calculate_bnpl_risk_score("user_marcus", 200.0, 4)
        score = result["score"]
        assert 0 <= score <= 100, f"Score {score} out of bounds"
        return f"score {score}, {result['risk_level'].value if hasattr(result['risk_level'], 'value') else result['risk_level']}"
    check('calculate_bnpl_risk_score → score 0-100', _check_bnpl_bounds)

    # --- Layer 3: HTTP Endpoint ---

    # Check 8: Standard payment → 200
    def _check_standard_endpoint():
        resp = client.post("/api/authorize-payment", json={
            "user_id": "user_sarah",
            "amount": 50.0,
            "merchant": "COFFEE_SHOP",
            "payment_type": "standard",
        })
        assert resp.status_code == 200, f"HTTP {resp.status_code}: {resp.text}"
        data = resp.json()
        return f"{resp.status_code}, {data['warning']['cash_flow']['risk_level']}"
    check('POST /api/authorize-payment (standard)', _check_standard_endpoint)

    # Check 9: BNPL payment → 200 with BNPL data
    def _check_bnpl_endpoint():
        resp = client.post("/api/authorize-payment", json={
            "user_id": "user_marcus",
            "amount": 200.0,
            "merchant": "AMAZON",
            "payment_type": "bnpl",
            "num_payments": 4,
        })
        assert resp.status_code == 200, f"HTTP {resp.status_code}: {resp.text}"
        data = resp.json()
        bnpl = data["warning"]["bnpl"]
        assert bnpl is not None, "BNPL section missing from response"
        cf = data["warning"]["cash_flow"]["risk_level"]
        bl = bnpl["risk_level"]
        return f"200, {cf} + {bl}"
    check('POST /api/authorize-payment (bnpl)', _check_bnpl_endpoint)

    # Check 10: Unknown user → 404
    def _check_unknown_user():
        resp = client.post("/api/authorize-payment", json={
            "user_id": "user_nonexistent",
            "amount": 100.0,
            "merchant": "AMAZON",
            "payment_type": "standard",
        })
        assert resp.status_code == 404, f"Expected 404, got {resp.status_code}"
        return f"{resp.status_code}, {resp.json()['detail']}"
    check('POST /api/authorize-payment (unknown user)', _check_unknown_user)

    # --- Summary ---
    total = _passed + _failed
    print()
    if _failed == 0:
        print(f"   {total}/{total} checks passed ✅")
    else:
        print(f"   {_passed}/{total} checks passed ❌  ({_failed} failed)")

    sys.exit(0 if _failed == 0 else 1)


if __name__ == "__main__":
    main()
