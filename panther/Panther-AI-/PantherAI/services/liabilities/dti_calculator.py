"""
Debt-to-income ratio calculation.

DTI output is descriptive analysis of the user's own liability and income data.
"""

from __future__ import annotations

from statistics import median
from typing import Any

from services.banking.mock_api import get_transactions

from .ingestion import get_liabilities_data


def calculate_dti(user_id: str) -> dict[str, Any]:
    liabilities = get_liabilities_data(user_id)

    credit_cards = sum(
        float(card.get("minimum_payment") or 0.0)
        for card in liabilities.get("credit_cards", [])
    )
    loans = sum(
        float(loan.get("monthly_payment") or 0.0)
        for loan in (
            liabilities.get("student_loans", [])
            + liabilities.get("auto_loans", [])
            + liabilities.get("personal_loans", [])
        )
    )
    mortgage = sum(
        float(item.get("monthly_payment") or 0.0)
        for item in liabilities.get("mortgages", [])
    )

    monthly_debt = round(credit_cards + loans + mortgage, 2)
    income = round(_gross_monthly_income(user_id, liabilities), 2)
    ratio = round(monthly_debt / income, 4) if income > 0 else 0.0
    status = _dti_status(ratio)

    return {
        "monthly_debt_payments": monthly_debt,
        "monthly_gross_income": income,
        "dti_ratio": ratio,
        "dti_status": status,
        "breakdown": {
            "credit_cards": round(credit_cards, 2),
            "loans": round(loans, 2),
            "mortgage": round(mortgage, 2),
        },
        "insight": _build_insight(ratio, status),
    }


def _gross_monthly_income(user_id: str, liabilities: dict[str, Any]) -> float:
    explicit = float(liabilities.get("gross_monthly_income") or 0.0)
    if explicit > 0:
        return explicit

    try:
        txns = get_transactions(user_id, days_back=370)
    except Exception:
        return 0.0

    incomes = [float(t["amount"]) for t in txns if float(t.get("amount") or 0.0) > 0]
    return float(median(incomes)) if incomes else 0.0


def _dti_status(ratio: float) -> str:
    if ratio > 0.50:
        return "CRITICAL"
    if ratio >= 0.36:
        return "HIGH"
    if ratio >= 0.28:
        return "ELEVATED"
    return "HEALTHY"


def _build_insight(ratio: float, status: str) -> str:
    pct = round(ratio * 100, 1)
    return (
        f"Your monthly debt payments are {pct}% of gross monthly income, "
        f"which falls in the {status.lower()} DTI range."
    )
