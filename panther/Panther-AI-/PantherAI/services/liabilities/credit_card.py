"""
Credit card liability analysis.

Insights describe the user's own credit card data only. They avoid directive
language, lender recommendations, and debt product recommendations.
"""

from __future__ import annotations

import math
from datetime import date
from typing import Any

from .ingestion import get_liabilities_data

DIRECTIVE_TERMS = {
    "you should",
    "you need to",
    "consider",
    "recommend",
    "balance transfer",
    "consolidate",
    "refinance",
    "switch",
    "apply for",
}


def analyze_credit_cards(user_id: str) -> dict[str, Any]:
    liabilities = get_liabilities_data(user_id)
    cards = liabilities.get("credit_cards", [])

    total_debt = round(sum(float(card.get("balance") or 0.0) for card in cards), 2)
    total_limit = round(
        sum(float(card.get("credit_limit") or 0.0) for card in cards), 2
    )
    utilization_rate = _ratio(total_debt, total_limit)
    utilization_status = _utilization_status(utilization_rate)

    analyzed_cards = [_analyze_card(card) for card in cards]
    highest_apr_card = None
    if analyzed_cards:
        highest_apr_card = max(analyzed_cards, key=lambda card: card["apr"])[
            "account_id"
        ]

    return {
        "total_credit_card_debt": total_debt,
        "total_credit_limit": total_limit,
        "utilization_rate": utilization_rate,
        "utilization_status": utilization_status,
        "cards": analyzed_cards,
        "highest_apr_card": highest_apr_card,
        "insight": _build_insight(utilization_rate, utilization_status),
    }


def contains_directive_language(text: str) -> bool:
    lower = text.lower()
    return any(term in lower for term in DIRECTIVE_TERMS)


def _analyze_card(card: dict[str, Any]) -> dict[str, Any]:
    balance = float(card.get("balance") or 0.0)
    credit_limit = float(card.get("credit_limit") or 0.0)
    apr = float(card.get("apr") or 0.0)
    minimum_payment = float(card.get("minimum_payment") or 0.0)
    due = _parse_date(card.get("next_payment_due"))
    days_until_due = (due - date.today()).days if due else None

    minimum = _payoff_projection(balance, apr, minimum_payment)
    aggressive = _payoff_projection(balance, apr, minimum_payment * 3)

    return {
        "account_id": card["account_id"],
        "balance": round(balance, 2),
        "credit_limit": round(credit_limit, 2),
        "utilization": _ratio(balance, credit_limit),
        "apr": round(apr, 2),
        "minimum_payment": round(minimum_payment, 2),
        "next_payment_due": due.isoformat() if due else None,
        "days_until_due": days_until_due,
        "payoff_months_minimum": minimum["months"],
        "payoff_months_aggressive": aggressive["months"],
        "total_interest_minimum": minimum["interest"],
        "status": _card_status(days_until_due),
    }


def _payoff_projection(
    balance: float, apr: float, monthly_payment: float
) -> dict[str, Any]:
    if balance <= 0:
        return {"months": 0, "interest": 0.0}
    if monthly_payment <= 0:
        return {"months": math.inf, "interest": math.inf}

    monthly_rate = apr / 100 / 12
    remaining = balance
    total_interest = 0.0
    months = 0

    while remaining > 0.01 and months < 600:
        interest = remaining * monthly_rate
        if monthly_payment <= interest and remaining > monthly_payment:
            return {"months": math.inf, "interest": math.inf}
        total_interest += interest
        remaining = max(0.0, remaining + interest - monthly_payment)
        months += 1

    return {
        "months": months if months < 600 else math.inf,
        "interest": round(total_interest, 2) if months < 600 else math.inf,
    }


def _ratio(numerator: float, denominator: float) -> float:
    if denominator <= 0:
        return 0.0
    return round(numerator / denominator, 4)


def _utilization_status(utilization_rate: float) -> str:
    if utilization_rate > 0.70:
        return "DANGER"
    if utilization_rate >= 0.30:
        return "WARNING"
    return "HEALTHY"


def _build_insight(utilization_rate: float, utilization_status: str) -> str:
    pct = round(utilization_rate * 100, 1)
    if utilization_status == "DANGER":
        return (
            f"Your overall credit card utilization is {pct}% — above the 70% "
            "level associated with severe credit score impact."
        )
    if utilization_status == "WARNING":
        return (
            f"Your overall credit card utilization is {pct}% — between the 30% "
            "and 70% levels commonly used to flag elevated utilization."
        )
    return (
        f"Your overall credit card utilization is {pct}% — below the 30% "
        "level commonly referenced in credit scoring models."
    )


def _card_status(days_until_due: int | None) -> str:
    if days_until_due is None:
        return "OK"
    if days_until_due < 0:
        return "OVERDUE"
    if days_until_due <= 7:
        return "DUE_SOON"
    return "OK"


def _parse_date(value: Any) -> date | None:
    if not value:
        return None
    return date.fromisoformat(str(value)[:10])
