"""
services/financial_advisor/analyzer.py
========================================
Top-level entry point: takes one person's raw financial data (income,
transactions, debts) and returns a full tailored report — expense breakdown,
gym/supplement flags, liability/DTI analysis, rough tax estimate, and
prioritized advice.

Called directly by scripts/analyze_financial_data.py (standalone/offline use)
and by routers/financial_advisor/router.py (HTTP use). Not decorated with
@contract: input includes a person's name and raw financial figures, and
CLAUDE.md's "never store PII in logs" rule means this boundary must not log
its raw args/kwargs the way the @contract decorator does.
"""

from __future__ import annotations

from typing import Any

from services.financial_advisor.advice_engine import build_advice
from services.financial_advisor.categorizer import categorize_expenses
from services.financial_advisor.crypto_analysis import analyze_crypto
from services.financial_advisor.gym_analysis import analyze_gym_spending
from services.financial_advisor.liability_analysis import analyze_liabilities
from services.financial_advisor.nft_analysis import analyze_nft
from services.financial_advisor.supplement_analysis import analyze_supplement_spending
from services.financial_advisor.tax_estimator import estimate_tax


def analyze_person(person: dict[str, Any]) -> dict[str, Any]:
    """
    Args:
        person: {
            "name": str (optional, used only for report labeling),
            "location": str (optional, e.g. "Austin, TX"),
            "monthly_income": float,
            "filing_status": "single" | "married_joint" (optional, default "single"),
            "transactions": [{"merchant": str, "amount": float,
                               "frequency": "monthly"|"weekly"|"annual"|"quarterly"|"one_time",
                               "category": str (optional hint), "location": str (optional)}],
            "debts": [{"name": str, "type": str, "balance": float,
                       "monthly_payment": float, "interest_rate": float (optional, as a %),
                       "property_value": float (optional, mortgage-type debts only, enables LTV check)}],
            "crypto_transactions": [{"asset": str, "side": "buy"|"sell", "quantity": float,
                                      "price_per_unit": float, "fee": float (optional),
                                      "date": str (optional, ISO)}] (optional),
            "crypto_current_prices": {"BTC": float, ...} (optional, enables unrealized P&L),
            "nft_transactions": [{"collection": str, "event": "mint"|"purchase"|"sale"|
                                   "transfer_in"|"transfer_out", "price": float,
                                   "gas_fee": float (optional), "date": str (optional),
                                   "current_floor_price": float (optional)}] (optional),
        }

    Returns: a full report dict (see keys below). Never raises on missing
    optional fields — only "monthly_income" is required to produce ratios.
    """
    monthly_income = float(person.get("monthly_income") or 0.0)
    location = person.get("location")
    filing_status = person.get("filing_status", "single")
    transactions = person.get("transactions") or []
    debts = person.get("debts") or []

    expense_summary = categorize_expenses(transactions)
    gym_result = analyze_gym_spending(expense_summary["transactions"], location)
    supplement_result = analyze_supplement_spending(expense_summary["transactions"], monthly_income)
    liability_result = analyze_liabilities(debts, monthly_income)
    tax_estimate = estimate_tax(monthly_income * 12, filing_status)
    crypto_result = analyze_crypto(
        person.get("crypto_transactions") or [], person.get("crypto_current_prices")
    )
    nft_result = analyze_nft(person.get("nft_transactions") or [])

    advice = build_advice(
        monthly_income=monthly_income,
        expense_summary=expense_summary,
        gym_result=gym_result,
        supplement_result=supplement_result,
        liability_result=liability_result,
        tax_estimate=tax_estimate,
        crypto_result=crypto_result,
        nft_result=nft_result,
    )

    total_expenses = expense_summary["total_monthly_expenses"]
    total_debt_payments = liability_result["total_monthly_payments"]
    leftover = round(monthly_income - total_expenses - total_debt_payments, 2)

    return {
        "name": person.get("name"),
        "monthly_income": round(monthly_income, 2),
        "summary": {
            "total_monthly_expenses": total_expenses,
            "total_monthly_debt_payments": total_debt_payments,
            "monthly_leftover": leftover,
            "savings_rate_pct": round((leftover / monthly_income) * 100, 2) if monthly_income > 0 else 0.0,
        },
        "expenses": expense_summary,
        "gym_analysis": gym_result,
        "supplement_analysis": supplement_result,
        "liabilities": liability_result,
        "tax_estimate": tax_estimate,
        "crypto_analysis": crypto_result,
        "nft_analysis": nft_result,
        "advice": advice,
    }


def analyze_people(people: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [analyze_person(p) for p in people]
