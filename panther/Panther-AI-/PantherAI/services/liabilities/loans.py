"""
Installment loan analysis for student, auto, and personal loans.

All insights are descriptive analysis of the user's own loan data.
"""

from __future__ import annotations

import math
from datetime import date
from typing import Any

from .ingestion import get_liabilities_data


def analyze_loans(user_id: str) -> dict[str, Any]:
    liabilities = get_liabilities_data(user_id)
    raw_loans = (
        liabilities.get("student_loans", [])
        + liabilities.get("auto_loans", [])
        + liabilities.get("personal_loans", [])
    )
    loans = [_analyze_loan(loan) for loan in raw_loans]
    total_debt = round(sum(loan["outstanding_balance"] for loan in loans), 2)

    return {
        "total_loan_debt": total_debt,
        "loans": loans,
        "insight": _build_insight(loans),
    }


def _analyze_loan(loan: dict[str, Any]) -> dict[str, Any]:
    balance = float(loan.get("outstanding_balance") or 0.0)
    original = float(loan.get("original_balance") or balance)
    rate = float(loan.get("interest_rate") or 0.0)
    monthly_payment = float(loan.get("monthly_payment") or 0.0)
    payoff_date = _parse_date(loan.get("expected_payoff_date"))

    months_remaining = _months_remaining(balance, rate, monthly_payment, payoff_date)
    total_interest = _remaining_interest(balance, monthly_payment, months_remaining)

    return {
        "account_id": loan["account_id"],
        "loan_type": _loan_type(loan.get("loan_type")),
        "outstanding_balance": round(balance, 2),
        "original_balance": round(original, 2),
        "interest_rate": round(rate, 2),
        "monthly_payment": round(monthly_payment, 2),
        "payoff_date": payoff_date.isoformat() if payoff_date else None,
        "months_remaining": months_remaining,
        "total_remaining_interest": total_interest,
        "percent_paid_off": _percent_paid_off(balance, original),
        "status": _status(loan.get("loan_status"), balance),
    }


def _months_remaining(
    balance: float,
    rate: float,
    monthly_payment: float,
    payoff_date: date | None,
) -> int:
    if balance <= 0:
        return 0
    if payoff_date:
        return max(
            0,
            (payoff_date.year - date.today().year) * 12
            + payoff_date.month
            - date.today().month,
        )
    if monthly_payment <= 0:
        return 9999

    monthly_rate = rate / 100 / 12
    if monthly_rate <= 0:
        return math.ceil(balance / monthly_payment)
    if monthly_payment <= balance * monthly_rate:
        return 9999

    months = -math.log(1 - (balance * monthly_rate / monthly_payment)) / math.log(
        1 + monthly_rate
    )
    return max(0, math.ceil(months))


def _remaining_interest(
    balance: float, monthly_payment: float, months_remaining: int
) -> float:
    if months_remaining >= 9999:
        return 0.0
    return round(max(0.0, monthly_payment * months_remaining - balance), 2)


def _percent_paid_off(balance: float, original: float) -> float:
    if original <= 0:
        return 100.0 if balance <= 0 else 0.0
    return round(max(0.0, min(1.0, (original - balance) / original)), 4)


def _status(raw_status: Any, balance: float) -> str:
    if balance <= 0:
        return "PAID_OFF"
    normalized = str(raw_status or "CURRENT").upper()
    if "LATE" in normalized or "DELINQUENT" in normalized or "PAST" in normalized:
        return "LATE"
    return "CURRENT"


def _loan_type(value: Any) -> str:
    normalized = str(value or "OTHER").upper()
    if normalized in {"STUDENT", "AUTO", "PERSONAL"}:
        return normalized
    return "OTHER"


def _build_insight(loans: list[dict[str, Any]]) -> str:
    if not loans:
        return "No active installment loans are present in the current liability data."

    largest = max(loans, key=lambda loan: loan["outstanding_balance"])
    paid_pct = round(largest["percent_paid_off"] * 100, 1)
    return (
        f"You have {largest['months_remaining']} months remaining on your "
        f"{largest['loan_type'].lower()} loan at {largest['interest_rate']}% APR. "
        f"You've paid off {paid_pct}% of the original balance."
    )


def _parse_date(value: Any) -> date | None:
    if not value:
        return None
    return date.fromisoformat(str(value)[:10])
