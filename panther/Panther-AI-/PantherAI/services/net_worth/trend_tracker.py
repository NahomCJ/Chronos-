"""Historical net worth trend tracking.

The public trend function reads historical snapshots only. It never projects
future values. A daily cron should call ``snapshot_net_worth`` for each active
user and persist the returned row to ``net_worth_history``.
"""

from __future__ import annotations

from copy import deepcopy
from datetime import date, datetime, timedelta, timezone
import os
from typing import Any

from dotenv import load_dotenv

from .aggregation import calculate_net_worth
from .mock_data import normalize_user_id

load_dotenv()

VALID_PERIODS = {"30d": 30, "90d": 90, "365d": 365}

_LOCAL_HISTORY: dict[str, list[dict[str, Any]]] = {}


def get_net_worth_trend(user_id: str, period: str = "90d") -> dict[str, Any]:
    if period not in VALID_PERIODS:
        raise ValueError("period must be one of: 30d, 90d, 365d")

    normalized_user_id = normalize_user_id(user_id)
    history = _history_for_user(normalized_user_id)
    cutoff = date.today() - timedelta(days=VALID_PERIODS[period])
    data_points = [
        {
            "date": item["date"].isoformat(),
            "net_worth": round(float(item["net_worth"]), 2),
        }
        for item in history
        if item["date"] >= cutoff
    ]

    if len(data_points) < 2:
        current = data_points[-1]["net_worth"] if data_points else 0.0
        return {
            "period": period,
            "data_points": data_points,
            "starting_net_worth": current,
            "current_net_worth": current,
            "change_amount": 0.0,
            "change_pct": 0.0,
            "trend": "STABLE",
            "insight": "There is not enough historical net worth data yet to show a reliable trend.",
        }

    starting = float(data_points[0]["net_worth"])
    current = float(data_points[-1]["net_worth"])
    change_amount = round(current - starting, 2)
    change_pct = round((change_amount / abs(starting)) * 100, 2) if starting else 0.0
    trend = _trend(change_pct, change_amount)

    return {
        "period": period,
        "data_points": data_points,
        "starting_net_worth": round(starting, 2),
        "current_net_worth": round(current, 2),
        "change_amount": change_amount,
        "change_pct": change_pct,
        "trend": trend,
        "insight": _insight(period, change_amount, change_pct, trend),
    }


def snapshot_net_worth(user_id: str) -> dict[str, Any]:
    """Creates today's net worth history row for the scheduled job."""

    normalized_user_id = normalize_user_id(user_id)
    net_worth = calculate_net_worth(normalized_user_id)
    row = {
        "user_id": normalized_user_id,
        "date": date.today(),
        "net_worth": net_worth["net_worth"],
        "total_assets": net_worth["total_assets"],
        "total_liabilities": net_worth["total_liabilities"],
        "data_completeness": net_worth["data_completeness"],
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    _persist_snapshot(row, net_worth)
    history = _history_for_user(normalized_user_id)
    _LOCAL_HISTORY[normalized_user_id] = [
        item for item in history if item["date"] != row["date"]
    ] + [row]
    _LOCAL_HISTORY[normalized_user_id].sort(key=lambda item: item["date"])
    return deepcopy(row)


def _history_for_user(user_id: str) -> list[dict[str, Any]]:
    supabase_history = _history_from_supabase(user_id)
    if supabase_history is not None:
        return deepcopy(supabase_history)
    if user_id not in _LOCAL_HISTORY:
        _LOCAL_HISTORY[user_id] = _build_mock_history(user_id)
    return deepcopy(_LOCAL_HISTORY[user_id])


def _history_from_supabase(user_id: str) -> list[dict[str, Any]] | None:
    sb = _get_supabase()
    if not sb:
        return None

    try:
        res = (
            sb.table("net_worth_history")
            .select(
                "snapshot_date,net_worth,total_assets,total_liabilities,"
                "data_completeness,created_at"
            )
            .eq("user_id", user_id)
            .order("snapshot_date")
            .execute()
        )
    except Exception:
        return None

    rows = []
    for item in res.data or []:
        snapshot_date = _parse_date(item.get("snapshot_date"))
        if not snapshot_date:
            continue
        rows.append(
            {
                "date": snapshot_date,
                "net_worth": float(item.get("net_worth") or 0.0),
                "total_assets": float(item.get("total_assets") or 0.0),
                "total_liabilities": float(item.get("total_liabilities") or 0.0),
                "data_completeness": float(item.get("data_completeness") or 0.0),
                "created_at": item.get("created_at"),
            }
        )
    return rows


def _persist_snapshot(row: dict[str, Any], net_worth: dict[str, Any]) -> None:
    sb = _get_supabase()
    if not sb:
        return

    try:
        sb.table("net_worth_history").upsert(
            {
                "user_id": row["user_id"],
                "snapshot_date": row["date"].isoformat(),
                "net_worth": row["net_worth"],
                "total_assets": row["total_assets"],
                "total_liabilities": row["total_liabilities"],
                "data_completeness": row["data_completeness"],
                "missing_sources": net_worth.get("missing_sources", []),
            },
            on_conflict="user_id,snapshot_date",
        ).execute()
    except Exception:
        return


def _get_supabase():
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    if not url or not key:
        return None
    try:
        from supabase import create_client

        return create_client(url, key)
    except Exception:
        return None


def _parse_date(value: Any) -> date | None:
    if not value:
        return None
    if isinstance(value, date):
        return value
    try:
        return date.fromisoformat(str(value)[:10])
    except ValueError:
        return None


def _build_mock_history(user_id: str) -> list[dict[str, Any]]:
    current = float(calculate_net_worth(user_id)["net_worth"])
    days = 365
    daily_delta = {
        "user_marcus": -38.0,
        "user_sarah": 42.0,
        "user_bob": 6.0,
    }.get(user_id, 0.0)
    today = date.today()
    rows = []
    for offset in range(days, -1, -1):
        row_date = today - timedelta(days=offset)
        net_worth = current - (daily_delta * offset)
        rows.append({"date": row_date, "net_worth": round(net_worth, 2)})
    return rows


def _trend(change_pct: float, change_amount: float) -> str:
    if abs(change_pct) < 1.0 or abs(change_amount) < 100:
        return "STABLE"
    if change_amount > 0:
        return "IMPROVING"
    return "DECLINING"


def _insight(period: str, change_amount: float, change_pct: float, trend: str) -> str:
    days = VALID_PERIODS[period]
    if trend == "STABLE":
        return f"Your connected net worth has been broadly stable over the last {days} days."
    direction = "increased" if change_amount > 0 else "decreased"
    return (
        f"Your connected net worth has {direction} by £{abs(change_amount):,.2f} "
        f"({abs(change_pct):.2f}%) over the last {days} days."
    )
