"""
services/insights/spending_summary.py
======================================
Monthly spending summary computation for the Dashboard Insights API.

Pure functions. No I/O. Takes raw transactions in, returns a chart-ready
dict. The router is responsible for fetching data (via
`services.insights.data`) and filling `meta.user_id`.

Response shape:
    {"meta": {...}, "summary": {...}, "by_category": [...],
     "daily_series": [...], "day_of_week_pattern": [...]}
"""

from __future__ import annotations

import calendar
from collections import defaultdict
from datetime import date, datetime, timezone
from typing import Any

from services.insights.constants import (
    CATEGORY_COLORS,
    CATEGORY_ICONS,
    CATEGORY_ID_TO_NAME,
    TAXONOMY,
    get_category_id,
    get_subcategory_color,
)
from services.insights.helpers import _direction, _parse_date, _pct


def _get_subcategories_for_category(cat_id: str) -> list[dict[str, str]]:
    for cat in TAXONOMY["taxonomy"]:
        if cat["id"] == cat_id:
            return cat.get("subcategories", [])
    return []


def compute_spending_summary(
    transactions: list[dict[str, Any]],
    prev_month_transactions: list[dict[str, Any]],
    month: int,
    year: int,
    *,
    today: date | None = None,
) -> dict[str, Any]:
    """
    Computes a full monthly spending summary with category breakdown, daily series, and month-over-month deltas.

    Args:
        transactions (list[dict]): All transactions across multiple months. Each dict must have
            keys: "merchant" (str), "amount" (float, negative=debit), "date" (str ISO),
            "category" (str, display name like "Groceries"). Filtered internally to target month.
        prev_month_transactions (list[dict]): Transactions from the previous month only.
            Used to compute vs_previous_month deltas at summary and category level.
        month (int): Target month (1-12).
        year (int): Target year (e.g. 2025).
        today (date | None): Anchor date for daily_series and days_elapsed calculation.
            Defaults to date.today(). The router passes the latest transaction date when
            using mock data so historical months render fully.

    Returns:
        dict: {"meta": {...}, "summary": {"total_spent", "total_income", "net_cash_flow",
            "vs_previous_month": {"direction": "increased|decreased|unchanged", ...}},
            "by_category": [sorted by amount desc, each with subcategories, top_merchants, color, icon],
            "daily_series": [one entry per day with cumulative], "day_of_week_pattern": [7 entries]}
            The "meta.user_id" field is empty — the router fills it.
    """
    days_in_month = calendar.monthrange(year, month)[1]
    start_date = date(year, month, 1)
    end_date = date(year, month, days_in_month)

    current_txns = [
        t for t in transactions if start_date <= _parse_date(t["date"]) <= end_date
    ]

    spending_txns = [t for t in current_txns if t["amount"] < 0]
    income_txns = [t for t in current_txns if t["amount"] > 0]

    total_spent = round(abs(sum(t["amount"] for t in spending_txns)), 2)
    total_income = round(sum(t["amount"] for t in income_txns), 2)
    net_cash_flow = round(total_income - total_spent, 2)
    transaction_count = len(current_txns)

    today = today or date.today()
    days_elapsed = (
        min((today - start_date).days + 1, days_in_month)
        if today >= start_date
        else days_in_month
    )
    daily_average = round(total_spent / max(days_elapsed, 1), 2)

    prev_spending = [t for t in prev_month_transactions if t["amount"] < 0]
    prev_total_spent = round(abs(sum(t["amount"] for t in prev_spending)), 2)
    spent_delta = round(total_spent - prev_total_spent, 2)
    spent_delta_pct = (
        round(spent_delta / prev_total_spent * 100, 1) if prev_total_spent else 0.0
    )

    # --- by_category ---
    cat_amounts: dict[str, float] = defaultdict(float)
    cat_counts: dict[str, int] = defaultdict(int)
    cat_txns: dict[str, list[dict]] = defaultdict(list)

    for t in spending_txns:
        cat_id = get_category_id(t.get("category", "Uncategorized"))
        cat_amounts[cat_id] += abs(t["amount"])
        cat_counts[cat_id] += 1
        cat_txns[cat_id].append(t)

    prev_cat_amounts: dict[str, float] = defaultdict(float)
    for t in prev_spending:
        cat_id = get_category_id(t.get("category", "Uncategorized"))
        prev_cat_amounts[cat_id] += abs(t["amount"])

    sorted_cats = sorted(cat_amounts.items(), key=lambda x: x[1], reverse=True)
    by_category = []
    for rank, (cat_id, amount) in enumerate(sorted_cats, 1):
        amount = round(amount, 2)
        cat_name = CATEGORY_ID_TO_NAME.get(cat_id, "Uncategorized")
        prev_amt = round(prev_cat_amounts.get(cat_id, 0), 2)
        cat_delta = round(amount - prev_amt, 2)

        sub_amounts: dict[str, float] = defaultdict(float)
        sub_counts: dict[str, int] = defaultdict(int)
        merchant_amounts: dict[str, float] = defaultdict(float)
        merchant_counts: dict[str, int] = defaultdict(int)

        for t in cat_txns[cat_id]:
            sub_name = t.get("category", "Uncategorized")
            sub_id_candidate = None
            for sub_def in _get_subcategories_for_category(cat_id):
                if sub_def["name"] == sub_name:
                    sub_id_candidate = sub_def["id"]
                    break
            sub_key = sub_id_candidate or "sub_general_misc"
            sub_amounts[sub_key] += abs(t["amount"])
            sub_counts[sub_key] += 1
            merchant_amounts[t["merchant"]] += abs(t["amount"])
            merchant_counts[t["merchant"]] += 1

        subcategories = []
        for idx, (sub_id, sub_amt) in enumerate(
            sorted(sub_amounts.items(), key=lambda x: x[1], reverse=True)
        ):
            sub_name_lookup = None
            for sub_def in _get_subcategories_for_category(cat_id):
                if sub_def["id"] == sub_id:
                    sub_name_lookup = sub_def["name"]
                    break
            subcategories.append(
                {
                    "subcategory_id": sub_id,
                    "subcategory_name": sub_name_lookup or sub_id,
                    "amount": round(sub_amt, 2),
                    "percentage_of_category": _pct(sub_amt, amount),
                    "percentage_of_total": _pct(sub_amt, total_spent),
                    "transaction_count": sub_counts[sub_id],
                    "color": get_subcategory_color(cat_id, idx),
                }
            )

        top_merchants = sorted(
            merchant_amounts.items(), key=lambda x: x[1], reverse=True
        )[:3]
        top_merchants_list = [
            {"merchant": m, "amount": round(a, 2), "count": merchant_counts[m]}
            for m, a in top_merchants
        ]

        by_category.append(
            {
                "category_id": cat_id,
                "category_name": cat_name,
                "amount": amount,
                "percentage": _pct(amount, total_spent),
                "transaction_count": cat_counts[cat_id],
                "daily_average": round(amount / max(days_elapsed, 1), 2),
                "color": CATEGORY_COLORS.get(cat_id, "#A0AEC0"),
                "icon": CATEGORY_ICONS.get(cat_id, "help-circle"),
                "rank": rank,
                "vs_previous_month": {
                    "amount_delta": cat_delta,
                    "amount_delta_pct": round(cat_delta / prev_amt * 100, 1)
                    if prev_amt
                    else 0.0,
                    "direction": _direction(cat_delta),
                },
                "subcategories": subcategories,
                "top_merchants": top_merchants_list,
            }
        )

    # --- daily_series ---
    daily_totals: dict[str, float] = {}
    for day_num in range(1, days_in_month + 1):
        d = date(year, month, day_num)
        if d > today:
            break
        daily_totals[d.isoformat()] = 0.0

    for t in spending_txns:
        d = t["date"]
        if d in daily_totals:
            daily_totals[d] += abs(t["amount"])

    daily_series = []
    cumulative = 0.0
    for d_str in sorted(daily_totals.keys()):
        d = _parse_date(d_str)
        total = round(daily_totals[d_str], 2)
        cumulative = round(cumulative + total, 2)
        daily_series.append(
            {
                "date": d_str,
                "total": total,
                "cumulative": cumulative,
                "day_of_week": d.strftime("%A"),
                "is_weekend": d.weekday() >= 5,
            }
        )

    # --- day_of_week_pattern ---
    dow_totals: dict[int, float] = defaultdict(float)
    dow_counts: dict[int, int] = defaultdict(int)
    day_names = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
    ]

    for entry in daily_series:
        d = _parse_date(entry["date"])
        idx = d.weekday()
        dow_totals[idx] += entry["total"]
        dow_counts[idx] += 1

    day_of_week_pattern = []
    for idx in range(7):
        total = round(dow_totals.get(idx, 0), 2)
        count = dow_counts.get(idx, 0)
        day_of_week_pattern.append(
            {
                "day": day_names[idx],
                "day_index": idx,
                "average": round(total / max(count, 1), 2),
                "total": total,
            }
        )

    return {
        "meta": {
            "user_id": "",  # Filled by router
            "period": {
                "month": month,
                "year": year,
                "label": f"{calendar.month_name[month]} {year}",
                "start_date": start_date.isoformat(),
                "end_date": end_date.isoformat(),
                "days_in_period": days_in_month,
                "days_elapsed": days_elapsed,
            },
            "currency": "USD",
            "generated_at": datetime.now(timezone.utc).isoformat(),
        },
        "summary": {
            "total_spent": total_spent,
            "total_income": total_income,
            "net_cash_flow": net_cash_flow,
            "transaction_count": transaction_count,
            "daily_average": daily_average,
            "vs_previous_month": {
                "total_spent_delta": spent_delta,
                "total_spent_delta_pct": spent_delta_pct,
                "direction": _direction(spent_delta),
            },
        },
        "by_category": by_category,
        "daily_series": daily_series,
        "day_of_week_pattern": day_of_week_pattern,
    }
