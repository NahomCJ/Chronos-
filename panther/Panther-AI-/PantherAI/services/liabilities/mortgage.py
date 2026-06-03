"""
Mortgage liability analysis.

Mortgage insights include the required FCA redirect and use original principal
as an LTV proxy because current market value is not available in Plaid.
"""

from __future__ import annotations

from typing import Any

from .ingestion import get_liabilities_data

FCA_REDIRECT = "Speak to an FCA-authorized mortgage advisor for personalized guidance."


def analyze_mortgage(user_id: str) -> dict[str, Any]:
    liabilities = get_liabilities_data(user_id)
    mortgages = liabilities.get("mortgages", [])
    if not mortgages:
        return {
            "has_mortgage": False,
            "outstanding_balance": 0.0,
            "original_principal": 0.0,
            "ltv_ratio": 0.0,
            "interest_rate": 0.0,
            "monthly_payment": 0.0,
            "has_pmi": False,
            "pmi_removal_eligible": False,
            "payoff_date": None,
            "insight": f"No mortgage is present in the current liability data. {FCA_REDIRECT}",
        }

    mortgage = mortgages[0]
    outstanding = float(mortgage.get("outstanding_balance") or 0.0)
    original = float(mortgage.get("original_principal") or 0.0)
    ltv_ratio = round(outstanding / original, 4) if original > 0 else 0.0
    has_pmi = bool(mortgage.get("has_pmi"))
    eligible = has_pmi and ltv_ratio < 0.80

    return {
        "has_mortgage": True,
        "outstanding_balance": round(outstanding, 2),
        "original_principal": round(original, 2),
        "ltv_ratio": ltv_ratio,
        "interest_rate": round(float(mortgage.get("interest_rate") or 0.0), 2),
        "monthly_payment": round(float(mortgage.get("monthly_payment") or 0.0), 2),
        "has_pmi": has_pmi,
        "pmi_removal_eligible": eligible,
        "payoff_date": mortgage.get("payoff_date"),
        "insight": _build_insight(ltv_ratio, has_pmi, eligible),
    }


def _build_insight(ltv_ratio: float, has_pmi: bool, eligible: bool) -> str:
    pct = round(ltv_ratio * 100, 1)
    if eligible:
        base = (
            "Your estimated LTV is below 80% based on your original purchase price — "
            "you may be eligible to request PMI removal. Speak to your mortgage lender "
            "to confirm with a current property valuation."
        )
    elif has_pmi:
        base = f"Your estimated LTV is {pct}% based on original principal, and PMI is present in the mortgage data."
    else:
        base = f"Your estimated LTV is {pct}% based on original principal, and PMI is not present in the mortgage data."
    return f"{base} {FCA_REDIRECT}"
