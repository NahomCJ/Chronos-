"""Net worth and Panther Financial Health API endpoints."""

from __future__ import annotations

import time
from concurrent.futures import ThreadPoolExecutor
from typing import Literal

from fastapi import APIRouter, HTTPException, Query

from core.logger import contract
from services.net_worth import (
    calculate_dta,
    calculate_health_score,
    calculate_net_worth,
    get_net_worth_trend,
    project_net_worth,
    snapshot_net_worth,
)

router = APIRouter(prefix="/net-worth", tags=["net-worth"])


def _user_query():
    return Query(
        ...,
        pattern=r"^(user_)?[a-z0-9_]{3,50}$",
        description="User identifier, e.g. user_marcus or marcus",
    )


@router.get("")
@contract
def net_worth(user_id: str = _user_query()):
    try:
        return calculate_net_worth(user_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/health-score")
@contract
def health_score(user_id: str = _user_query()):
    try:
        return calculate_health_score(user_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/trend")
@contract
def trend(
    user_id: str = _user_query(),
    period: Literal["30d", "90d", "365d"] = "90d",
):
    try:
        return get_net_worth_trend(user_id, period=period)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))


@router.get("/dta")
@contract
def dta(user_id: str = _user_query()):
    try:
        return calculate_dta(user_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/projection")
@contract
def projection(
    user_id: str = _user_query(),
    months: int = Query(12, ge=1, le=60),
    monthly_contribution_delta: float = Query(0.0),
    annual_investment_return_pct: float = Query(7.0, ge=0, le=30),
):
    try:
        return project_net_worth(
            user_id,
            months=months,
            monthly_contribution_delta=monthly_contribution_delta,
            annual_investment_return_pct=annual_investment_return_pct,
        )
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/dashboard")
@contract
def dashboard(
    user_id: str = _user_query(),
    period: Literal["30d", "90d", "365d"] = "90d",
):
    started = time.perf_counter()
    try:
        with ThreadPoolExecutor(max_workers=4) as pool:
            net_worth_future = pool.submit(calculate_net_worth, user_id)
            health_future = pool.submit(calculate_health_score, user_id)
            trend_future = pool.submit(get_net_worth_trend, user_id, period)
            dta_future = pool.submit(calculate_dta, user_id)
            net_worth_result = net_worth_future.result()
            health_result = health_future.result()
            trend_result = trend_future.result()
            dta_result = dta_future.result()
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    return {
        "net_worth": net_worth_result,
        "health_score": health_result,
        "trend": trend_result,
        "dta": dta_result,
        "duration_ms": round((time.perf_counter() - started) * 1000, 2),
    }


@router.post("/snapshot")
@contract
def snapshot(user_id: str = _user_query()):
    try:
        return snapshot_net_worth(user_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
