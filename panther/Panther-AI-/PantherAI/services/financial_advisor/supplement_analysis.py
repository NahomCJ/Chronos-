"""
services/financial_advisor/supplement_analysis.py
===================================================
Supplement/vitamin/sports-nutrition spending analysis.

Only flags this spend when it's material relative to income (default: >=1.5%
of monthly income), to avoid noisy advice over a single $20 vitamin purchase.
"""

from __future__ import annotations

from typing import Any

from services.financial_advisor.categorizer import SUB_SUPPLEMENTATION

DEFAULT_MATERIALITY_THRESHOLD_PCT = 1.5  # percent of monthly income


def analyze_supplement_spending(
    transactions: list[dict[str, Any]],
    monthly_income: float,
    threshold_pct: float = DEFAULT_MATERIALITY_THRESHOLD_PCT,
) -> dict[str, Any]:
    supplement_txns = [t for t in transactions if t["subcategory_id"] == SUB_SUPPLEMENTATION]
    total_monthly = round(sum(t["monthly_amount"] for t in supplement_txns), 2)

    pct_of_income = round((total_monthly / monthly_income) * 100, 2) if monthly_income > 0 else 0.0
    is_material = pct_of_income >= threshold_pct

    result: dict[str, Any] = {
        "has_supplement_spending": bool(supplement_txns),
        "merchants": sorted({t["merchant"] for t in supplement_txns}),
        "total_monthly_cost": total_monthly,
        "pct_of_monthly_income": pct_of_income,
        "materiality_threshold_pct": threshold_pct,
        "is_material": is_material,
        "flags": [],
    }

    if is_material:
        result["flags"].append(
            {
                "type": "MATERIAL_SUPPLEMENT_SPEND",
                "message": (
                    f"Supplement/vitamin spending is ${total_monthly:,.2f}/mo "
                    f"({pct_of_income:.1f}% of monthly income) — above the "
                    f"{threshold_pct:.1f}% materiality threshold. Worth checking "
                    "cost-per-serving vs. bulk/generic alternatives, or whether "
                    "some of it could be replaced with whole-food sources."
                ),
            }
        )

    return result
