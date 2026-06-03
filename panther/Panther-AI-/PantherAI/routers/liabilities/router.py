"""Liabilities API endpoints."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException, Query

from core.logger import contract
from services.liabilities.credit_card import analyze_credit_cards
from services.liabilities.dti_calculator import calculate_dti
from services.liabilities.ingestion import LiabilitiesConsentError, sync_liabilities
from services.liabilities.loans import analyze_loans
from services.liabilities.mortgage import analyze_mortgage

router = APIRouter(prefix="/liabilities", tags=["liabilities"])


def _user_query():
    return Query(
        ...,
        pattern=r"^(user_)?[a-z0-9_]{3,50}$",
        description="User identifier, e.g. user_marcus or marcus",
    )


@router.get("/credit-cards")
@contract
def credit_cards(user_id: str = _user_query()):
    try:
        return analyze_credit_cards(user_id)
    except LiabilitiesConsentError as exc:
        raise HTTPException(status_code=403, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/loans")
@contract
def loans(user_id: str = _user_query()):
    try:
        return analyze_loans(user_id)
    except LiabilitiesConsentError as exc:
        raise HTTPException(status_code=403, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/mortgage")
@contract
def mortgage(user_id: str = _user_query()):
    try:
        return analyze_mortgage(user_id)
    except LiabilitiesConsentError as exc:
        raise HTTPException(status_code=403, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/dti")
@contract
def dti(user_id: str = _user_query()):
    try:
        result = calculate_dti(user_id)
        result["disclaimer"] = "This is an analysis of your data, not debt advice."
        return result
    except LiabilitiesConsentError as exc:
        raise HTTPException(status_code=403, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/summary")
@contract
def summary(user_id: str = _user_query()):
    try:
        synced = sync_liabilities(user_id)
        credit = analyze_credit_cards(user_id)
        loan_data = analyze_loans(user_id)
        mortgage_data = analyze_mortgage(user_id)
        dti_data = calculate_dti(user_id)
        total_debt = round(
            float(credit.get("total_credit_card_debt") or 0.0)
            + float(loan_data.get("total_loan_debt") or 0.0)
            + float(mortgage_data.get("outstanding_balance") or 0.0),
            2,
        )
        return {
            "user_id": synced["user_id"],
            "synced_at": synced["synced_at"],
            "total_debt": total_debt,
            "credit_cards": credit,
            "loans": loan_data,
            "mortgage": mortgage_data,
            "dti": dti_data,
            "disclaimer": "This is an analysis of your data, not debt advice.",
        }
    except LiabilitiesConsentError as exc:
        raise HTTPException(status_code=403, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
