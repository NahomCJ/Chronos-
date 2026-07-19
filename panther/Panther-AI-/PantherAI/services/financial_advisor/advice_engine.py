"""
services/financial_advisor/advice_engine.py
=============================================
Combines expense categorization, gym/supplement flags, liability analysis,
and the rough tax estimate into a single prioritized, tailored advice list.

Pure function, no I/O — takes the outputs of the other financial_advisor
modules and produces human-readable recommendations. Advice is ordered by
rough financial impact (largest dollar effect first).
"""

from __future__ import annotations

from typing import Any

TARGET_SAVINGS_RATE_PCT = 20.0
HOUSING_COST_RATIO_THRESHOLD_PCT = 30.0  # the classic "front-end ratio" affordability rule
DISCRETIONARY_SUBCATEGORIES = {
    "sub_restaurants_bars", "sub_delivery", "sub_fitness_gym", "sub_supplementation",
    "sub_wellness_beauty", "sub_subscriptions", "sub_events_culture", "sub_hobbies",
    "sub_fashion", "sub_electronics",
}


def build_advice(
    *,
    monthly_income: float,
    expense_summary: dict[str, Any],
    gym_result: dict[str, Any],
    supplement_result: dict[str, Any],
    liability_result: dict[str, Any],
    tax_estimate: dict[str, Any],
    crypto_result: dict[str, Any] | None = None,
    nft_result: dict[str, Any] | None = None,
) -> list[dict[str, Any]]:
    advice: list[dict[str, Any]] = []

    total_expenses = expense_summary["total_monthly_expenses"]
    total_debt_payments = liability_result["total_monthly_payments"]
    leftover = round(monthly_income - total_expenses - total_debt_payments, 2)
    savings_rate_pct = round((leftover / monthly_income) * 100, 2) if monthly_income > 0 else 0.0

    if leftover < 0:
        advice.append(
            {
                "priority": 1,
                "category": "cash_flow",
                "impact_monthly": abs(leftover),
                "advice": (
                    f"Spending plus debt payments exceed income by ${abs(leftover):,.2f}/mo. "
                    "This is the first thing to fix — look at the largest discretionary "
                    "categories below before anything else."
                ),
            }
        )
    elif savings_rate_pct < TARGET_SAVINGS_RATE_PCT:
        gap_pct = TARGET_SAVINGS_RATE_PCT - savings_rate_pct
        gap_dollars = round(monthly_income * gap_pct / 100, 2)
        advice.append(
            {
                "priority": 2,
                "category": "savings_rate",
                "impact_monthly": gap_dollars,
                "advice": (
                    f"Current savings rate is {savings_rate_pct:.1f}% of income "
                    f"(${leftover:,.2f}/mo leftover). Reaching a {TARGET_SAVINGS_RATE_PCT:.0f}% "
                    f"target would mean finding about ${gap_dollars:,.2f}/mo more, "
                    "either from the discretionary categories below or by increasing income."
                ),
            }
        )
    else:
        advice.append(
            {
                "priority": 5,
                "category": "savings_rate",
                "impact_monthly": leftover,
                "advice": (
                    f"Savings rate is {savings_rate_pct:.1f}% of income — at or above the "
                    f"{TARGET_SAVINGS_RATE_PCT:.0f}% target. Keep this up."
                ),
            }
        )

    for flag in liability_result["flags"]:
        advice.append(
            {
                "priority": 1 if flag["type"] == "HIGH_INTEREST_DEBT" else 2,
                "category": "liabilities",
                "impact_monthly": total_debt_payments,
                "advice": flag["message"],
            }
        )

    by_sub = {row["subcategory_id"]: row["monthly_total"] for row in expense_summary["by_subcategory"]}
    housing_expense_side = (
        by_sub.get("sub_rent_mortgage", 0.0) + by_sub.get("sub_utility_bills", 0.0) + by_sub.get("sub_insurance", 0.0)
    )
    mortgage_debt_side = sum(
        d["monthly_payment"] for d in liability_result["debts"] if d["type"] == "mortgage"
    ) + by_sub.get("sub_utility_bills", 0.0) + by_sub.get("sub_insurance", 0.0)
    housing_cost = max(housing_expense_side, mortgage_debt_side)
    housing_cost_ratio_pct = round((housing_cost / monthly_income) * 100, 1) if monthly_income > 0 else 0.0
    if housing_cost_ratio_pct >= HOUSING_COST_RATIO_THRESHOLD_PCT:
        advice.append(
            {
                "priority": 2,
                "category": "housing_bills",
                "impact_monthly": round(housing_cost, 2),
                "advice": (
                    f"Housing + utilities + insurance is {housing_cost_ratio_pct:.1f}% of monthly income "
                    f"(${housing_cost:,.2f}/mo) — above the classic 30% affordability guideline."
                ),
            }
        )

    for flag in gym_result.get("flags", []):
        advice.append(
            {
                "priority": 3,
                "category": "gym_membership",
                "impact_monthly": gym_result["total_monthly_cost"],
                "advice": flag["message"],
            }
        )

    for flag in supplement_result.get("flags", []):
        advice.append(
            {
                "priority": 3,
                "category": "supplements",
                "impact_monthly": supplement_result["total_monthly_cost"],
                "advice": flag["message"],
            }
        )

    if crypto_result and crypto_result.get("has_crypto_activity"):
        for flag in crypto_result.get("flags", []):
            advice.append(
                {
                    "priority": 4,
                    "category": "crypto",
                    "impact_monthly": crypto_result.get("total_fees_paid", 0.0),
                    "advice": flag["message"],
                }
            )

    if nft_result and nft_result.get("has_nft_activity"):
        for flag in nft_result.get("flags", []):
            advice.append(
                {
                    "priority": 4,
                    "category": "nft",
                    "impact_monthly": nft_result.get("total_gas_fees", 0.0),
                    "advice": flag["message"],
                }
            )

    top_discretionary = [
        row for row in expense_summary["by_subcategory"]
        if row["subcategory_id"] in DISCRETIONARY_SUBCATEGORIES and row["monthly_total"] > 0
    ][:3]
    if top_discretionary:
        breakdown = ", ".join(
            f"{row['subcategory_name']} (${row['monthly_total']:,.2f}/mo)" for row in top_discretionary
        )
        advice.append(
            {
                "priority": 4,
                "category": "discretionary_spending",
                "impact_monthly": round(sum(r["monthly_total"] for r in top_discretionary), 2),
                "advice": f"Top discretionary categories: {breakdown}. These are the easiest places to trim if cash flow is tight.",
            }
        )

    advice.append(
        {
            "priority": 6,
            "category": "tax",
            "impact_monthly": tax_estimate["estimated_monthly_tax"],
            "advice": (
                f"Rough estimate: effective tax rate ~{tax_estimate['effective_tax_rate_pct']:.1f}%, "
                f"marginal rate {tax_estimate['marginal_tax_rate_pct']:.0f}%. {tax_estimate['disclaimer']}"
            ),
        }
    )

    advice.sort(key=lambda a: a["priority"])
    return advice
