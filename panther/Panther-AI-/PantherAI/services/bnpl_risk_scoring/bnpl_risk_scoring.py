from typing import TypedDict, List
from enum import Enum
import sys
from pathlib import Path

# Ensure we can import from the 'services' package
root_dir = Path(__file__).resolve().parent.parent.parent
sys.path.append(str(root_dir))

from services.banking.mock_api import (
    get_balance,
    get_upcoming_bills,
    get_active_bnpl_amount,
    count_active_bnpls,
    count_late_bnpl_payments,
)


class RiskLevel(str, Enum):
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"


class BNPLRiskScoreResponse(TypedDict):
    score: int
    risk_level: RiskLevel
    risk_factors: List[str]
    recommendation: str


import math


def calculate_bnpl_risk_score(
    user_id: str, amount: float, num_payments: int
) -> BNPLRiskScoreResponse:
    """
    Calculates a continuous risk score (0-100) and recommendation for a BNPL request based on cashflow and behavior.

    Args:
        user_id (str): The unique identifier for the user.
        amount (float): The requested BNPL principal amount. Must be strictly positive.
        num_payments (int): Number of months to repay. Must be between 1 and 36.

    Returns:
        BNPLRiskScoreResponse: A dictionary containing the numeric 'score', categorical 'risk_level', string 'recommendation', and a list of 'risk_factors' strings.

    Raises:
        ValueError: If amount <= 0 or num_payments is outside the [1, 36] range.
        Exception: Bubbles up underlying exceptions from the banking API (e.g., if user_id is invalid or network fails).
    """

    # 0. Input Validations (Fail-Fast)
    if amount <= 0:
        raise ValueError("Requested BNPL amount must be strictly positive.")
    if num_payments <= 0 or num_payments > 36:
        raise ValueError("Number of payments must be between 1 and 36.")

    # 1. Fetch User Data (Will raise ValueError if user_id is unknown, maintaining data integrity)
    balance = get_balance(user_id)
    bills = get_upcoming_bills(user_id)
    active_bnpls = count_active_bnpls(user_id)
    late_payments = count_late_bnpl_payments(user_id)
    active_bnpl_amount = get_active_bnpl_amount(user_id)

    risk_factors = []

    # 2. Early Exits (Fast Paths)
    # Instant rejection for bad behavior
    if late_payments > 0:
        risk_factors.append(f"You have {late_payments} late payment(s) on your record.")
        return {
            "score": 10,
            "risk_level": RiskLevel.HIGH,
            "risk_factors": risk_factors,
            "recommendation": "⚠️ Application denied due to recent late payments.",
        }

    # Instant rejection for negative cash flow without even simulating
    total_bills = sum(b.get("amount", 0.0) for b in bills)
    free_cash_flow = balance - total_bills - active_bnpl_amount

    new_monthly_payment = amount / max(1, num_payments)

    if free_cash_flow <= 0:
        risk_factors.append(
            "Your projected free cash flow is already negative before this purchase."
        )
        return {
            "score": 15,
            "risk_level": RiskLevel.HIGH,
            "risk_factors": risk_factors,
            "recommendation": "⚠️ This purchase is highly discouraged as it exceeds your current free cash flow.",
        }

    # 3. Calculate Affordability Score (out of 70)
    # The higher the ratio of the new payment to the free cash flow, the lower the score.
    # If the payment takes up > 50% of free cash, score drops to 0.
    ratio = new_monthly_payment / free_cash_flow

    if ratio >= 0.5:
        affordability_score = 0
        risk_factors.append(
            f"This BNPL would consume {(ratio*100):.0f}% of your free cash flow."
        )
    else:
        # scales linearly from 70 (ratio=0) to 0 (ratio=0.5)
        affordability_score = 70 * (1 - (ratio / 0.5))
        if ratio > 0.3:
            risk_factors.append(
                f"This takes up {(ratio*100):.0f}% of your available monthly cash."
            )

    # 4. Calculate Behavior Score (out of 30)
    # 0 BNPLs -> 30 pts, 1 BNPL -> 25 pts, 2 BNPLs -> 15 pts, 3+ BNPLs -> 0 pts
    behavior_score = 0
    if active_bnpls == 0:
        behavior_score = 30
    elif active_bnpls == 1:
        behavior_score = 25
    elif active_bnpls == 2:
        behavior_score = 15
        risk_factors.append("You already have 2 active BNPL plans.")
    else:
        behavior_score = 0
        risk_factors.append(
            f"You have {active_bnpls} active BNPL plans, increasing your debt burden."
        )

    # 5. Compile Final Score
    # ADR: We use a 0-100 continuous score instead of just calculating categorical tiers (Low/Medium/High)
    # because it makes threshold tuning easier later without changing the database schema or core APIs.
    total_score = math.floor(affordability_score + behavior_score)

    # 6. Determine Risk Level & Recommendation
    if total_score >= 70:
        risk_level = RiskLevel.LOW
        recommendation = "✅ Safe to proceed. This BNPL fits well within your budget."
        if not risk_factors:
            risk_factors.append("Excellent payment history and strong cash flow.")
    elif total_score >= 40:
        risk_level = RiskLevel.MEDIUM
        recommendation = (
            "⚠️ Proceed carefully. Make sure you can comfortably cover future payments."
        )
    else:
        risk_level = RiskLevel.HIGH
        recommendation = "🛑 High risk of defaulting. We recommend saving up for this purchase instead."

    return {
        "score": max(0, min(100, total_score)),  # Ensure bounds between 0 and 100
        "risk_level": risk_level,
        "risk_factors": risk_factors,
        "recommendation": recommendation,
    }
