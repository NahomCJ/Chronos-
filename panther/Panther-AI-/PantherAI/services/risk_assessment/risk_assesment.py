from typing import TypedDict, List
from enum import Enum


class RiskLevel(str, Enum):
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"


class Bill(TypedDict):
    name: str
    amount: float
    due_in_days: int


class UserData(TypedDict):
    balance: float
    bills: List[Bill]


class RiskAssessmentResponse(TypedDict):
    is_risky: bool
    risk_level: RiskLevel
    warning_message: str
    projected_balance: float
    confidence: float


import sys  # noqa: E402
from pathlib import Path  # noqa: E402

# Ensure we can import from the 'services' package
root_dir = Path(__file__).resolve().parent.parent.parent
sys.path.append(str(root_dir))

from services.banking.mock_api import (  # noqa: E402
    get_balance,
    get_upcoming_bills,
    get_active_bnpl_amount,
)


def assess_payment_risk(user_id: str, amount: float) -> RiskAssessmentResponse:
    """
    Determines if a payment endangers the user's ability to cover upcoming bills.

    Args:
        user_id (str): Unique user identifier. Must exist in the banking data source.
        amount (float): Payment amount in USD.

    Returns:
        RiskAssessmentResponse: {
            "is_risky": bool,
            "risk_level": RiskLevel ("HIGH" | "MEDIUM" | "LOW"),
            "warning_message": str,
            "projected_balance": float,
            "confidence": float
        }

    Raises:
        ValueError: If user_id is not found in the banking data source.
    """
    balance = get_balance(user_id)
    bills = get_upcoming_bills(user_id)
    active_bnpl_amount = get_active_bnpl_amount(user_id)

    # 1. Fetch User Data (Will raise ValueError if user_id is unknown)

    total_bills = sum(bill["amount"] for bill in bills) + active_bnpl_amount

    if amount > balance:
        return {
            "is_risky": True,
            "risk_level": RiskLevel.HIGH,
            "warning_message": f"⚠️ Insufficient funds. This ${amount:,.2f} purchase exceeds your ${balance:,.2f} balance, and you have ${total_bills:,.2f} in upcoming obligations.",
            "projected_balance": float(f"{balance - amount - total_bills:.2f}"),
            "confidence": 1.0,
        }
    free_liquidity = balance - total_bills
    projected_balance = free_liquidity - amount

    # ADR: Dynamic buffer = max($100, 15% of obligations). The $100 floor
    # prevents low-bill users from getting a dangerously small buffer.
    buffer_seguridad = max(100.0, total_bills * 0.15)

    if free_liquidity > 0:
        liquidity_ratio = (amount / free_liquidity) * 100
    else:
        liquidity_ratio = 100.0

    if projected_balance < 0:
        biggest_bill = max(bills, key=lambda b: b["amount"]) if bills else None
        if biggest_bill:
            warning_message = f"⚠️ Your {biggest_bill['name']} of ${biggest_bill['amount']:,.2f} is due in {biggest_bill['due_in_days']} days. This payment will leave you with a negative balance of -${abs(projected_balance):,.2f}."
        else:
            warning_message = f"⚠️ This payment will leave you with a negative balance of -${abs(projected_balance):,.2f}."

        return {
            "is_risky": True,
            "risk_level": RiskLevel.HIGH,
            "warning_message": warning_message,
            "projected_balance": float(f"{projected_balance:.2f}"),
            "confidence": 1.0,
        }

    # ADR: 40% liquidity ratio triggers MEDIUM even if buffer is fine — a single
    # purchase consuming 40%+ of free cash signals concentration risk.
    elif projected_balance < buffer_seguridad or liquidity_ratio >= 40.0:
        warning_message = f"⚠️ This purchase absorbs {liquidity_ratio:.0f}% of your free liquidity. You will only have ${projected_balance:,.2f} left for emergencies. Are you sure you want to proceed?"
        return {
            "is_risky": True,
            "risk_level": RiskLevel.MEDIUM,
            "warning_message": warning_message,
            "projected_balance": float(f"{projected_balance:.2f}"),
            "confidence": 1.0,
        }

    else:
        return {
            "is_risky": False,
            "risk_level": RiskLevel.LOW,
            "warning_message": "✅ Safe to proceed. This payment is well within your budget.",
            "projected_balance": float(f"{projected_balance:.2f}"),
            "confidence": 1.0,
        }
