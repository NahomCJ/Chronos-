"""
Income ingestion from Plaid Income with local demo fallback.

Payroll data is treated as maximum-sensitivity data. This module minimizes
Plaid payloads immediately, persists only bracketed ranges for payroll-derived
amounts, and logs sync source/status without salary values.
"""

from __future__ import annotations

import calendar
import os
from copy import deepcopy
from datetime import date, datetime, timedelta, timezone
from typing import Any

from dotenv import load_dotenv

from core.logger import log

load_dotenv()

SYNC_TTL_SECONDS = 6 * 60 * 60
PAYROLL_RETENTION_DAYS = 60
UNKNOWN_INCOME_TYPE = "UNKNOWN"

_SYNC_CACHE: dict[str, tuple[datetime, dict[str, Any]]] = {}
_LOCAL_SANITIZED_INCOME: dict[str, dict[str, Any]] = {}
_LOCAL_SYNC_AUDIT: list[dict[str, Any]] = []


class IncomeConsentError(PermissionError):
    """Raised when a user has not authorized Plaid Income access."""


def sync_income(user_id: str, force: bool = False) -> dict[str, Any]:
    """
    Syncs payroll and bank income data, with payroll taking priority.

    Returns numeric values for authenticated internal service/API use. The
    persisted local/Supabase snapshot is sanitized and bracketed.
    """
    normalized_user_id = normalize_user_id(user_id)
    if _is_unknown_local_user(normalized_user_id):
        raise ValueError(f"Unknown user: {normalized_user_id}")
    if not has_income_consent(normalized_user_id):
        raise IncomeConsentError("Plaid Income product is not authorized")

    cached = _SYNC_CACHE.get(normalized_user_id)
    if not force and cached:
        cached_at, data = cached
        if (datetime.now(timezone.utc) - cached_at).total_seconds() < SYNC_TTL_SECONDS:
            return deepcopy(data)

    log.contract("sync_income", user_id=normalized_user_id)

    payroll_payload, bank_payload = _fetch_plaid_income(normalized_user_id)
    if payroll_payload or bank_payload:
        data = _extract_plaid_income(normalized_user_id, payroll_payload, bank_payload)
    elif normalized_user_id in _LOCAL_INCOME_FIXTURES:
        data = _mock_income(normalized_user_id)
    else:
        data = _unknown_income(normalized_user_id)

    data["user_id"] = normalized_user_id
    data["synced_at"] = datetime.now(timezone.utc).isoformat()
    data["retention_expires_at"] = (
        datetime.now(timezone.utc) + timedelta(days=PAYROLL_RETENTION_DAYS)
    ).isoformat()

    _persist_income(normalized_user_id, data)
    _audit_income_sync(normalized_user_id, data)
    _SYNC_CACHE[normalized_user_id] = (datetime.now(timezone.utc), deepcopy(data))
    return deepcopy(data)


def get_income_data(user_id: str) -> dict[str, Any]:
    """Returns cached/synced income data for service-layer analysis."""
    return sync_income(user_id)


def has_income_consent(user_id: str) -> bool:
    normalized_user_id = normalize_user_id(user_id)
    if normalized_user_id in _LOCAL_INCOME_CONSENT:
        return _LOCAL_INCOME_CONSENT[normalized_user_id]

    sb = _get_supabase()
    if not sb:
        return False

    try:
        res = (
            sb.table("plaid_tokens")
            .select("*")
            .eq("user_id", normalized_user_id)
            .execute()
        )
        if not res.data:
            return False
        row = res.data[0]
        products = row.get("products") or row.get("authorized_products")
        if products is None:
            return bool(row.get("income_authorized"))
        if isinstance(products, str):
            products = [part.strip() for part in products.split(",")]
        if isinstance(products, dict):
            products = products.values()
        product_set = {str(product).lower() for product in products}
        return bool({"income", "income_verification"} & product_set)
    except Exception as exc:
        log.failure(
            "has_income_consent",
            error_type=type(exc).__name__,
            message=str(exc),
            user_id=normalized_user_id,
        )
        return False


