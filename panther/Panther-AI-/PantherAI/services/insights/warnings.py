"""
services/insights/warnings.py
===============================
Warnings history computation for the Dashboard Insights API.

Pure functions. No I/O. Takes raw warning records in, returns a chart-ready
dict with risk summary, enriched warnings (date labels, colors), and a
calendar heatmap. The router is responsible for fetching data (via
`services.insights.data`) and filling `meta.user_id`.

Response shape:
    {"meta": {...}, "risk_summary": {...}, "warnings": [...],
     "calendar_heatmap": [...]}
"""

from __future__ import annotations

import calendar
from collections import defaultdict
from datetime import date, datetime, timedelta, timezone
from typing import Any

from services.insights.constants import RISK_COLORS
from services.insights.helpers import _direction, _pct


def compile_warnings_history(
    warnings: list[dict[str, Any]],
    limit: int,
    offset: int = 0,
    *,
    now: datetime | None = None,
) -> dict[str, Any]:
    """
    Compiles raw warning records into a chart-ready response with risk summary, date labels, and calendar heatmap.

    Args:
        warnings (list[dict]): Raw warning records sorted newest-first. Each dict must have:
            "id" (str), "timestamp" (str ISO with Z suffix), "source" ("cash_flow"|"bnpl"),
            "risk_level" ("HIGH"|"MEDIUM"|"LOW"), "title" (str), "message" (str),
            "context" (dict, varies by source), "outcome" (dict with "user_action").
        limit (int): Max warnings per page (1-100).
        offset (int): Pagination offset (default 0).
        now (datetime | None): Anchor timestamp for date_label computation and trend windows.
            Defaults to datetime.now(UTC). The router passes the latest warning timestamp
            when using mock data.

    Returns:
        dict: {"meta": {pagination}, "risk_summary": {by_level with colors, by_source, trend_last_30d},
            "warnings": [enriched with date_label, risk_color, risk_icon],
            "calendar_heatmap": [one entry per day in current month]}
            The "meta.user_id" field is empty — the router fills it.
    """
    # ADR: date_label is computed server-side ("Today", "2 days ago", "Feb 10")
    # to prevent timezone mismatch bugs between server and client. The server
    # owns the clock. This also means the frontend never needs moment.js or
    # date-fns for relative-time formatting on warning entries.
    total = len(warnings)

    # Risk summary
    by_level: dict[str, int] = {"HIGH": 0, "MEDIUM": 0, "LOW": 0}
    by_source: dict[str, int] = defaultdict(int)
    for w in warnings:
        level = w.get("risk_level", "LOW")
        by_level[level] = by_level.get(level, 0) + 1
        by_source[w.get("source", "unknown")] += 1

    # Trend: warnings in last 30d vs previous 30d
    now = now or datetime.now(timezone.utc)
    thirty_days_ago = now - timedelta(days=30)
    sixty_days_ago = now - timedelta(days=60)

    recent_count = sum(
        1
        for w in warnings
        if datetime.fromisoformat(w["timestamp"].replace("Z", "+00:00"))
        >= thirty_days_ago
    )
    prev_count = sum(
        1
        for w in warnings
        if sixty_days_ago
        <= datetime.fromisoformat(w["timestamp"].replace("Z", "+00:00"))
        < thirty_days_ago
    )
    count_delta = recent_count - prev_count

    # Paginate
    paginated = warnings[offset : offset + limit]

    # Add computed fields to each warning
    enriched_warnings = []
    for w in paginated:
        ts = datetime.fromisoformat(w["timestamp"].replace("Z", "+00:00"))
        days_ago = (now - ts).days

        if days_ago == 0:
            date_label = "Today"
        elif days_ago == 1:
            date_label = "Yesterday"
        elif days_ago < 7:
            date_label = f"{days_ago} days ago"
        else:
            date_label = ts.strftime("%b %d")

        risk_level = w.get("risk_level", "LOW")
        enriched_warnings.append(
            {
                "id": w["id"],
                "timestamp": w["timestamp"],
                "date_label": date_label,
                "source": w.get("source", "unknown"),
                "risk_level": risk_level,
                "risk_color": RISK_COLORS.get(risk_level, "#38A169"),
                "risk_icon": {
                    "HIGH": "shield-alert",
                    "MEDIUM": "alert-triangle",
                    "LOW": "info",
                }.get(risk_level, "info"),
                "title": w.get("title", ""),
                "message": w.get("message", ""),
                "context": w.get("context", {}),
                "outcome": w.get("outcome", {}),
            }
        )

    # Calendar heatmap — current month
    month_days = calendar.monthrange(now.year, now.month)[1]

    # Build daily warning counts
    daily_warnings: dict[str, list[str]] = defaultdict(list)
    for w in warnings:
        ts = datetime.fromisoformat(w["timestamp"].replace("Z", "+00:00"))
        d = ts.date().isoformat()
        daily_warnings[d].append(w.get("risk_level", "LOW"))

    severity_rank = {"HIGH": 3, "MEDIUM": 2, "LOW": 1}
    calendar_heatmap = []
    for day_num in range(1, month_days + 1):
        d = date(now.year, now.month, day_num)
        if d > now.date():
            break
        d_str = d.isoformat()
        levels = daily_warnings.get(d_str, [])
        max_severity = (
            max(levels, key=lambda lv: severity_rank.get(lv, 0)) if levels else None
        )
        calendar_heatmap.append(
            {
                "date": d_str,
                "warning_count": len(levels),
                "max_severity": max_severity,
            }
        )

    return {
        "meta": {
            "user_id": "",  # Filled by router
            "pagination": {
                "limit": limit,
                "offset": offset,
                "total": total,
                "has_more": offset + limit < total,
            },
            "generated_at": now.isoformat(),
        },
        "risk_summary": {
            "total_warnings": total,
            "by_level": {
                level: {
                    "count": count,
                    "percentage": _pct(count, total),
                    "color": RISK_COLORS.get(level, "#38A169"),
                }
                for level, count in by_level.items()
            },
            "by_source": dict(by_source),
            "trend_last_30d": {
                "warnings_count": recent_count,
                "vs_previous_30d": {
                    "count_delta": count_delta,
                    "direction": _direction(count_delta),
                },
            },
        },
        "warnings": enriched_warnings,
        "calendar_heatmap": calendar_heatmap,
    }
