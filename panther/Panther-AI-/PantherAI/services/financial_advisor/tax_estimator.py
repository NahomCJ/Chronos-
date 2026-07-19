"""
services/financial_advisor/tax_estimator.py
=============================================
Rough, non-authoritative federal income tax estimate.

This is a simplified progressive-bracket calculation (2024 US federal brackets,
standard deduction only — no state tax, credits, itemized deductions, or
self-employment tax). It exists to give a ballpark "you'll likely owe roughly
this much" figure for advice purposes, NOT a real tax computation.

ADR: services/income/tax_awareness.py deliberately never calculates a tax
liability figure — it only surfaces UK HMRC-style pattern flags, and Chris's
system prompt is hard-coded to refuse stating a specific tax liability in
conversation. This module is a distinct, explicitly-labeled "rough estimate"
tool for the standalone financial-advisor report; it is intentionally NOT
wired into Chris's tool-calling loop (see services/conversational_ai/tools.py)
so that compliance guardrail is not bypassed by a raw number reaching the LLM.
"""

from __future__ import annotations

from typing import Any, Literal

TAX_DISCLAIMER = (
    "This is a rough, non-authoritative estimate based on simplified 2024 US "
    "federal brackets and the standard deduction only. It ignores state tax, "
    "credits, itemized deductions, and self-employment tax. Speak to a "
    "qualified tax professional for your actual liability."
)

_STANDARD_DEDUCTION = {
    "single": 14_600.0,
    "married_joint": 29_200.0,
}

# (bracket_ceiling, rate) — cumulative progressive brackets, 2024 US federal.
_BRACKETS = {
    "single": [
        (11_600.0, 0.10),
        (47_150.0, 0.12),
        (100_525.0, 0.22),
        (191_950.0, 0.24),
        (243_725.0, 0.32),
        (609_350.0, 0.35),
        (float("inf"), 0.37),
    ],
    "married_joint": [
        (23_200.0, 0.10),
        (94_300.0, 0.12),
        (201_050.0, 0.22),
        (383_900.0, 0.24),
        (487_450.0, 0.32),
        (731_200.0, 0.35),
        (float("inf"), 0.37),
    ],
}


def estimate_tax(
    annual_income: float,
    filing_status: Literal["single", "married_joint"] = "single",
) -> dict[str, Any]:
    filing_status = filing_status if filing_status in _BRACKETS else "single"
    deduction = _STANDARD_DEDUCTION[filing_status]
    taxable_income = max(0.0, annual_income - deduction)

    brackets = _BRACKETS[filing_status]
    tax_owed = 0.0
    prev_ceiling = 0.0
    marginal_rate = brackets[0][1]

    for ceiling, rate in brackets:
        if taxable_income <= prev_ceiling:
            break
        slice_amount = min(taxable_income, ceiling) - prev_ceiling
        tax_owed += slice_amount * rate
        marginal_rate = rate
        prev_ceiling = ceiling
        if taxable_income <= ceiling:
            break

    effective_rate = round((tax_owed / annual_income) * 100, 2) if annual_income > 0 else 0.0

    return {
        "filing_status": filing_status,
        "annual_income": round(annual_income, 2),
        "standard_deduction": deduction,
        "taxable_income": round(taxable_income, 2),
        "estimated_annual_tax": round(tax_owed, 2),
        "estimated_monthly_tax": round(tax_owed / 12, 2),
        "effective_tax_rate_pct": effective_rate,
        "marginal_tax_rate_pct": round(marginal_rate * 100, 2),
        "disclaimer": TAX_DISCLAIMER,
    }
