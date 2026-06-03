"""Income and payroll advisory API endpoints."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException, Query

from core.logger import contract
from services.income import (
    IncomeConsentError,
    analyze_income_stability,
    get_paycheck_plan,
    get_tax_awareness,
    sync_income,
)

router = APIRouter(prefix="/income", tags=["income"])


def _user_query():
    return Query(
        ...,
        pattern=r"^(user_)?[a-z0-9_]{3,50}$",
        description="User identifier, e.g. user_marcus or marcus",
    )


@router.get("/stability")
@contract
def stability(user_id: str = _user_query()):
    try:
        return analyze_income_stability(user_id)
    except IncomeConsentError as exc:
        raise HTTPException(status_code=403, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/paycheck-plan")
@contract
def paycheck_plan(user_id: str = _user_query()):
    try:
        return get_paycheck_plan(user_id)
    except IncomeConsentError as exc:
        raise HTTPException(status_code=403, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/tax-awareness")
@contract
def tax_awareness(user_id: str = _user_query()):
    try:
        return get_tax_awareness(user_id)
    except IncomeConsentError as exc:
        raise HTTPException(status_code=403, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/summary")
@contract
def summary(user_id: str = _user_query()):
    try:
        synced = sync_income(user_id)
        stability_data = analyze_income_stability(user_id)
        paycheck = get_paycheck_plan(user_id)
        tax = get_tax_awareness(user_id)
        return {
            "user_id": synced["user_id"],
            "synced_at": synced["synced_at"],
            "income_type": synced["income_type"],
            "has_payroll_connection": synced["has_payroll_connection"],
            "estimated_monthly_income": synced["estimated_monthly_income"],
            "stability_score": stability_data["stability_score"],
            "stability_status": stability_data["stability_status"],
            "expected_next_income_date": stability_data["expected_next_income_date"],
            "will_overdraft": paycheck["will_overdraft"],
            "balance_after_bills": paycheck["balance_after_bills"],
            "tax_flags": tax["tax_flags"],
        }
    except IncomeConsentError as exc:
        raise HTTPException(status_code=403, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
