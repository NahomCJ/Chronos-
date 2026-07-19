"""
services/financial_advisor/liability_analysis.py
==================================================
Debt/liability summary: total balances, monthly payment burden, DTI ratio,
and an avalanche-method payoff priority order (highest interest rate first).
"""

from __future__ import annotations

from typing import Any

HIGH_INTEREST_THRESHOLD_PCT = 15.0
PMI_LIKELY_LTV_THRESHOLD_PCT = 80.0
REFI_EQUITY_LTV_THRESHOLD_PCT = 60.0


def _dti_status(ratio: float) -> str:
    if ratio > 0.50:
        return "CRITICAL"
    if ratio >= 0.36:
        return "HIGH"
    if ratio >= 0.28:
        return "ELEVATED"
    return "HEALTHY"


def analyze_liabilities(debts: list[dict[str, Any]], monthly_income: float) -> dict[str, Any]:
    """Expects each debt dict: name, type, balance, monthly_payment, interest_rate (optional),
    property_value (optional, mortgage-type debts only — enables an LTV/PMI check)."""
    normalized = []
    for d in debts:
        entry = {
            "name": d.get("name", "Unnamed debt"),
            "type": d.get("type", "other"),
            "balance": round(float(d.get("balance") or 0.0), 2),
            "monthly_payment": round(float(d.get("monthly_payment") or 0.0), 2),
            "interest_rate": float(d["interest_rate"]) if d.get("interest_rate") is not None else None,
        }
        if entry["type"] == "mortgage" and d.get("property_value"):
            property_value = float(d["property_value"])
            ltv_pct = round((entry["balance"] / property_value) * 100, 1) if property_value > 0 else None
            entry["property_value"] = round(property_value, 2)
            entry["ltv_pct"] = ltv_pct
        normalized.append(entry)

    total_balance = round(sum(d["balance"] for d in normalized), 2)
    total_monthly_payments = round(sum(d["monthly_payment"] for d in normalized), 2)
    dti_ratio = round(total_monthly_payments / monthly_income, 4) if monthly_income > 0 else 0.0
    dti_status = _dti_status(dti_ratio)

    payoff_priority = sorted(
        (d for d in normalized if d["interest_rate"] is not None),
        key=lambda d: d["interest_rate"],
        reverse=True,
    )

    flags = []
    high_interest = [d for d in normalized if (d["interest_rate"] or 0) >= HIGH_INTEREST_THRESHOLD_PCT]
    if high_interest:
        names = ", ".join(f"{d['name']} ({d['interest_rate']:.1f}%)" for d in high_interest)
        flags.append(
            {
                "type": "HIGH_INTEREST_DEBT",
                "message": (
                    f"High-interest debt detected: {names}. Prioritize paying these down "
                    "first (avalanche method) before extra payments on lower-rate debt."
                ),
            }
        )
    if dti_status in ("HIGH", "CRITICAL"):
        flags.append(
            {
                "type": "DTI_" + dti_status,
                "message": (
                    f"Debt-to-income ratio is {dti_ratio * 100:.1f}% ({dti_status.lower()}). "
                    "Lenders generally view above 36% as elevated risk for new credit."
                ),
            }
        )

    for d in normalized:
        if d["type"] != "mortgage" or d.get("ltv_pct") is None:
            continue
        if d["ltv_pct"] >= PMI_LIKELY_LTV_THRESHOLD_PCT:
            flags.append(
                {
                    "type": "PMI_LIKELY",
                    "message": (
                        f"{d['name']} has an estimated LTV of {d['ltv_pct']:.1f}% — at or above 80% "
                        "usually means private mortgage insurance (PMI) is still required. Worth "
                        "checking with the lender once the balance drops below 80% of the home's value."
                    ),
                }
            )
        elif d["ltv_pct"] <= REFI_EQUITY_LTV_THRESHOLD_PCT:
            flags.append(
                {
                    "type": "SIGNIFICANT_EQUITY",
                    "message": (
                        f"{d['name']} has an estimated LTV of {d['ltv_pct']:.1f}%, meaning significant "
                        "home equity has built up. This is informational only — not a recommendation "
                        "to refinance or borrow against it."
                    ),
                }
            )

    return {
        "debts": normalized,
        "total_balance": total_balance,
        "total_monthly_payments": total_monthly_payments,
        "dti_ratio": dti_ratio,
        "dti_status": dti_status,
        "payoff_priority_order": [d["name"] for d in payoff_priority],
        "flags": flags,
        "disclaimer": "This is an analysis of your own data, not personalized debt advice.",
    }
