import sys
import pytest
from pathlib import Path

root_dir = Path(__file__).resolve().parent.parent
sys.path.append(str(root_dir))

from services.bnpl_risk_scoring.bnpl_risk_scoring import (
    calculate_bnpl_risk_score,
    RiskLevel,
)

# ==============================================================================
# 1. EXCEPTION & VALIDATION TESTING (FAIL-FAST)
# ==============================================================================


def test_validation_negative_amount():
    with pytest.raises(ValueError, match="strictly positive"):
        calculate_bnpl_risk_score("user_perfect", amount=0, num_payments=4)

    with pytest.raises(ValueError, match="strictly positive"):
        calculate_bnpl_risk_score("user_perfect", amount=-100.0, num_payments=4)


def test_validation_invalid_payments():
    with pytest.raises(ValueError, match="1 and 36"):
        calculate_bnpl_risk_score("user_perfect", amount=100.0, num_payments=0)

    with pytest.raises(ValueError, match="1 and 36"):
        calculate_bnpl_risk_score("user_perfect", amount=100.0, num_payments=40)


def test_validation_unknown_user():
    with pytest.raises(ValueError, match="Unknown user"):
        calculate_bnpl_risk_score("user_ghost", amount=100.0, num_payments=4)


# ==============================================================================
# 2. EQUIVALENCE CLASSES & BOUNDARY TESTING (USING REAL MOCK DB)
# ==============================================================================


@pytest.mark.parametrize(
    "user_id, amount, num_payments, expected_min_score, expected_max_score, expected_risk_level",
    [
        # Perfect user: Massively solvent, no debt. Score should be ~100.
        ("user_perfect", 1000.0, 4, 98, 100, RiskLevel.LOW),
        # Behavior crash: User has 4 BNPLs -> Behavior score = 0.
        # Even with infinite money, score maxes at 70.
        # In debt spiral, free cash flow = 50k - 5k - 20k = 25k. 25k is highly solvent.
        # Affordability: 200/25k is tiny, ~70 score. Total ~70.
        # But wait! user_debt_spiral actually hits 70 max, which is barely LOW or just MEDIUM.
        # Let's request an amount of 50k over 4 months -> 12.5k. Ratio = 12.5/25 = 0.5 -> 0.
        # Score = 0 + 0 = 0
        ("user_debt_spiral", 50000.0, 4, 0, 15, RiskLevel.HIGH),
        # Borderline Low: user_borderline_low (Balance 3k, bills 1k). Free cash = 2000.
        # Request 1000 over 4 payments (250/mo). Ratio = 250/2000 = 0.125
        # Affordability = 70 * (1 - 0.125/0.5) = 70 * 0.75 = 52.5
        # Behavior (0 bnpls) = 30
        # Total = 82 (LOW)
        ("user_borderline_low", 1000.0, 4, 80, 85, RiskLevel.LOW),
        # Borderline Medium: user_borderline_medium (Balance 2k, bills 1k). Free cash = 1000.
        # Request 1000 over 4 payments = 250/mo. Ratio = 250/1000 = 0.25
        # Affordability = 70 * 0.5 = 35
        # Behavior (1 bnpl) = 25
        # Total = 60 (MEDIUM)
        ("user_borderline_medium", 1000.0, 4, 58, 62, RiskLevel.MEDIUM),
        # Instant Rejects:
        # Marcos: already over-leveraged before BNPL. Instant fail.
        ("user_marcus", 100.0, 4, 15, 15, RiskLevel.HIGH),
        # Bob: Late payments on record. Instant fail.
        ("user_bob", 100.0, 4, 10, 10, RiskLevel.HIGH),
    ],
)
def test_bnpl_scoring_matrix(
    user_id,
    amount,
    num_payments,
    expected_min_score,
    expected_max_score,
    expected_risk_level,
):
    res = calculate_bnpl_risk_score(user_id, amount, num_payments)

    assert (
        expected_min_score <= res["score"] <= expected_max_score
    ), f"Score {res['score']} out of expected bounds [{expected_min_score}, {expected_max_score}] for {user_id}"

    assert (
        res["risk_level"] == expected_risk_level
    ), f"Expected {expected_risk_level} but got {res['risk_level']} for {user_id}"
