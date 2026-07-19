"""UK tax-awareness pattern flags.

This module does not calculate tax owed. It only surfaces patterns that may be
worth checking with HMRC or a qualified tax advisor.
"""

from __future__ import annotations

import os
from datetime import date
from typing import Any

from services.income.ingestion import (
    bracket_annual_income,
    get_income_data,
    normalize_user_id,
)

ADVISOR_PROMPT = "You may want to speak to a qualified tax advisor or check HMRC directly."
HIGHER_RATE_THRESHOLD = 50_270.0
CGT_ANNUAL_EXEMPT_AMOUNT = 3_000.0
CGT_APPROACHING_RATIO = 0.8
_LOCAL_INVESTMENT_GAINS = {
    "user_marcus": 2650.0,
    "user_sarah": 2650.0,
    "user_bob": 1200.0,
}


def get_tax_awareness(user_id: str) -> dict[str, Any]:
    normalized_user_id = normalize_user_id(user_id)
    income_data = get_income_data(normalized_user_id)
    annual_income = round(float(income_data.get("estimated_monthly_income") or 0.0) * 12, 2)
    income_sources = _income_sources(income_data)
    flags = _tax_flags(annual_income, income_data, income_sources, normalized_user_id)

    return {
        "user_id": normalized_user_id,
        "estimated_annual_income": annual_income,
        "estimated_annual_income_range": bracket_annual_income(annual_income),
        "income_sources": income_sources,
        "tax_flags": flags,
        "tax_year_end_days": _tax_year_end_days(date.today()),
        "insight": _insight(flags),
    }


def _income_sources(data: dict[str, Any]) -> list[dict[str, Any]]:
    return [
        {
            "source_type": source.get("source_type"),
            "income_category": source.get("income_category"),
            "pay_frequency": source.get("pay_frequency"),
            "monthly_income_range": source.get("monthly_income_range"),
        }
        for source in data.get("income_sources", [])
    ]


def _tax_flags(
    annual_income: float,
    income_data: dict[str, Any],
    income_sources: list[dict[str, Any]],
    user_id: str,
) -> list[dict[str, str]]:
    flags: list[dict[str, str]] = []
    if annual_income > HIGHER_RATE_THRESHOLD:
        flags.append(
            _flag(
                "HIGHER_RATE_BAND",
                "Your estimated annual income pattern is above the UK higher-rate threshold.",
            )
        )

    categories = {
        str(source.get("income_category") or "").upper() for source in income_sources
    }
    if categories & {"FREELANCE", "GIG_ECONOMY", "SIDE_HUSTLE", "CONTRACT"}:
        flags.append(
            _flag(
                "SELF_EMPLOYMENT_INCOME",
                "Your income pattern includes freelance, gig, or self-employment style income.",
            )
        )

    if len(income_sources) >= 2:
        flags.append(
            _flag(
                "MULTIPLE_INCOME_SOURCES",
                "Your income pattern includes more than one income source.",
            )
        )

    if _capital_gains_approaching(user_id):
        flags.append(
            _flag(
                "CAPITAL_GAINS_APPROACHING",
                "Your investment gains pattern is approaching the annual capital gains allowance.",
            )
        )

    if not flags and income_data.get("income_type") == "UNKNOWN":
        return []
    return flags


def _flag(flag_type: str, message: str) -> dict[str, str]:
    return {
        "flag_type": flag_type,
        "message": f"{message} {ADVISOR_PROMPT}",
        "advisor_prompt": ADVISOR_PROMPT,
    }


def _capital_gains_approaching(user_id: str) -> bool:
    if user_id in _LOCAL_INVESTMENT_GAINS:
        return (
            _LOCAL_INVESTMENT_GAINS[user_id]
            >= CGT_ANNUAL_EXEMPT_AMOUNT * CGT_APPROACHING_RATIO
        )
    if not os.getenv("BLOCKHUB_URL"):
        return False

    try:
        from services.blockhub.connector import get_crypto_pnl

        pnl = get_crypto_pnl(user_id)
    except Exception:
        return False

    values = [
        abs(float(pnl.get("realized_pnl") or 0.0)),
        abs(float(pnl.get("unrealized_pnl") or 0.0)),
        abs(float(pnl.get("total_pnl_usd") or 0.0)),
    ]
    return max(values, default=0.0) >= CGT_ANNUAL_EXEMPT_AMOUNT * CGT_APPROACHING_RATIO


def _tax_year_end_days(today: date) -> int:
    tax_year_end = date(today.year, 4, 5)
    if today > tax_year_end:
        tax_year_end = date(today.year + 1, 4, 5)
    return (tax_year_end - today).days


def _insight(flags: list[dict[str, str]]) -> str:
    if not flags:
        return f"No tax-awareness flags were detected. {ADVISOR_PROMPT}"
    return f"{len(flags)} tax-awareness flag(s) were detected. {ADVISOR_PROMPT}"
