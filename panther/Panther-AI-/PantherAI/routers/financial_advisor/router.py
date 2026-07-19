"""
routers/financial_advisor/router.py
=====================================
Financial Advisor API — analyzes pasted/uploaded financial data (income,
transactions, debts) for one or more people and returns a tailored advice
report: expense categorization, gym/supplement flags, liability/DTI
analysis, and a rough tax estimate.

Unlike the rest of the Panther API, these endpoints do not look up a
user_id in mock/Plaid banking data — the caller supplies the financial data
directly in the request body. This is the "given raw pasted data, analyze
it" path (e.g. for a one-off financial review), separate from the
per-connected-account insights/net-worth/liabilities APIs.

POST /api/financial-advisor/analyze        — one person
POST /api/financial-advisor/analyze/batch  — multiple people
"""

from __future__ import annotations

from fastapi import APIRouter

from routers.financial_advisor.models import (
    BatchFinancialAdviceReport,
    BatchFinancialInput,
    FinancialAdviceReport,
    PersonFinancialInput,
)
from services.financial_advisor.analyzer import analyze_people, analyze_person

router = APIRouter(prefix="/financial-advisor", tags=["financial-advisor"])


@router.post("/analyze", response_model=FinancialAdviceReport)
def analyze(person: PersonFinancialInput):
    """Analyzes one person's financial data and returns a tailored advice report."""
    return analyze_person(person.model_dump())


@router.post("/analyze/batch", response_model=BatchFinancialAdviceReport)
def analyze_batch(payload: BatchFinancialInput):
    """Analyzes multiple people's financial data in one call (e.g. a household review)."""
    reports = analyze_people([p.model_dump() for p in payload.people])
    return {"reports": reports}
