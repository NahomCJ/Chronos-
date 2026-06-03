"""Paycheck planning and bill coverage analysis."""

from __future__ import annotations

from datetime import date, timedelta
from typing import Any

from services.banking.mock_api import get_balance, get_upcoming_bills
from services.income.ingestion import get_income_data, normalize_user_id
from services.income.stability import analyze_income_stability


def get_paycheck_plan(user_id: str) -> dict[str, Any]:
    normalized_user_id = normalize_user_id(user_id)
    income_data = get_income_data(normalized_user_id)
    stability = analyze_income_stability(normalized_user_id)
    current_balance = float(get_balance(normalized_user_id))
    today = date.today()

    last_event = _last_income_event(income_data)
    last_income_date = (
        date.fromisoformat(last_event["date"]) if last_event and last_event.get("date") else None
    )
    expected_next = stability.get("expected_next_income_date")
    if isinstance(expected_next, str):
        expected_next = date.fromisoformat(expected_next)
    days_until_next = (expected_next - today).days if expected_next else None

    upcoming = _upcoming_bills(normalized_user_id, current_balance, today)
    balance_after_bills = round(
        current_balance - sum(float(bill["amount"]) for bill in upcoming), 2
    )
    overdraft_risk_date = _first_overdraft_date(current_balance, upcoming)
    recommended_daily_spend = _recommended_daily_spend(
        balance_after_bills, days_until_next
    )

    return {
        "user_id": normalized_user_id,
        "last_income_amount": round(float(last_event["amount"]), 2) if last_event else 0.0,
        "last_income_date": last_income_date,
        "days_since_last_income": (today - last_income_date).days if last_income_date else None,
        "expected_next_income_date": expected_next,
        "days_until_next_income": days_until_next,
        "upcoming_bills": upcoming,
        "current_balance": round(current_balance, 2),
        "balance_after_bills": balance_after_bills,
        "will_overdraft": overdraft_risk_date is not None,
        "overdraft_risk_date": overdraft_risk_date,
        "recommended_daily_spend": recommended_daily_spend,
        "insight": _insight(
            upcoming,
            balance_after_bills,
            days_until_next,
            recommended_daily_spend,
            overdraft_risk_date,
        ),
    }


def _last_income_event(data: dict[str, Any]) -> dict[str, Any] | None:
    events = [
        event
        for event in data.get("income_events", [])
        if float(event.get("amount") or 0.0) > 0 and event.get("date")
    ]
    if not events:
        return None
    return max(events, key=lambda item: item["date"])


def _upcoming_bills(
    user_id: str, current_balance: float, today: date
) -> list[dict[str, Any]]:
    try:
        raw_bills = get_upcoming_bills(user_id, days_ahead=30)
    except Exception:
        raw_bills = []

    running_balance = current_balance
    planned: list[dict[str, Any]] = []
    for bill in sorted(raw_bills, key=lambda item: int(item.get("due_in_days") or 0)):
        amount = round(float(bill.get("amount") or 0.0), 2)
        due_in_days = int(bill.get("due_in_days") or 0)
        running_balance -= amount
        planned.append(
            {
                "merchant": str(bill.get("merchant") or bill.get("name") or "Bill"),
                "amount": amount,
                "due_date": today + timedelta(days=due_in_days),
                "days_until_due": due_in_days,
                "covered_by_balance": running_balance >= 0,
            }
        )
    return planned


def _first_overdraft_date(
    current_balance: float, upcoming_bills: list[dict[str, Any]]
) -> date | None:
    running_balance = current_balance
    for bill in sorted(upcoming_bills, key=lambda item: item["due_date"]):
        running_balance -= float(bill["amount"])
        if running_balance < 0:
            return bill["due_date"]
    return None


def _recommended_daily_spend(
    balance_after_bills: float, days_until_next_income: int | None
) -> float:
    if days_until_next_income is None or days_until_next_income <= 0:
        return 0.0
    return round(max(balance_after_bills, 0.0) / days_until_next_income, 2)


def _insight(
    upcoming_bills: list[dict[str, Any]],
    balance_after_bills: float,
    days_until_next: int | None,
    recommended_daily_spend: float,
    overdraft_risk_date: date | None,
) -> str:
    if overdraft_risk_date:
        return (
            f"After {len(upcoming_bills)} scheduled bills, your balance would be "
            f"{balance_after_bills:.2f}; the first shortfall appears on "
            f"{overdraft_risk_date.isoformat()}."
        )
    if days_until_next is None:
        return (
            f"After {len(upcoming_bills)} scheduled bills, you would have "
            f"{balance_after_bills:.2f} left. No reliable next payday is available yet."
        )
    return (
        f"Your next expected payday is in {days_until_next} days. After "
        f"{len(upcoming_bills)} scheduled bills, you would have "
        f"{balance_after_bills:.2f} left, about {recommended_daily_spend:.2f}/day."
    )
