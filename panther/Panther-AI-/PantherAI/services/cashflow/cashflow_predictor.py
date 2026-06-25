"""
Cashflow forecasting over a user's own banking history.

All output is informational guidance only. The service describes projected
balances and risk levels; it does not prescribe financial actions.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from datetime import date, timedelta
import os
from statistics import median
from typing import Any, Iterable

import numpy as np

from core.logger import log
from services.banking.mock_api import get_balance, get_transactions, get_upcoming_bills
from services.subscriptions.detector import detect_subscriptions

try:
    from xgboost import XGBRegressor
except Exception:  # pragma: no cover - optional dependency in local dev.
    XGBRegressor = None


DEFAULT_HORIZONS = [7, 30, 90]
LOW_CONFIDENCE_HISTORY_DAYS = 30
ENABLE_XGBOOST_CASHFLOW = (
    os.getenv("PANTHER_ENABLE_XGBOOST_CASHFLOW", "false").lower() == "true"
)


@dataclass(frozen=True)
class _RecurringIncome:
    amount: float
    day_of_month: int


def predict_cashflow(user_id: str, days: list[int] | int | None = None) -> dict[str, Any]:
    """
    Forecast a user's daily balance over one or more horizons.

    Args:
        user_id: User identifier.
        days: Forecast horizons. Passing `30` returns a 30-day series; passing
            `[7, 30, 90]` returns the longest requested horizon.

    Returns:
        {
            "projected_balance_series": [{"date": "...", "projected_balance": ...}],
            "overdraft_risk": "HIGH" | "MEDIUM" | "LOW",
            "days_until_zero": int,
            "income_spike_expected": bool,
            "confidence": "high" | "low",
            "history_days": int
        }
    """
    horizons = _normalize_horizons(days)
    horizon = max(horizons)

    transactions = get_transactions(user_id, days_back=370)
    balance = float(get_balance(user_id))
    if not transactions:
        return _empty_projection(balance, horizon)

    parsed = _parse_transactions(transactions)
    anchor = min(date.today(), max(t["date"] for t in parsed))
    first_seen = min(t["date"] for t in parsed)
    history_days = max((anchor - first_seen).days + 1, 1)
    confidence = "low" if history_days < LOW_CONFIDENCE_HISTORY_DAYS else "high"

    subscriptions = detect_subscriptions(user_id, persist=False)
    recurring_income = _detect_recurring_income(parsed)
    daily_variable_spend = _daily_variable_spend(parsed, history_days, subscriptions)
    model = _fit_xgboost(parsed, first_seen, anchor)
    upcoming_bills = _upcoming_bill_schedule(user_id, anchor, horizon)

    projected_balance = balance
    series: list[dict[str, Any]] = []
    income_spike_expected = False

    for offset in range(1, horizon + 1):
        target_date = anchor + timedelta(days=offset)
        deterministic_delta = -_weekday_adjusted_spend(daily_variable_spend, target_date)
        deterministic_delta += _subscription_delta(subscriptions, target_date)
        deterministic_delta += _income_delta(recurring_income, target_date)
        deterministic_delta += upcoming_bills.get(target_date, 0.0)

        model_delta = _predict_daily_delta(model, first_seen, target_date)
        daily_delta = _blend_delta(deterministic_delta, model_delta)

        if _income_delta(recurring_income, target_date) > 0:
            income_spike_expected = True

        projected_balance += daily_delta
        series.append(
            {
                "date": target_date.isoformat(),
                "projected_balance": round(projected_balance, 2),
            }
        )

    days_until_zero = _days_until_zero(series, horizon)
    risk = _overdraft_risk(series, days_until_zero, daily_variable_spend)

    return {
        "projected_balance_series": series,
        "overdraft_risk": risk,
        "days_until_zero": days_until_zero,
        "income_spike_expected": income_spike_expected,
        "confidence": confidence,
        "history_days": history_days,
    }


def _normalize_horizons(days: list[int] | int | None) -> list[int]:
    if days is None:
        return DEFAULT_HORIZONS
    if isinstance(days, int):
        values = [days]
    else:
        values = list(days)
    cleaned = sorted({int(value) for value in values if int(value) > 0})
    return cleaned or DEFAULT_HORIZONS


def _empty_projection(balance: float, horizon: int) -> dict[str, Any]:
    today = date.today()
    series = [
        {
            "date": (today + timedelta(days=offset)).isoformat(),
            "projected_balance": round(balance, 2),
        }
        for offset in range(1, horizon + 1)
    ]
    return {
        "projected_balance_series": series,
        "overdraft_risk": "LOW" if balance > 0 else "HIGH",
        "days_until_zero": 1 if balance <= 0 else horizon + 1,
        "income_spike_expected": False,
        "confidence": "low",
        "history_days": 0,
    }


def _parse_transactions(transactions: Iterable[dict[str, Any]]) -> list[dict[str, Any]]:
    parsed: list[dict[str, Any]] = []
    for txn in transactions:
        try:
            parsed.append(
                {
                    "merchant": str(txn.get("merchant") or txn.get("merchant_name") or ""),
                    "amount": float(txn.get("amount") or 0.0),
                    "date": date.fromisoformat(str(txn["date"])[:10]),
                    "category": str(txn.get("category") or ""),
                }
            )
        except Exception as exc:
            log.failure(
                "predict_cashflow.parse_transaction",
                error_type=type(exc).__name__,
                message=str(exc),
                detail="Skipping malformed transaction row",
            )
    return parsed


def _fit_xgboost(
    transactions: list[dict[str, Any]], first_seen: date, anchor: date
) -> Any | None:
    if not ENABLE_XGBOOST_CASHFLOW or XGBRegressor is None:
        return None

    rows = _daily_rows(transactions, first_seen, anchor)
    if len(rows) < 14:
        return None

    features = np.array([_features_for_day(row["date"], first_seen) for row in rows])
    target = np.array([row["net"] for row in rows])
    try:
        model = XGBRegressor(
            n_estimators=80,
            max_depth=3,
            learning_rate=0.08,
            objective="reg:squarederror",
            random_state=42,
        )
        model.fit(features, target)
        return model
    except Exception as exc:
        log.failure(
            "predict_cashflow.xgboost",
            error_type=type(exc).__name__,
            message=str(exc),
            detail="XGBoost training failed; falling back to deterministic projection",
        )
        return None


def _daily_rows(
    transactions: list[dict[str, Any]], first_seen: date, anchor: date
) -> list[dict[str, Any]]:
    totals: dict[date, float] = defaultdict(float)
    for txn in transactions:
        totals[txn["date"]] += txn["amount"]

    day_count = (anchor - first_seen).days + 1
    return [
        {"date": first_seen + timedelta(days=offset), "net": totals[first_seen + timedelta(days=offset)]}
        for offset in range(day_count)
    ]


def _features_for_day(day: date, first_seen: date) -> list[float]:
    return [
        float((day - first_seen).days),
        float(day.weekday()),
        float(day.day),
        float(day.month),
        1.0 if day.weekday() >= 5 else 0.0,
        1.0 if day.day == 1 else 0.0,
        1.0 if day.day >= 28 else 0.0,
    ]


def _predict_daily_delta(model: Any | None, first_seen: date, target_date: date) -> float | None:
    if model is None:
        return None
    try:
        features = np.array([_features_for_day(target_date, first_seen)])
        return float(model.predict(features)[0])
    except Exception:
        return None


def _blend_delta(deterministic_delta: float, model_delta: float | None) -> float:
    if model_delta is None:
        return deterministic_delta
    return deterministic_delta * 0.85 + model_delta * 0.15


def _daily_variable_spend(
    transactions: list[dict[str, Any]], history_days: int, subscriptions: list[dict[str, Any]]
) -> float:
    recurring_merchants = {_normalized_name(sub["merchant"]) for sub in subscriptions}
    total_variable_spend = 0.0

    for txn in transactions:
        amount = txn["amount"]
        if amount >= 0:
            continue
        merchant = _normalized_name(txn["merchant"])
        if merchant in recurring_merchants:
            continue
        if abs(amount) >= 300 and _looks_fixed_bill(txn):
            continue
        total_variable_spend += abs(amount)

    return round(total_variable_spend / max(history_days, 1), 2)


def _weekday_adjusted_spend(daily_spend: float, target_date: date) -> float:
    if target_date.weekday() >= 5:
        return daily_spend * 1.08
    return daily_spend


def _subscription_delta(subscriptions: list[dict[str, Any]], target_date: date) -> float:
    delta = 0.0
    for sub in subscriptions:
        if _subscription_occurs_on(sub, target_date):
            delta -= float(sub["amount"])
    return delta


def _subscription_occurs_on(subscription: dict[str, Any], target_date: date) -> bool:
    next_date_raw = subscription.get("next_charge_date")
    if not next_date_raw:
        return False
    next_date = date.fromisoformat(next_date_raw)
    frequency = subscription.get("frequency")

    if frequency == "weekly":
        return target_date >= next_date and (target_date - next_date).days % 7 == 0
    if frequency == "monthly":
        return target_date.day == next_date.day
    if frequency == "quarterly":
        return (
            target_date.day == next_date.day
            and target_date >= next_date
            and (target_date.year - next_date.year) * 12 + target_date.month - next_date.month
            >= 0
            and ((target_date.year - next_date.year) * 12 + target_date.month - next_date.month) % 3 == 0
        )
    if frequency == "annual":
        return target_date.month == next_date.month and target_date.day == next_date.day
    return False


def _detect_recurring_income(transactions: list[dict[str, Any]]) -> list[_RecurringIncome]:
    groups: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for txn in transactions:
        if txn["amount"] <= 0:
            continue
        groups[_normalized_name(txn["merchant"])].append(txn)

    incomes: list[_RecurringIncome] = []
    for rows in groups.values():
        if len(rows) < 2:
            continue
        ordered = sorted(rows, key=lambda t: t["date"])
        intervals = [
            (later["date"] - earlier["date"]).days
            for earlier, later in zip(ordered, ordered[1:])
        ]
        if not intervals or not 24 <= median(intervals) <= 35:
            continue
        day = _modal_day([row["date"] for row in ordered])
        amount = round(float(median(row["amount"] for row in ordered)), 2)
        incomes.append(_RecurringIncome(amount=amount, day_of_month=day))
    return incomes


def _income_delta(incomes: list[_RecurringIncome], target_date: date) -> float:
    return sum(income.amount for income in incomes if target_date.day == income.day_of_month)


def _upcoming_bill_schedule(user_id: str, anchor: date, horizon: int) -> dict[date, float]:
    schedule: dict[date, float] = defaultdict(float)
    try:
        bills = get_upcoming_bills(user_id, days_ahead=min(horizon, 30))
    except Exception:
        return schedule

    for bill in bills:
        due_in_days = int(bill.get("due_in_days") or 0)
        if 1 <= due_in_days <= horizon:
            schedule[anchor + timedelta(days=due_in_days)] -= abs(float(bill.get("amount") or 0.0))
    return schedule


def _days_until_zero(series: list[dict[str, Any]], horizon: int) -> int:
    for index, point in enumerate(series, start=1):
        if float(point["projected_balance"]) <= 0:
            return index
    return horizon + 1


def _overdraft_risk(
    series: list[dict[str, Any]], days_until_zero: int, daily_variable_spend: float
) -> str:
    min_balance_30 = min(float(point["projected_balance"]) for point in series[:30])
    min_balance_all = min(float(point["projected_balance"]) for point in series)
    monthly_spend_buffer = max(daily_variable_spend * 30, 1.0)

    if days_until_zero <= 14 or min_balance_30 <= 0:
        return "HIGH"
    if days_until_zero <= len(series) or min_balance_all < monthly_spend_buffer:
        return "MEDIUM"
    return "LOW"


def _looks_fixed_bill(txn: dict[str, Any]) -> bool:
    category = txn["category"].lower()
    merchant = txn["merchant"].lower()
    return any(
        marker in category or marker in merchant
        for marker in {"rent", "mortgage", "loan", "insurance"}
    )


def _normalized_name(value: str) -> str:
    return " ".join(value.upper().replace("&", "AND").split())


def _modal_day(dates: list[date]) -> int:
    counts: dict[int, int] = defaultdict(int)
    for observed in dates:
        counts[observed.day] += 1
    return max(counts.items(), key=lambda item: (item[1], item[0]))[0]
