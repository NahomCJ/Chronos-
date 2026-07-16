"""
Recurring charge detection for subscription and fixed-bill patterns.

The service describes recurring transaction patterns in the user's own data.
It does not recommend cancellation or any other financial action.
"""

from __future__ import annotations

import calendar
import os
import re
from collections import defaultdict
from dataclasses import dataclass
from datetime import date, datetime, timedelta, timezone
from statistics import median
from typing import Any, Iterable

from dotenv import load_dotenv

from core.logger import log
from services.banking.mock_api import get_transactions

load_dotenv()

AMOUNT_TOLERANCE = 1.00
RETENTION_DAYS = 90

_LOCAL_RECURRING_CHARGES: dict[str, list[dict[str, Any]]] = {}
_KNOWN_MERCHANT_DISPLAY = {
    "NETFLIX": "Netflix",
    "SPOTIFY": "Spotify",
    "LANDLORD PMT": "Rent",
    "RENT": "Rent",
    "MONTHLY RENT PAYMENT": "Rent",
}
_RENT_TERMS = {"LANDLORD", "RENT", "PROPERTY MGMT", "PROPERTY MANAGEMENT"}


@dataclass(frozen=True)
class _ChargeCluster:
    merchant_key: str
    display_merchant: str
    transactions: list[dict[str, Any]]


def detect_subscriptions(user_id: str, persist: bool = True) -> list[dict[str, Any]]:
    """
    Detect recurring charges for a user.

    Args:
        user_id: User identifier.
        persist: When True, writes the detected result to `recurring_charges`.

    Returns:
        List of recurring charges:
        `{merchant, amount, frequency, next_charge_date, months_active}`.
    """
    transactions = get_transactions(user_id, days_back=370)
    charges = _detect_from_transactions(transactions)

    if persist:
        _persist_recurring_charges(user_id, charges)

    return charges


def get_cached_recurring_charges(user_id: str) -> list[dict[str, Any]]:
    """Returns the last locally persisted detection result for offline/mock mode."""
    return list(_LOCAL_RECURRING_CHARGES.get(user_id, []))


def _detect_from_transactions(transactions: Iterable[dict[str, Any]]) -> list[dict[str, Any]]:
    debits = [
        t
        for t in transactions
        if _amount(t) < 0 and t.get("merchant") and t.get("date")
    ]
    groups: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for txn in debits:
        groups[_merchant_key(str(txn["merchant"]))].append(txn)

    candidates: list[dict[str, Any]] = []
    for merchant_key, rows in groups.items():
        for cluster in _cluster_by_amount(merchant_key, rows):
            detected = _detect_cluster(cluster)
            if detected:
                candidates.append(detected)

    candidates.sort(
        key=lambda c: (
            _frequency_rank(c["frequency"]),
            c["next_charge_date"] or "9999-12-31",
            c["merchant"],
        )
    )
    return candidates


def _cluster_by_amount(merchant_key: str, rows: list[dict[str, Any]]) -> list[_ChargeCluster]:
    sorted_rows = sorted(rows, key=lambda t: abs(_amount(t)))
    clusters: list[list[dict[str, Any]]] = []

    for txn in sorted_rows:
        amount = abs(_amount(txn))
        for cluster in clusters:
            cluster_amount = median(abs(_amount(row)) for row in cluster)
            if abs(amount - cluster_amount) <= AMOUNT_TOLERANCE:
                cluster.append(txn)
                break
        else:
            clusters.append([txn])

    display = _display_merchant(merchant_key, rows)
    return [
        _ChargeCluster(merchant_key=merchant_key, display_merchant=display, transactions=cluster)
        for cluster in clusters
        if len(cluster) >= 2
    ]


def _detect_cluster(cluster: _ChargeCluster) -> dict[str, Any] | None:
    rows = sorted(cluster.transactions, key=lambda t: _date(t))
    unique_dates = sorted({_date(t) for t in rows})
    if len(unique_dates) < 2:
        return None

    intervals = [
        (later - earlier).days
        for earlier, later in zip(unique_dates, unique_dates[1:])
        if (later - earlier).days > 0
    ]
    if not intervals:
        return None

    frequency = _classify_frequency(intervals)
    if not frequency:
        return None

    amount = round(float(median(abs(_amount(t)) for t in rows)), 2)
    next_charge = _next_charge_date(unique_dates, frequency)
    months_active = _months_active(unique_dates[0], unique_dates[-1], frequency)

    return {
        "merchant": cluster.display_merchant,
        "amount": amount,
        "frequency": frequency,
        "next_charge_date": next_charge.isoformat() if next_charge else None,
        "months_active": months_active,
    }


def _classify_frequency(intervals: list[int]) -> str | None:
    typical = median(intervals)
    if 5 <= typical <= 9:
        return "weekly"
    if 24 <= typical <= 35:
        return "monthly"
    if 80 <= typical <= 100:
        return "quarterly"
    if 330 <= typical <= 400:
        return "annual"
    return None


