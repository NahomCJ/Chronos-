"""
routers/insights/router.py
============================
Dashboard Insights API — 3 GET endpoints for tier-1 bank-quality visualizations.

GET /api/insights/spending-summary  — Monthly spending + category breakdown
GET /api/insights/top-categories    — Top 5 categories with trend sparklines
GET /api/insights/warnings-history  — Risk warning timeline with heatmap

Every response is chart-ready: pre-sorted, pre-colored, pre-calculated.
The frontend renders data directly — zero transformation needed.
"""

from __future__ import annotations

import calendar
from datetime import date, datetime, timezone

from fastapi import APIRouter, HTTPException, Query

from core.logger import contract
from services.insights.data import load_transactions, load_warnings
from services.insights.warnings import compile_warnings_history
from services.insights.top_categories import compute_top_categories
from services.insights.spending_summary import compute_spending_summary
from routers.insights.models import (
    SpendingSummaryResponse,
    TopCategoriesResponse,
    WarningsHistoryResponse,
)

# ADR: The router is thin — it only fetches data and delegates computation to
# spending_summary.py, top_categories.py, and warnings.py (pure functions, no
# I/O). This means analytics functions are unit-testable without mocking
# database or API calls.
router = APIRouter(prefix="/insights", tags=["insights"])


@router.get("/spending-summary", response_model=SpendingSummaryResponse)
@contract
def spending_summary(
    user_id: str = Query(
        ...,
        pattern=r"^[a-z0-9_]{3,50}$",
        description="User identifier (e.g. 'user_marcus')",
    ),
    month: int = Query(..., ge=1, le=12, description="Target month (1-12)"),
    year: int = Query(..., ge=2020, le=2030, description="Target year"),
):
    """
    Returns a monthly spending summary with category breakdown, daily series, and day-of-week patterns.

    Args:
        user_id (str): User identifier (e.g. "user_marcus").
        month (int): Target month (1-12).
        year (int): Target year (2020-2030).

    Returns:
        SpendingSummaryResponse: Chart-ready JSON with summary totals, by_category (sorted desc,
            with subcategories, top_merchants, colors), daily_series (with cumulative),
            day_of_week_pattern, and month-over-month deltas at both summary and category level.

    Raises:
        HTTPException(404): Unknown user_id.
    """
    prev_month = month - 1 if month > 1 else 12
    prev_year = year if month > 1 else year - 1

    # ADR: Fetch just enough to cover target + previous month (~60 days) instead
    # of a blanket 365. Reduces Plaid/Supabase payload ~6x. The computation layer
    # filters to exact month boundaries, so extra data is harmless but wasteful.
    first_of_prev = date(prev_year, prev_month, 1)
    days_back = max((date.today() - first_of_prev).days + 1, 1)

    try:
        all_txns = load_transactions(user_id, days_back=days_back)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    # Anchor "today" to the latest transaction date so mock data always renders.
    # In production (Plaid/Supabase), transactions are current so this is a no-op.
    if all_txns:
        data_max = max(date.fromisoformat(t["date"]) for t in all_txns)
        real_today = date.today()
        anchor = real_today if real_today <= data_max else data_max
    else:
        anchor = date.today()

    # Split into previous month for comparison using date objects (not string prefix)
    prev_days = calendar.monthrange(prev_year, prev_month)[1]
    prev_start = date(prev_year, prev_month, 1)
    prev_end = date(prev_year, prev_month, prev_days)
    prev_month_txns = [
        t for t in all_txns if prev_start <= date.fromisoformat(t["date"]) <= prev_end
    ]

    # For historical months, use end-of-month so the full month renders.
    # For the anchor's own month, use the anchor date (partial month).
    days_in_month = calendar.monthrange(year, month)[1]
    end_of_month = date(year, month, days_in_month)
    summary_anchor = (
        anchor if (year == anchor.year and month == anchor.month) else end_of_month
    )

    result = compute_spending_summary(
        all_txns, prev_month_txns, month, year, today=summary_anchor
    )
    result["meta"]["user_id"] = user_id
    return result


@router.get("/top-categories", response_model=TopCategoriesResponse)
@contract
def top_categories(
    user_id: str = Query(
        ...,
        pattern=r"^[a-z0-9_]{3,50}$",
        description="User identifier (e.g. 'user_marcus')",
    ),
    days: int = Query(30, ge=1, le=365, description="Lookback period in days"),
):
    """
    Returns top 5 spending categories with 3-month trend sparklines and AI-generated insights.

    Args:
        user_id (str): User identifier (e.g. "user_marcus").
        days (int): Lookback period in days (1-365, default 30).

    Returns:
        TopCategoriesResponse: Chart-ready JSON with top_categories (ranked, with trend.spark,
            is_recurring_dominant, colors), other_categories (aggregated), and insights
            (natural-language observations about spending patterns).

    Raises:
        HTTPException(404): Unknown user_id.
    """
    try:
        # Fetch 90 days to have enough data for sparklines
        all_txns = load_transactions(user_id, days_back=max(days, 90))
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    # Anchor "today" to the latest transaction date so mock data always renders.
    # Cap with real today to prevent future-dated anchors if mock data has future dates.
    if all_txns:
        data_max = max(date.fromisoformat(t["date"]) for t in all_txns)
        real_today = date.today()
        anchor = min(real_today, data_max)
    else:
        anchor = date.today()

    result = compute_top_categories(all_txns, days, today=anchor)
    result["meta"]["user_id"] = user_id
    return result


@router.get("/warnings-history", response_model=WarningsHistoryResponse)
@contract
def warnings_history(
    user_id: str = Query(
        ...,
        pattern=r"^[a-z0-9_]{3,50}$",
        description="User identifier (e.g. 'user_marcus')",
    ),
    limit: int = Query(10, ge=1, le=100, description="Max warnings per page"),
    offset: int = Query(0, ge=0, description="Pagination offset"),
):
    """
    Returns risk warning history with severity distribution, trend analysis, and calendar heatmap.

    Args:
        user_id (str): User identifier (e.g. "user_marcus").
        limit (int): Max warnings per page (1-100, default 10).
        offset (int): Pagination offset (default 0).

    Returns:
        WarningsHistoryResponse: Chart-ready JSON with risk_summary (by_level with colors,
            by_source, trend_last_30d), warnings (enriched with date_label, risk_color),
            and calendar_heatmap (daily warning counts for current month).

    Raises:
        HTTPException(404): Unknown user_id.
    """
    try:
        # Fetch all warnings (compile_warnings_history handles pagination)
        raw_warnings = load_warnings(user_id, limit=1000)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    # Anchor "now" to the latest warning timestamp so mock data renders correctly.
    if raw_warnings:
        latest_ts = max(w["timestamp"] for w in raw_warnings)
        anchor = datetime.fromisoformat(latest_ts.replace("Z", "+00:00"))
    else:
        anchor = datetime.now(timezone.utc)

    result = compile_warnings_history(raw_warnings, limit, offset, now=anchor)
    result["meta"]["user_id"] = user_id
    return result
