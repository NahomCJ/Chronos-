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

POST /api/financial-advisor/analyze        — one person, caller-supplied data
POST /api/financial-advisor/analyze/batch  — multiple people, caller-supplied data
GET  /api/financial-advisor/full-analysis  — one connected user, pulled from
                                              Plaid + Veryfi (mock today, real
                                              once tokens/credentials exist)
"""

from __future__ import annotations

from fastapi import APIRouter, HTTPException, Query

from routers.financial_advisor.models import (
    BatchFinancialAdviceReport,
    BatchFinancialInput,
    FinancialAdviceReport,
    FullFinancialPictureReport,
    PersonFinancialInput,
)
from services.financial_advisor.analyzer import analyze_people, analyze_person
from services.financial_advisor.full_picture import build_full_financial_picture

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


@router.get("/full-analysis", response_model=FullFinancialPictureReport)
def full_analysis(
    user_id: str = Query(
        ...,
        pattern=r"^[a-z0-9_]{3,50}$",
        description="User identifier (e.g. 'user_marcus')",
    ),
):
    """
    Full-capability analysis for a connected user: pulls Plaid transactions
    and BNPL exposure plus Veryfi receipt line items, merges them, and runs
    the result through the same advice engine as /analyze.

    Unlike /analyze, the caller doesn't paste financial data — it's read
    from the user's connected accounts (mock data until Plaid/Veryfi
    credentials are configured for that user; same response shape either way).
    """
    try:
        return build_full_financial_picture(user_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
