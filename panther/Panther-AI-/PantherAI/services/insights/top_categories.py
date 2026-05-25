"""
services/insights/top_categories.py
=====================================
Top-categories computation for the Dashboard Insights API.

Pure functions. No I/O. Takes raw transactions in, returns a chart-ready
dict with the top 5 spending categories, 3-month trend sparklines, and
AI-generated insights. The router is responsible for fetching data (via
`services.insights.data`) and filling `meta.user_id`.

Response shape:
    {"meta": {...}, "total_spent": float, "top_categories": [...],
     "other_categories": {...}, "insights": [...]}
"""

from __future__ import annotations

import calendar
from collections import defaultdict
from datetime import date, datetime, timedelta, timezone
from typing import Any

from services.insights.constants import (
    CATEGORY_COLORS,
    CATEGORY_ICONS,
    CATEGORY_ID_TO_NAME,
    get_category_id,
)
from services.insights.helpers import _parse_date, _pct


def compute_top_categories(
    transactions: list[dict[str, Any]],
    days: int,
    *,
    today: date | None = None,
) -> dict[str, Any]:
    """
    Computes top 5 spending categories with 3-month trend sparklines and AI-generated insights.

    Args:
        transactions (list[dict]): All transactions (must include 90+ days for sparklines).
            Each dict: {"merchant": str, "amount": float, "date": str, "category": str}.
            Filtered internally to last N days for ranking; full history used for sparklines.
        days (int): Lookback period in days for the primary ranking (1-365).
        today (date | None): Anchor date for the lookback window. Defaults to date.today().
            The router passes the latest transaction date when using mock data.

    Returns:
        dict: {"meta": {...}, "total_spent": float, "top_categories": [max 5, each with
            trend.spark (3-element array), trend.direction, is_recurring_dominant, color, icon],
            "other_categories": {aggregated remainder}, "insights": [AI observations]}
            The "meta.user_id" field is empty — the router fills it.
    """
    # ADR: Sparklines use calendar months (not rolling 30-day windows) because
    # users think in months, not arbitrary date ranges. "Feb vs Jan" is intuitive;
    # "Feb 1-28 vs Jan 2-31" is confusing.
    today = today or date.today()
    start_date = today - timedelta(days=days)
    end_date = today

    # Current period
    current_txns = [
        t
        for t in transactions
        if start_date <= _parse_date(t["date"]) <= end_date and t["amount"] < 0
    ]

    total_spent = round(abs(sum(t["amount"] for t in current_txns)), 2)

    # Group by category
    cat_amounts: dict[str, float] = defaultdict(float)
    cat_counts: dict[str, int] = defaultdict(int)
    cat_merchants: dict[str, dict[str, int]] = defaultdict(lambda: defaultdict(int))

    for t in current_txns:
        cat_id = get_category_id(t.get("category", "Uncategorized"))
        cat_amounts[cat_id] += abs(t["amount"])
        cat_counts[cat_id] += 1
        cat_merchants[cat_id][t["merchant"]] += 1

    # Build 3-month sparkline data
    def _monthly_total(cat_id: str, target_month: int, target_year: int) -> float:
        month_days = calendar.monthrange(target_year, target_month)[1]
        s = date(target_year, target_month, 1)
        e = date(target_year, target_month, month_days)
        return round(
            abs(
                sum(
                    t["amount"]
                    for t in transactions
                    if s <= _parse_date(t["date"]) <= e
                    and t["amount"] < 0
                    and get_category_id(t.get("category", "Uncategorized")) == cat_id
                )
            ),
            2,
        )

    # Last 3 months
    months_back = []
    current_month = today.month
    current_year = today.year
    for i in range(3):
        m = current_month - i
        y = current_year
        if m <= 0:
            m += 12
            y -= 1
        months_back.insert(0, (y, m))

    sorted_cats = sorted(cat_amounts.items(), key=lambda x: x[1], reverse=True)
    top_5 = sorted_cats[:5]
    rest = sorted_cats[5:]

    top_categories = []
    for rank, (cat_id, amount) in enumerate(top_5, 1):
        amount = round(amount, 2)
        cat_name = CATEGORY_ID_TO_NAME.get(cat_id, "Uncategorized")

        # Sparkline
        spark = [_monthly_total(cat_id, m, y) for y, m in months_back]
        periods = [f"{calendar.month_abbr[m]} {y}" for y, m in months_back]
        avg_3mo = sum(spark) / max(len(spark), 1)
        current_val = spark[-1] if spark else 0
        delta_vs_avg = round(current_val - avg_3mo, 2)
        delta_vs_avg_pct = round(delta_vs_avg / avg_3mo * 100, 1) if avg_3mo else 0.0

        if delta_vs_avg_pct > 10:
            trend_dir = "increasing"
        elif delta_vs_avg_pct < -10:
            trend_dir = "decreasing"
        else:
            trend_dir = "stable"

        # ADR: Recurring detection uses a simple heuristic — if a category has
        # <=3 transactions and >=70% come from a single merchant, it's likely a
        # recurring bill (rent, subscription). This avoids false positives on
        # categories like "Food & Drink" where many merchants appear.
        merchants = cat_merchants[cat_id]
        total_cat_txns = cat_counts[cat_id]
        top_merchant_count = max(merchants.values()) if merchants else 0
        is_recurring = (
            total_cat_txns <= 3 and top_merchant_count >= total_cat_txns * 0.7
        )

        top_categories.append(
            {
                "rank": rank,
                "category_id": cat_id,
                "category_name": cat_name,
                "amount": amount,
                "percentage": _pct(amount, total_spent),
                "transaction_count": cat_counts[cat_id],
                "avg_transaction": round(amount / max(cat_counts[cat_id], 1), 2),
                "color": CATEGORY_COLORS.get(cat_id, "#A0AEC0"),
                "icon": CATEGORY_ICONS.get(cat_id, "help-circle"),
                "is_recurring_dominant": is_recurring,
                "trend": {
                    "direction": trend_dir,
                    "spark": spark,
                    "periods": periods,
                    "current_vs_3mo_avg": delta_vs_avg,
                    "current_vs_3mo_avg_pct": delta_vs_avg_pct,
                },
                "budget_status": None,
            }
        )

    # Other categories
    other_amount = round(sum(a for _, a in rest), 2)
    other_cats = [
        {
            "category_id": cid,
            "category_name": CATEGORY_ID_TO_NAME.get(cid, "Uncategorized"),
            "amount": round(a, 2),
        }
        for cid, a in rest
    ]

    # ADR: Insights are generated server-side (not by an LLM) using simple
    # threshold rules. This keeps latency < 5ms and avoids LLM costs. The
    # thresholds (5% spike, 35% concentration) are tuned to the demo narrative
    # and will be configurable per-user in a future sprint.
    insights = []
    for cat in top_categories:
        trend = cat["trend"]
        if trend["direction"] == "increasing" and trend["current_vs_3mo_avg_pct"] > 5:
            insights.append(
                {
                    "type": "spike",
                    "severity": "info",
                    "message": f"{cat['category_name']} spending is up {trend['current_vs_3mo_avg_pct']}% vs. your 3-month average.",
                    "category_id": cat["category_id"],
                    "icon": "trending-up",
                }
            )
        if cat["percentage"] > 35:
            qualifier = (
                "Mostly recurring bills." if cat["is_recurring_dominant"] else ""
            )
            insights.append(
                {
                    "type": "concentration",
                    "severity": "warning",
                    "message": f"{cat['percentage']}% of your spending goes to {cat['category_name']}. {qualifier}".strip(),
                    "category_id": cat["category_id"],
                    "icon": "alert-circle",
                }
            )

    return {
        "meta": {
            "user_id": "",  # Filled by router
            "period": {
                "days": days,
                "start_date": start_date.isoformat(),
                "end_date": end_date.isoformat(),
                "label": f"Last {days} days",
            },
            "currency": "USD",
            "generated_at": datetime.now(timezone.utc).isoformat(),
        },
        "total_spent": total_spent,
        "category_count_total": len(cat_amounts),
        "top_categories": top_categories,
        "other_categories": {
            "count": len(rest),
            "amount": other_amount,
            "percentage": _pct(other_amount, total_spent),
            "categories": other_cats,
        },
        "insights": insights,
    }
