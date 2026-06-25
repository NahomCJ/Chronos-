"""Panther Financial Health Score v2.

Scoring logic documentation for FCA Consumer Duty explainability:

The score is an internal progress metric built from five explainable pillars.
Each pillar produces a 0-100 score, then the weighted average is floored to an
integer. The weights are: spending 0.20, saving 0.20, debt 0.25, investing 0.20,
and income stability 0.15.

Pillar mapping:
- Spending: derived from cash-flow/overdraft risk. HIGH overdraft risk maps to
  35, MEDIUM buffer risk maps to 65, LOW risk maps to 80.
- Saving: uses projected cash buffer after known bills divided by monthly income.
  >20% maps to 90, 10-20% maps linearly to 60-89, <10% maps linearly to 30-59.
- Debt: uses DTI from the liabilities lane. <28% maps to 90, 28-36% maps
  linearly to 60-89, 36-50% maps linearly to 30-59, and >50% maps to 0-29.
- Investing: diversified connected investments map to 70, undiversified connected
  investments map to 58, and no connected investment account maps to neutral 40.
- Income stability: maps directly from the Income lane stability_score.

The score must never be framed as a credit score, credit rating, underwriting
metric, or regulated financial assessment. ``score_disclaimer`` is mandatory in
every response and must never be empty.
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from services.banking.mock_api import get_balance
from services.income.ingestion import IncomeConsentError, get_income_data
from services.income.paycheck_planner import get_paycheck_plan
from services.income.stability import analyze_income_stability
from services.liabilities.dti_calculator import calculate_dti
from services.liabilities.ingestion import LiabilitiesConsentError

from .mock_data import has_source, investment_fixture, normalize_user_id

SCORE_DISCLAIMER = (
    "Panther's Financial Health Score is an internal metric to help you track your "
    "financial progress over time. It is not a credit score, credit rating, or regulated "
    "financial assessment, and has no impact on your ability to access credit or financial products."
)

WEIGHTS = {
    "spending": 0.20,
    "saving": 0.20,
    "debt": 0.25,
    "investing": 0.20,
    "income_stability": 0.15,
}


def calculate_health_score(user_id: str) -> dict[str, Any]:
    normalized_user_id = normalize_user_id(user_id)
    get_balance(normalized_user_id)

    pillars = {
        "spending": _spending_pillar(normalized_user_id),
        "saving": _saving_pillar(normalized_user_id),
        "debt": _debt_pillar(normalized_user_id),
        "investing": _investing_pillar(normalized_user_id),
        "income_stability": _income_stability_pillar(normalized_user_id),
    }
    weighted_score = sum(
        pillars[name]["score"] * pillars[name]["weight"] for name in WEIGHTS
    )
    overall_score = max(0, min(100, int(weighted_score)))

    return {
        "user_id": normalized_user_id,
        "overall_score": overall_score,
        "rating": _rating(overall_score),
        "pillars": pillars,
        "score_disclaimer": SCORE_DISCLAIMER,
        "previous_score": None,
        "score_change": None,
        "calculated_at": datetime.now(timezone.utc).isoformat(),
    }


def _spending_pillar(user_id: str) -> dict[str, Any]:
    try:
        plan = get_paycheck_plan(user_id)
        if plan.get("will_overdraft"):
            score = 35
            status = "HIGH_RISK"
            insight = "Connected cash-flow data shows a shortfall before the next reliable income date."
        elif float(plan.get("balance_after_bills") or 0.0) < 500:
            score = 65
            status = "MEDIUM_RISK"
            insight = "Known bills are covered, but the remaining cash buffer is thin."
        else:
            score = 80
            status = "LOW_RISK"
            insight = "Known bills are covered by the connected cash balance."
    except (IncomeConsentError, ValueError):
        score = 50
        status = "PARTIAL_DATA"
        insight = "Cash-flow risk is based on partial connected account data."
    return _pillar(score, "spending", status, insight)


def _saving_pillar(user_id: str) -> dict[str, Any]:
    try:
        plan = get_paycheck_plan(user_id)
        income = _monthly_income(user_id)
        if income <= 0:
            return _pillar(
                40,
                "saving",
                "INSUFFICIENT_DATA",
                "No reliable income estimate is connected yet, so savings capacity is partial.",
            )
        savings_rate = max(0.0, float(plan.get("balance_after_bills") or 0.0)) / income
        if savings_rate > 0.20:
            score = 90
            status = "STRONG"
        elif savings_rate >= 0.10:
            score = int(60 + ((savings_rate - 0.10) / 0.10) * 29)
            status = "MODERATE"
        else:
            score = int(30 + (savings_rate / 0.10) * 29)
            status = "LOW"
        insight = (
            "Savings capacity is estimated from connected cash remaining after known bills "
            "against connected monthly income."
        )
        return _pillar(score, "saving", status, insight)
    except (IncomeConsentError, ValueError):
        return _pillar(
            40,
            "saving",
            "PARTIAL_DATA",
            "Savings capacity cannot be fully calculated without connected income data.",
        )


def _debt_pillar(user_id: str) -> dict[str, Any]:
    try:
        dti = calculate_dti(user_id)
        ratio = float(dti.get("dti_ratio") or 0.0)
        if ratio < 0.28:
            score = 90
            status = "HEALTHY"
        elif ratio <= 0.36:
            score = int(60 + ((0.36 - ratio) / 0.08) * 29)
            status = "ELEVATED"
        elif ratio <= 0.50:
            score = int(30 + ((0.50 - ratio) / 0.14) * 29)
            status = "HIGH"
        else:
            score = max(0, int(29 - min((ratio - 0.50) / 0.50, 1.0) * 29))
            status = "CRITICAL"
        insight = "Debt pillar uses connected DTI and utilization signals from the liabilities lane."
        return _pillar(score, "debt", status, insight)
    except (LiabilitiesConsentError, ValueError):
        return _pillar(
            45,
            "debt",
            "PARTIAL_DATA",
            "No connected liabilities data is available, so Panther does not infer that debt is zero.",
        )


def _investing_pillar(user_id: str) -> dict[str, Any]:
    if not has_source(user_id, "investments"):
        return _pillar(
            40,
            "investing",
            "NO_CONNECTED_ACCOUNT",
            "No investment account is connected; this is treated as neutral rather than zero.",
        )

    investments = investment_fixture(user_id)
    if bool(investments.get("diversified")):
        score = 70
        status = "DIVERSIFIED"
        insight = "Connected investments include multiple asset classes."
    else:
        score = 58
        status = "CONCENTRATED"
        insight = "Connected investments appear concentrated in a small number of holdings."
    return _pillar(score, "investing", status, insight)


def _income_stability_pillar(user_id: str) -> dict[str, Any]:
    try:
        stability = analyze_income_stability(user_id)
        score = int(float(stability.get("stability_score") or 0.0))
        status = str(stability.get("stability_status") or "UNKNOWN")
        insight = str(stability.get("insight") or "Income stability is based on connected income events.")
        return _pillar(score, "income_stability", status, insight)
    except (IncomeConsentError, ValueError):
        return _pillar(
            35,
            "income_stability",
            "PARTIAL_DATA",
            "No connected income stability data is available.",
        )


def _monthly_income(user_id: str) -> float:
    data = get_income_data(user_id)
    return float(data.get("estimated_monthly_income") or data.get("gross_monthly_income") or 0.0)


def _pillar(score: int, name: str, status: str, insight: str) -> dict[str, Any]:
    return {
        "score": max(0, min(100, int(score))),
        "weight": WEIGHTS[name],
        "status": status,
        "insight": insight,
    }


def _rating(score: int) -> str:
    if score >= 85:
        return "EXCELLENT"
    if score >= 70:
        return "GOOD"
    if score >= 50:
        return "FAIR"
    if score >= 35:
        return "NEEDS_ATTENTION"
    return "AT_RISK"
