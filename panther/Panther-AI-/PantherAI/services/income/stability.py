"""Income stability analysis."""

from __future__ import annotations

from collections import defaultdict
from datetime import date
from statistics import mean, pstdev
from typing import Any

from services.income.ingestion import get_income_data, normalize_user_id


def analyze_income_stability(user_id: str) -> dict[str, Any]:
    data = get_income_data(user_id)
    normalized_user_id = normalize_user_id(user_id)
    events = _events(data)

    if not events:
        return {
            "user_id": normalized_user_id,
            "stability_score": 0.0,
            "stability_status": "IRREGULAR",
            "average_monthly_income": 0.0,
            "income_variance_pct": 0.0,
            "months_analyzed": 0,
            "income_trend": "INSUFFICIENT_DATA",
            "last_income_date": None,
            "expected_next_income_date": None,
            "missed_income_events": 0,
            "insight": "No regular income pattern has been detected yet.",
        }

    ordered = sorted(events, key=lambda item: item["date"])
    amounts = [float(item["amount"]) for item in ordered]
    dates = [date.fromisoformat(str(item["date"])[:10]) for item in ordered]
    months_analyzed = _months_analyzed(dates)
    average_monthly = round(
        float(data.get("estimated_monthly_income") or sum(amounts) / months_analyzed),
        2,
    )
    variance_pct = _variance_pct(amounts)
    timing_variance = _timing_variance_days(dates)
    source_count = len({item.get("source_id") for item in ordered if item.get("source_id")})
    missed_events = _missed_monthly_events(dates) if _looks_monthly(dates) else 0

    score = _score(
        income_type=str(data.get("income_type") or "UNKNOWN"),
        variance_pct=variance_pct,
        timing_variance_days=timing_variance,
        source_count=source_count,
        missed_events=missed_events,
        event_count=len(ordered),
    )
    status = _status(score)
    expected_next = _expected_next_income_date(dates, status)

    return {
        "user_id": normalized_user_id,
        "stability_score": round(score, 1),
        "stability_status": status,
        "average_monthly_income": average_monthly,
        "income_variance_pct": round(variance_pct, 1),
        "months_analyzed": months_analyzed,
        "income_trend": _trend(ordered),
        "last_income_date": dates[-1],
        "expected_next_income_date": expected_next,
        "missed_income_events": missed_events,
        "insight": _insight(status, dates, average_monthly, expected_next),
    }


def _events(data: dict[str, Any]) -> list[dict[str, Any]]:
    return [
        event
        for event in data.get("income_events", [])
        if float(event.get("amount") or 0.0) > 0 and event.get("date")
    ]


def _months_analyzed(dates: list[date]) -> int:
    if not dates:
        return 0
    first = min(dates)
    last = max(dates)
    return max((last.year - first.year) * 12 + last.month - first.month + 1, 1)


def _variance_pct(amounts: list[float]) -> float:
    if len(amounts) < 2:
        return 0.0
    avg = mean(amounts)
    if avg <= 0:
        return 0.0
    return pstdev(amounts) / avg * 100


def _timing_variance_days(dates: list[date]) -> float:
    if len(dates) < 3:
        return 0.0
    intervals = [(b - a).days for a, b in zip(dates, dates[1:])]
    return pstdev(intervals)


def _score(
    income_type: str,
    variance_pct: float,
    timing_variance_days: float,
    source_count: int,
    missed_events: int,
    event_count: int,
) -> float:
    if event_count == 0:
        return 0.0
    score = 100.0
    score -= min(variance_pct * 0.9, 35.0)
    score -= min(timing_variance_days * 1.3, 30.0)
    score -= max(source_count - 1, 0) * 8
    score -= missed_events * 12
    if event_count < 3:
        score = min(score, 35.0)
    if income_type == "IRREGULAR":
        score = min(score, 48.0)
    elif income_type == "MIXED":
        score = min(score, 72.0)
    elif income_type == "UNKNOWN":
        score = min(score, 20.0)
    return max(score, 0.0)


def _status(score: float) -> str:
    if score >= 80:
        return "STABLE"
    if score >= 60:
        return "MODERATE"
    if score >= 40:
        return "VOLATILE"
    return "IRREGULAR"


def _looks_monthly(dates: list[date]) -> bool:
    if len(dates) < 3:
        return False
    ordered = sorted(dates)
    days = [item.day for item in ordered]
    day_variance = pstdev(days) if len(days) > 1 else 0.0
    intervals = [(b - a).days for a, b in zip(ordered, ordered[1:])]
    return bool(intervals) and day_variance <= 3 and all(24 <= item <= 35 for item in intervals)


def _missed_monthly_events(dates: list[date]) -> int:
    if not dates:
        return 0
    by_month = {(item.year, item.month) for item in dates}
    first = min(dates)
    last = max(dates)
    missed = 0
    month_index = first.year * 12 + first.month - 1
    last_index = last.year * 12 + last.month - 1
    while month_index <= last_index:
        year = month_index // 12
        month = month_index % 12 + 1
        if (year, month) not in by_month:
            missed += 1
        month_index += 1
    return missed


def _expected_next_income_date(dates: list[date], status: str) -> date | None:
    if status not in {"STABLE", "MODERATE"} or not _looks_monthly(dates):
        return None
    day = round(mean([item.day for item in dates]))
    last = max(dates)
    month_index = last.year * 12 + last.month
    year = month_index // 12
    month = month_index % 12 + 1
    max_day = _days_in_month(year, month)
    return date(year, month, min(day, max_day))


def _trend(events: list[dict[str, Any]]) -> str:
    if len(events) < 3:
        return "INSUFFICIENT_DATA"
    monthly: dict[tuple[int, int], float] = defaultdict(float)
    for event in events:
        event_date = date.fromisoformat(str(event["date"])[:10])
        monthly[(event_date.year, event_date.month)] += float(event["amount"])
    totals = [total for _, total in sorted(monthly.items())]
    if len(totals) < 3:
        return "INSUFFICIENT_DATA"
    midpoint = len(totals) // 2
    earlier = mean(totals[:midpoint])
    later = mean(totals[midpoint:])
    if earlier <= 0:
        return "INSUFFICIENT_DATA"
    change_pct = (later - earlier) / earlier * 100
    if change_pct > 5:
        return "INCREASING"
    if change_pct < -5:
        return "DECREASING"
    return "FLAT"


def _insight(
    status: str, dates: list[date], average_monthly: float, expected_next: date | None
) -> str:
    if status == "STABLE" and expected_next:
        day = round(mean([item.day for item in dates]))
        return (
            f"Your income has been consistent over the last {len(dates)} events, "
            f"arriving around the {_ordinal(day)} of each month."
        )
    if status == "MODERATE" and expected_next:
        return "Your income is regular, with some variation in timing or amount."
    if status == "VOLATILE":
        return "Your income has varied across recent months, so the next pay date is not predictable yet."
    if average_monthly <= 0:
        return "No regular income pattern has been detected yet."
    return "Your income pattern is irregular, so Panther cannot estimate a reliable next income date yet."


def _days_in_month(year: int, month: int) -> int:
    if month == 12:
        next_month = date(year + 1, 1, 1)
    else:
        next_month = date(year, month + 1, 1)
    return (next_month - date(year, month, 1)).days


def _ordinal(day: int) -> str:
    if 10 <= day % 100 <= 20:
        suffix = "th"
    else:
        suffix = {1: "st", 2: "nd", 3: "rd"}.get(day % 10, "th")
    return f"{day}{suffix}"