def normalize_user_id(user_id: str) -> str:
    value = str(user_id or "").strip().lower()
    if value.startswith("user_"):
        return value
    return f"user_{value}"


def bracket_annual_income(annual_income: float | int | None) -> str:
    """Converts an exact annualized income value into a coarse range."""
    amount = max(float(annual_income or 0.0), 0.0)
    if amount <= 0:
        return "GBP 0 range"
    lower = int(amount // 10_000) * 10
    upper = lower + 10
    return f"GBP {lower}k-{upper}k range"


def bracket_monthly_income(monthly_income: float | int | None) -> str:
    return bracket_annual_income(float(monthly_income or 0.0) * 12)


def _is_unknown_local_user(user_id: str) -> bool:
    return user_id not in _LOCAL_INCOME_CONSENT and _get_supabase() is None


def _fetch_plaid_income(user_id: str) -> tuple[dict[str, Any] | None, dict[str, Any] | None]:
    user_token = _get_income_user_token(user_id)
    if not user_token:
        return None, None

    try:
        from plaid.model.credit_bank_income_get_request import CreditBankIncomeGetRequest
        from plaid.model.credit_payroll_income_get_request import (
            CreditPayrollIncomeGetRequest,
        )
        from services.banking.plaid_client import get_plaid_client

        client = get_plaid_client()
        payroll = client.credit_payroll_income_get(
            CreditPayrollIncomeGetRequest(user_token=user_token)
        )
        bank = client.credit_bank_income_get(
            CreditBankIncomeGetRequest(user_token=user_token)
        )
        return _to_dict(payroll), _to_dict(bank)
    except Exception as exc:
        log.failure(
            "_fetch_plaid_income",
            error_type=type(exc).__name__,
            message=str(exc),
            user_id=user_id,
            detail="Plaid Income fetch failed; falling back when local fixtures exist",
        )
        return None, None


def _extract_plaid_income(
    user_id: str,
    payroll_payload: dict[str, Any] | None,
    bank_payload: dict[str, Any] | None,
) -> dict[str, Any]:
    payroll_sources, payroll_events, payroll_rows = _extract_payroll(payroll_payload)
    bank_sources, bank_events = _extract_bank_income(bank_payload)

    primary_sources = payroll_sources or bank_sources
    income_sources = payroll_sources + bank_sources
    events = payroll_events or bank_events
    estimated_monthly = _estimated_monthly_income(primary_sources, events)
    income_type = _classify_income_type(payroll_sources, bank_sources, events)

    return {
        "income_sources": income_sources,
        "payroll_data": payroll_rows or None,
        "estimated_monthly_income": round(estimated_monthly, 2),
        "gross_monthly_income": round(estimated_monthly, 2),
        "income_type": income_type,
        "has_payroll_connection": bool(payroll_sources),
        "income_events": sorted(events, key=lambda item: item["date"]),
        "data_source": "PLAID_PAYROLL" if payroll_sources else "PLAID_BANK" if bank_sources else "NONE",
        "source_priority": "PAYROLL" if payroll_sources else "BANK" if bank_sources else "NONE",
        "mock": False,
    }


def _extract_payroll(
    payload: dict[str, Any] | None,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[dict[str, Any]]]:
    if not payload:
        return [], [], []

    payroll_items = payload.get("payroll_income") or payload.get("items") or []
    if isinstance(payroll_items, dict):
        payroll_items = [payroll_items]

    sources: list[dict[str, Any]] = []
    events: list[dict[str, Any]] = []
    payroll_rows: list[dict[str, Any]] = []

    for index, item in enumerate(payroll_items):
        pay_stubs = item.get("pay_stubs") or item.get("paystubs") or []
        if isinstance(pay_stubs, dict):
            pay_stubs = [pay_stubs]
        pay_frequency = _clean_frequency(item.get("pay_frequency"))
        source_id = str(item.get("account_id") or f"payroll_{index + 1}")

        monthly_values = []
        for stub in pay_stubs:
            gross = _amount_from_stub(stub, gross=True)
            net = _amount_from_stub(stub, gross=False)
            pay_date = _first_date(
                stub.get("pay_date"),
                stub.get("pay_period_end_date"),
                stub.get("pay_period_start_date"),
            )
            stub_frequency = _clean_frequency(stub.get("pay_frequency")) or pay_frequency
            pay_frequency = pay_frequency or stub_frequency
            monthly = _monthly_from_pay_amount(gross or net, stub_frequency)
            if monthly > 0:
                monthly_values.append(monthly)
            if pay_date and (gross or net):
                events.append(
                    {
                        "source_id": source_id,
                        "source_type": "PAYROLL",
                        "income_category": "SALARY",
                        "amount": round(float(gross or net), 2),
                        "date": pay_date.isoformat(),
                        "pay_frequency": stub_frequency or "UNKNOWN",
                    }
                )

            payroll_rows.append(
                {
                    "source_id": source_id,
                    "pay_period_start_date": _iso_date(stub.get("pay_period_start_date")),
                    "pay_period_end_date": _iso_date(stub.get("pay_period_end_date")),
                    "pay_frequency": stub_frequency or "UNKNOWN",
                    "gross_earnings_range": bracket_annual_income(monthly * 12),
                    "net_earnings_range": bracket_annual_income(
                        _monthly_from_pay_amount(net, stub_frequency) * 12
                    ),
                }
            )

        monthly_income = _average(monthly_values)
        if monthly_income > 0:
            sources.append(
                {
                    "source_id": source_id,
                    "source_type": "PAYROLL",
                    "income_category": "SALARY",
                    "monthly_income": round(monthly_income, 2),
                    "monthly_income_range": bracket_monthly_income(monthly_income),
                    "pay_frequency": pay_frequency or "UNKNOWN",
                    "transaction_count": len(pay_stubs),
                    "start_date": min((event["date"] for event in events), default=None),
                }
            )

    return sources, events, payroll_rows


def _extract_bank_income(
    payload: dict[str, Any] | None,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    if not payload:
        return [], []

    items = payload.get("bank_income") or payload.get("items") or []
    if isinstance(items, dict):
        items = [items]

    sources: list[dict[str, Any]] = []
    events: list[dict[str, Any]] = []
    for item_index, item in enumerate(items):
        income_sources = item.get("income_sources") or []
        if isinstance(income_sources, dict):
            income_sources = [income_sources]
        for source_index, source in enumerate(income_sources):
            source_id = str(
                source.get("income_source_id")
                or source.get("source_id")
                or f"bank_{item_index + 1}_{source_index + 1}"
            )
            monthly_income = _float(
                source.get("monthly_income"),
                _monthly_from_total(
                    source.get("total_amount"),
                    source.get("start_date"),
                    source.get("end_date"),
                ),
            )
            category = _map_bank_category(source.get("income_category"))
            pay_frequency = _clean_frequency(source.get("pay_frequency")) or "UNKNOWN"
            sources.append(
                {
                    "source_id": source_id,
                    "source_type": "BANK",
                    "income_category": category,
                    "monthly_income": round(monthly_income, 2),
                    "monthly_income_range": bracket_monthly_income(monthly_income),
                    "pay_frequency": pay_frequency,
                    "transaction_count": int(source.get("transaction_count") or 0),
                    "start_date": _iso_date(source.get("start_date")),
                }
            )
            for txn in source.get("income_transactions") or []:
                txn_date = _first_date(txn.get("date"), txn.get("transaction_date"))
                amount = _float(txn.get("amount"))
                if txn_date and amount > 0:
                    events.append(
                        {
                            "source_id": source_id,
                            "source_type": "BANK",
                            "income_category": category,
                            "amount": round(amount, 2),
                            "date": txn_date.isoformat(),
                            "pay_frequency": pay_frequency,
                        }
                    )
    return sources, events


def _persist_income(user_id: str, data: dict[str, Any]) -> None:
    sanitized = _sanitize_for_storage(data)
    _LOCAL_SANITIZED_INCOME[user_id] = deepcopy(sanitized)

    sb = _get_supabase()
    if not sb:
        return

    try:
        cutoff = (
            datetime.now(timezone.utc) - timedelta(days=PAYROLL_RETENTION_DAYS)
        ).isoformat()
        sb.table("income_snapshots").delete().eq("user_id", user_id).lt(
            "synced_at", cutoff
        ).execute()
        sb.table("income_snapshots").upsert(sanitized, on_conflict="user_id").execute()
    except Exception as exc:
        log.failure(
            "_persist_income",
            error_type=type(exc).__name__,
            message=str(exc),
            user_id=user_id,
            detail="income_snapshots write failed; local sanitized cache retained",
        )


def _audit_income_sync(user_id: str, data: dict[str, Any]) -> None:
    row = {
        "user_id": user_id,
        "synced_at": data["synced_at"],
        "data_source": data.get("data_source", "NONE"),
        "income_type": data.get("income_type", UNKNOWN_INCOME_TYPE),
        "status": "SUCCESS",
    }
    _LOCAL_SYNC_AUDIT.append(row)

    sb = _get_supabase()
    if not sb:
        return
    try:
        sb.table("income_sync_audit").insert(row).execute()
    except Exception as exc:
        log.failure(
            "_audit_income_sync",
            error_type=type(exc).__name__,
            message=str(exc),
            user_id=user_id,
        )


def _sanitize_for_storage(data: dict[str, Any]) -> dict[str, Any]:
    return {
        "user_id": data["user_id"],
        "income_type": data.get("income_type", UNKNOWN_INCOME_TYPE),
        "has_payroll_connection": bool(data.get("has_payroll_connection")),
        "estimated_monthly_income_range": bracket_monthly_income(
            data.get("estimated_monthly_income")
        ),
        "gross_monthly_income_range": bracket_monthly_income(
            data.get("gross_monthly_income")
        ),
        "income_sources": [
            {
                "source_id": source.get("source_id"),
                "source_type": source.get("source_type"),
                "income_category": source.get("income_category"),
                "monthly_income_range": source.get("monthly_income_range")
                or bracket_monthly_income(source.get("monthly_income")),
                "pay_frequency": source.get("pay_frequency"),
                "transaction_count": source.get("transaction_count", 0),
                "start_date": source.get("start_date"),
            }
            for source in data.get("income_sources", [])
        ],
        "payroll_data": data.get("payroll_data"),
        "data_source": data.get("data_source", "NONE"),
        "synced_at": data["synced_at"],
        "retention_expires_at": data["retention_expires_at"],
    }


def _mock_income(user_id: str) -> dict[str, Any]:
    fixture = _LOCAL_INCOME_FIXTURES[user_id]()
    events = sorted(fixture["income_events"], key=lambda item: item["date"])
    estimated_monthly = fixture.get("estimated_monthly_income")
    if estimated_monthly is None:
        estimated_monthly = _estimated_monthly_income(fixture["income_sources"], events)
    return {
        "income_sources": fixture["income_sources"],
        "payroll_data": fixture.get("payroll_data"),
        "estimated_monthly_income": round(float(estimated_monthly or 0.0), 2),
        "gross_monthly_income": round(float(fixture.get("gross_monthly_income") or estimated_monthly or 0.0), 2),
        "income_type": fixture["income_type"],
        "has_payroll_connection": bool(fixture.get("payroll_data")),
        "income_events": events,
        "data_source": "LOCAL_MOCK",
        "source_priority": "PAYROLL" if fixture.get("payroll_data") else "BANK",
        "mock": True,
    }


def _unknown_income(user_id: str) -> dict[str, Any]:
    return {
        "user_id": user_id,
        "income_sources": [],
        "payroll_data": None,
        "estimated_monthly_income": 0.0,
        "gross_monthly_income": 0.0,
        "income_type": UNKNOWN_INCOME_TYPE,
        "has_payroll_connection": False,
        "income_events": [],
        "data_source": "NONE",
        "source_priority": "NONE",
        "mock": False,
    }


def _estimated_monthly_income(
    sources: list[dict[str, Any]], events: list[dict[str, Any]]
) -> float:
    source_values = [float(s.get("monthly_income") or 0.0) for s in sources]
    source_values = [value for value in source_values if value > 0]
    if source_values:
        return sum(source_values)
    if not events:
        return 0.0
    parsed_dates = [date.fromisoformat(event["date"]) for event in events]
    months = max(_month_span(min(parsed_dates), max(parsed_dates)), 1)
    return sum(float(event["amount"]) for event in events) / months


def _classify_income_type(
    payroll_sources: list[dict[str, Any]],
    bank_sources: list[dict[str, Any]],
    events: list[dict[str, Any]],
) -> str:
    if payroll_sources and bank_sources:
        has_irregular = any(
            source.get("income_category") in {"FREELANCE", "GIG_ECONOMY", "OTHER"}
            for source in bank_sources
        )
        return "MIXED" if has_irregular else "SALARIED"
    if payroll_sources:
        return "SALARIED"
    if not bank_sources and not events:
        return UNKNOWN_INCOME_TYPE
    if any(
        source.get("income_category") in {"FREELANCE", "GIG_ECONOMY", "OTHER"}
        for source in bank_sources
    ):
        return "IRREGULAR"
    return "SALARIED" if _events_look_monthly(events) else "IRREGULAR"


def _events_look_monthly(events: list[dict[str, Any]]) -> bool:
    if len(events) < 3:
        return False
    ordered = sorted(date.fromisoformat(event["date"]) for event in events)
    intervals = [(b - a).days for a, b in zip(ordered, ordered[1:])]
    return bool(intervals) and all(24 <= interval <= 35 for interval in intervals)


def _month_span(start: date, end: date) -> int:
    return (end.year - start.year) * 12 + end.month - start.month + 1


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


def _get_income_user_token(user_id: str) -> str | None:
    sb = _get_supabase()
    if not sb:
        return None
    try:
        res = (
            sb.table("plaid_tokens")
            .select("income_user_token,user_token")
            .eq("user_id", user_id)
            .execute()
        )
        if res.data:
            row = res.data[0]
            return row.get("income_user_token") or row.get("user_token")
    except Exception:
        return None
    return None


def _to_dict(value: Any) -> dict[str, Any]:
    if value is None:
        return {}
    if hasattr(value, "to_dict"):
        return value.to_dict()
    return dict(value)


def _amount_from_stub(stub: dict[str, Any], gross: bool) -> float:
    candidates = []
    if gross:
        candidates.extend(
            [
                ("gross_earnings", "current_pay"),
                ("gross_earnings", "current_amount"),
                ("earnings", "current_pay"),
                ("earnings", "current_amount"),
                ("earnings", "total", "current_amount"),
            ]
        )
    else:
        candidates.extend(
            [
                ("net_earnings", "current_pay"),
                ("net_earnings", "current_amount"),
                ("net_pay", "current_amount"),
            ]
        )
    for path in candidates:
        value: Any = stub
        for key in path:
            value = value.get(key) if isinstance(value, dict) else None
        amount = _float(value)
        if amount > 0:
            return amount
    return 0.0


def _monthly_from_pay_amount(amount: float | int | None, frequency: str | None) -> float:
    value = _float(amount)
    if value <= 0:
        return 0.0
    normalized = _clean_frequency(frequency)
    multipliers = {
        "WEEKLY": 52 / 12,
        "BIWEEKLY": 26 / 12,
        "SEMI_MONTHLY": 2,
        "SEMIMONTHLY": 2,
        "MONTHLY": 1,
        "ANNUALLY": 1 / 12,
        "ANNUAL": 1 / 12,
    }
    return value * multipliers.get(normalized or "", 1)


def _monthly_from_total(
    total_amount: Any, start_date: Any, end_date: Any
) -> float:
    total = _float(total_amount)
    start = _first_date(start_date)
    end = _first_date(end_date)
    if total <= 0 or not start or not end:
        return 0.0
    months = max(_month_span(start, end), 1)
    return total / months


def _map_bank_category(value: Any) -> str:
    raw = str(value or "").upper()
    if raw in {"SALARY", "PAYROLL", "W2"}:
        return "SALARY"
    if raw in {"FREELANCE", "GIG_ECONOMY", "SIDE_HUSTLE", "CONTRACT"}:
        return "GIG_ECONOMY"
    if "BENEFIT" in raw:
        return "BENEFITS"
    if raw:
        return raw
    return "OTHER"


def _clean_frequency(value: Any) -> str | None:
    if not value:
        return None
    return str(value).replace("-", "_").replace(" ", "_").upper()


def _first_date(*values: Any) -> date | None:
    for value in values:
        if not value:
            continue
        if isinstance(value, date):
            return value
        try:
            return date.fromisoformat(str(value)[:10])
        except ValueError:
            continue
    return None


def _iso_date(value: Any) -> str | None:
    parsed = _first_date(value)
    return parsed.isoformat() if parsed else None


def _float(value: Any, default: float = 0.0) -> float:
    if value is None:
        return float(default)
    try:
        return float(value)
    except (TypeError, ValueError):
        return float(default)


def _average(values: list[float]) -> float:
    cleaned = [float(value) for value in values if float(value) > 0]
    return sum(cleaned) / len(cleaned) if cleaned else 0.0


def _month_date(month_offset: int, day: int) -> str:
    today = date.today()
    month_index = today.month - 1 + month_offset
    year = today.year + month_index // 12
    month = month_index % 12 + 1
    max_day = calendar.monthrange(year, month)[1]
    return date(year, month, min(day, max_day)).isoformat()


def _period_start(month_offset: int) -> str:
    return _month_date(month_offset, 1)


def _period_end(month_offset: int) -> str:
    raw = date.fromisoformat(_month_date(month_offset, 1))
    return raw.replace(day=calendar.monthrange(raw.year, raw.month)[1]).isoformat()


def _salary_source(source_id: str, monthly_income: float, transaction_count: int) -> dict[str, Any]:
    return {
        "source_id": source_id,
        "source_type": "PAYROLL",
        "income_category": "SALARY",
        "monthly_income": monthly_income,
        "monthly_income_range": bracket_monthly_income(monthly_income),
        "pay_frequency": "MONTHLY",
        "transaction_count": transaction_count,
        "start_date": _month_date(-5, 1),
    }


def _salary_payroll_rows(source_id: str, monthly_income: float) -> list[dict[str, Any]]:
    return [
        {
            "source_id": source_id,
            "pay_period_start_date": _period_start(offset),
            "pay_period_end_date": _period_end(offset),
            "pay_frequency": "MONTHLY",
            "gross_earnings_range": bracket_monthly_income(monthly_income),
            "net_earnings_range": bracket_monthly_income(monthly_income * 0.72),
        }
        for offset in range(-5, 1)
    ]


def _sarah_income() -> dict[str, Any]:
    monthly = 6500.0
    source_id = "payroll_sarah_primary"
    events = [
        {
            "source_id": source_id,
            "source_type": "PAYROLL",
            "income_category": "SALARY",
            "amount": monthly,
            "date": _month_date(offset, 1),
            "pay_frequency": "MONTHLY",
        }
        for offset in range(-5, 1)
    ]
    return {
        "income_sources": [_salary_source(source_id, monthly, len(events))],
        "payroll_data": _salary_payroll_rows(source_id, monthly),
        "estimated_monthly_income": monthly,
        "gross_monthly_income": monthly,
        "income_type": "SALARIED",
        "income_events": events,
    }


def _bob_income() -> dict[str, Any]:
    monthly = 4800.0
    source_id = "payroll_bob_primary"
    events = [
        {
            "source_id": source_id,
            "source_type": "PAYROLL",
            "income_category": "SALARY",
            "amount": monthly,
            "date": _month_date(offset, 1),
            "pay_frequency": "MONTHLY",
        }
        for offset in range(-5, 1)
    ]
    return {
        "income_sources": [_salary_source(source_id, monthly, len(events))],
        "payroll_data": _salary_payroll_rows(source_id, monthly),
        "estimated_monthly_income": monthly,
        "gross_monthly_income": monthly,
        "income_type": "SALARIED",
        "income_events": events,
    }


def _marcus_income() -> dict[str, Any]:
    gig_events = [
        (-5, 4, 420.0, "rideshare_marcus"),
        (-5, 18, 610.0, "delivery_marcus"),
        (-4, 2, 980.0, "freelance_marcus"),
        (-4, 22, 310.0, "rideshare_marcus"),
        (-3, 10, 1500.0, "freelance_marcus"),
        (-2, 6, 260.0, "delivery_marcus"),
        (-2, 27, 720.0, "rideshare_marcus"),
        (-1, 13, 430.0, "delivery_marcus"),
        (0, 4, 550.0, "rideshare_marcus"),
    ]
    events = [
        {
            "source_id": source_id,
            "source_type": "BANK",
            "income_category": "GIG_ECONOMY" if "freelance" not in source_id else "FREELANCE",
            "amount": amount,
            "date": _month_date(offset, day),
            "pay_frequency": "UNKNOWN",
        }
        for offset, day, amount, source_id in gig_events
    ]
    sources = [
        {
            "source_id": "rideshare_marcus",
            "source_type": "BANK",
            "income_category": "GIG_ECONOMY",
            "monthly_income": 980.0,
            "monthly_income_range": bracket_monthly_income(980.0),
            "pay_frequency": "UNKNOWN",
            "transaction_count": 4,
            "start_date": _month_date(-5, 4),
        },
        {
            "source_id": "freelance_marcus",
            "source_type": "BANK",
            "income_category": "FREELANCE",
            "monthly_income": 900.0,
            "monthly_income_range": bracket_monthly_income(900.0),
            "pay_frequency": "UNKNOWN",
            "transaction_count": 2,
            "start_date": _month_date(-4, 2),
        },
        {
            "source_id": "delivery_marcus",
            "source_type": "BANK",
            "income_category": "GIG_ECONOMY",
            "monthly_income": 520.0,
            "monthly_income_range": bracket_monthly_income(520.0),
            "pay_frequency": "UNKNOWN",
            "transaction_count": 3,
            "start_date": _month_date(-5, 18),
        },
    ]
    return {
        "income_sources": sources,
        "payroll_data": None,
        "estimated_monthly_income": 2400.0,
        "gross_monthly_income": 2400.0,
        "income_type": "IRREGULAR",
        "income_events": events,
    }


def _zero_income() -> dict[str, Any]:
    return {
        "income_sources": [],
        "payroll_data": None,
        "estimated_monthly_income": 0.0,
        "gross_monthly_income": 0.0,
        "income_type": UNKNOWN_INCOME_TYPE,
        "income_events": [],
    }


_LOCAL_INCOME_CONSENT = {
    "user_marcus": True,
    "user_sarah": True,
    "user_bob": True,
    "user_zero_income": True,
    "user_no_consent": False,
}

_LOCAL_INCOME_FIXTURES = {
    "user_marcus": _marcus_income,
    "user_sarah": _sarah_income,
    "user_bob": _bob_income,
    "user_zero_income": _zero_income,
}