def _next_charge_date(observed_dates: list[date], frequency: str) -> date | None:
    today = date.today()
    last_date = observed_dates[-1]

    if frequency == "weekly":
        candidate = last_date + timedelta(days=7)
        while candidate <= today:
            candidate += timedelta(days=7)
        return candidate

    if frequency == "monthly":
        day = _modal_day(observed_dates)
        candidate = _date_with_clamped_day(today.year, today.month, day)
        if candidate <= today:
            candidate = _add_months(candidate, 1, day)
        return candidate

    if frequency == "quarterly":
        day = _modal_day(observed_dates)
        candidate = _date_with_clamped_day(last_date.year, last_date.month, day)
        while candidate <= today:
            candidate = _add_months(candidate, 3, day)
        return candidate

    if frequency == "annual":
        month = _modal_month(observed_dates)
        day = _modal_day(observed_dates)
        candidate = _date_with_clamped_day(today.year, month, day)
        if candidate <= today:
            candidate = _date_with_clamped_day(today.year + 1, month, day)
        return candidate

    return None


def _persist_recurring_charges(user_id: str, charges: list[dict[str, Any]]) -> None:
    sb = _get_supabase()
    if not sb:
        _LOCAL_RECURRING_CHARGES[user_id] = list(charges)
        return

    try:
        account = sb.table("accounts").select("id").eq("user_id", user_id).execute()
        if not account.data:
            raise ValueError(f"Unknown user: {user_id}")
        account_id = account.data[0]["id"]

        cutoff = (datetime.now(timezone.utc) - timedelta(days=RETENTION_DAYS)).isoformat()
        (
            sb.table("recurring_charges")
            .delete()
            .eq("account_id", account_id)
            .lt("detected_at", cutoff)
            .execute()
        )
        sb.table("recurring_charges").delete().eq("account_id", account_id).execute()

        rows = [
            {
                "account_id": account_id,
                "merchant": charge["merchant"],
                "amount": charge["amount"],
                "frequency": _db_frequency(charge["frequency"]),
                "next_expected_date": charge["next_charge_date"],
                "detected_at": datetime.now(timezone.utc).isoformat(),
            }
            for charge in charges
        ]
        if rows:
            sb.table("recurring_charges").insert(rows).execute()
    except Exception as exc:
        log.failure(
            "detect_subscriptions.persist",
            error_type=type(exc).__name__,
            message=str(exc),
            user_id=user_id,
            detail="Supabase recurring_charges write failed; using local cache",
        )
        _LOCAL_RECURRING_CHARGES[user_id] = list(charges)


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


def _amount(txn: dict[str, Any]) -> float:
    return float(txn.get("amount") or 0.0)


def _date(txn: dict[str, Any]) -> date:
    return date.fromisoformat(str(txn["date"])[:10])


def _merchant_key(merchant: str) -> str:
    upper = re.sub(r"[^A-Z0-9& ]+", " ", merchant.upper())
    upper = re.sub(r"\b(?:PMT|PAYMENT|AUTOPAY|RECURRING|CARD|ONLINE)\b", " ", upper)
    upper = re.sub(r"\b\d+\b", " ", upper)
    upper = re.sub(r"\s+", " ", upper).strip()
    if any(term in upper for term in _RENT_TERMS):
        return "RENT"
    return upper


def _display_merchant(merchant_key: str, rows: list[dict[str, Any]]) -> str:
    if merchant_key in _KNOWN_MERCHANT_DISPLAY:
        return _KNOWN_MERCHANT_DISPLAY[merchant_key]

    original = str(rows[0].get("merchant") or merchant_key)
    normalized = _merchant_key(original)
    if normalized in _KNOWN_MERCHANT_DISPLAY:
        return _KNOWN_MERCHANT_DISPLAY[normalized]
    return normalized.title()


def _frequency_rank(frequency: str) -> int:
    return {"weekly": 0, "monthly": 1, "quarterly": 2, "annual": 3}.get(frequency, 9)


def _months_active(first: date, last: date, frequency: str) -> int:
    if frequency == "weekly":
        return max(1, round((last - first).days / 30) + 1)
    return max(1, (last.year - first.year) * 12 + last.month - first.month + 1)


def _modal_day(dates: list[date]) -> int:
    counts: dict[int, int] = defaultdict(int)
    for observed in dates:
        counts[observed.day] += 1
    return max(counts.items(), key=lambda item: (item[1], item[0]))[0]


def _modal_month(dates: list[date]) -> int:
    counts: dict[int, int] = defaultdict(int)
    for observed in dates:
        counts[observed.month] += 1
    return max(counts.items(), key=lambda item: (item[1], item[0]))[0]


def _date_with_clamped_day(year: int, month: int, day: int) -> date:
    max_day = calendar.monthrange(year, month)[1]
    return date(year, month, min(day, max_day))


def _add_months(value: date, months: int, preferred_day: int) -> date:
    month_index = value.month - 1 + months
    year = value.year + month_index // 12
    month = month_index % 12 + 1
    return _date_with_clamped_day(year, month, preferred_day)


def _db_frequency(frequency: str) -> str:
    return {"annual": "yearly"}.get(frequency, frequency)
