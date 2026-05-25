import sys
import pytest
from pathlib import Path

root_dir = Path(__file__).resolve().parent.parent
sys.path.append(str(root_dir))

from services.risk_assessment.risk_assesment import assess_payment_risk, RiskLevel

# ==============================================================================
# 1. EXCEPTION TESTING (FAIL-FAST)
# ==============================================================================


def test_validation_unknown_user():
    with pytest.raises(ValueError, match="Unknown user"):
        assess_payment_risk("user_ghost", amount=100.0)


# ==============================================================================
# 2. EQUIVALENCE CLASSES & BOUNDARY TESTING
# ==============================================================================


@pytest.mark.parametrize(
    "user_id, amount, expected_risk_level, expected_projected, expected_message_type",
    [
        # Amount > Balance -> Immediate HIGH Risk
        ("user_pending_payroll", 10.0, RiskLevel.HIGH, -10.0, "Insufficient funds"),
        # Negative free cashflow -> Immediate HIGH Risk
        ("user_marcus", 200.0, RiskLevel.HIGH, -295.99, "negative balance"),
        ("user_overleveraged", 100.0, RiskLevel.HIGH, -600.0, "negative balance"),
        ("user_investor", 50.0, RiskLevel.HIGH, -1900.0, "negative balance"),
        # Liquidity Ratio exactly > 40% -> MEDIUM Risk
        # Sarah: Free liquidity = 3800. Amount 1600. Ratio = 42%. Proj = 2200.
        ("user_sarah", 1600.0, RiskLevel.MEDIUM, 2200.0, "absorbs"),
        # Projected < 15% Buffer -> MEDIUM Risk
        # Bob: Free = 350. Buffer = 1850*0.15 = 277.5. Amount 100 -> Proj 250.
        ("user_bob", 100.0, RiskLevel.MEDIUM, 250.0, "absorbs"),
        # Safe -> LOW Risk
        # Bob: Free = 350. Amount 50 -> Proj 300 (> buffer). Ratio 14% (< 40%).
        ("user_bob", 50.0, RiskLevel.LOW, 300.0, "Safe to proceed"),
        # Perfect User -> LOW Risk
        # Free = 99000. Amount 5000.
        ("user_perfect", 5000.0, RiskLevel.LOW, 94000.0, "Safe to proceed"),
    ],
)
def test_risk_assessment_matrix(
    user_id, amount, expected_risk_level, expected_projected, expected_message_type
):
    res = assess_payment_risk(user_id, amount)

    assert res["is_risky"] == (
        expected_risk_level in [RiskLevel.HIGH, RiskLevel.MEDIUM]
    ), f"Incorrect is_risky for {user_id}"

    assert (
        res["risk_level"] == expected_risk_level
    ), f"Expected {expected_risk_level} but got {res['risk_level']} for {user_id}"

    assert (
        res["projected_balance"] == pytest.approx(expected_projected, rel=1e-2)
    ), f"Expected proj {expected_projected} but got {res['projected_balance']} for {user_id}"

    assert (
        expected_message_type in res["warning_message"]
    ), f"Expected message type '{expected_message_type}' not found in '{res['warning_message']}'"
