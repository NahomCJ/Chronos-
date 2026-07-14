"""What-if net worth projection.

Answers "if I invest/save an extra $X per month starting now, how does my net
worth look in N months?" by walking forward month-by-month from the current
``calculate_net_worth`` snapshot: investable assets compound at an assumed
annual return, liabilities pay down by the sum of connected accounts' real
minimum/monthly payments (0 if liabilities aren't connected — a conservative
"balance stays flat" assumption rather than guessing a paydown rate), and any
extra monthly contribution the user is considering is added straight to
savings. This mirrors services/cashflow/cashflow_predictor.py's walk-forward
shape but at monthly granularity over the whole net-worth surface (assets +
liabilities) rather than daily bank balance alone.
"""

from __future__ import annotations

import calendar
from datetime import date, datetime, timezone
from typing import Any

from .aggregation import calculate_net_worth
from .mock_data import normalize_user_id


def project_net_worth(
    user_id: str,
    months: int = 12,
    monthly_contribution_delta: float = 0.0,
    annual_investment_return_pct: float = 7.0,
) -> dict[str, Any]:
    """Projects net worth forward, comparing a baseline path against a
    what-if scenario where the user contributes ``monthly_contribution_delta``
    extra per month starting now.
    """
    normalized_user_id = normalize_user_id(user_id)
    current = calculate_net_worth(normalized_user_id)
    assets = current["assets_breakdown"]
    monthly_growth_rate = (annual_investment_return_pct / 100) / 12
    monthly_liability_paydown = _monthly_liability_paydown(normalized_user_id)

    baseline_series = _walk_forward(
        assets=assets,
        total_liabilities=current["total_liabilities"],
        months=months,
        monthly_growth_rate=monthly_growth_rate,
        monthly_liability_paydown=monthly_liability_paydown,
        extra_monthly_contribution=0.0,
    )
    scenario_series = (
        _walk_forward(
            assets=assets,
            total_liabilities=current["total_liabilities"],
            months=months,
            monthly_growth_rate=monthly_growth_rate,
            monthly_liability_paydown=monthly_liability_paydown,
            extra_monthly_contribution=monthly_contribution_delta,
        )
        if monthly_contribution_delta
        else baseline_series
    )

    baseline_end = baseline_series[-1]["net_worth"]
    scenario_end = scenario_series[-1]["net_worth"]

    return {
        "user_id": normalized_user_id,
        "months": months,
        "starting_net_worth": current["net_worth"],
        "assumptions": {
            "annual_investment_return_pct": annual_investment_return_pct,
            "monthly_contribution_delta": monthly_contribution_delta,
            "monthly_liability_paydown": round(monthly_liability_paydown, 2),
        },
        "baseline_projection": baseline_series,
        "scenario_projection": scenario_series,
        "projected_net_worth_at_end": {
            "baseline": baseline_end,
            "scenario": scenario_end,
            "difference": round(scenario_end - baseline_end, 2),
        },
        "calculated_at": datetime.now(timezone.utc).isoformat(),
        "insight": _insight(months, baseline_end, scenario_end, monthly_contribution_delta),
    }


def _walk_forward(
    *,
    assets: dict[str, float],
    total_liabilities: float,
    months: int,
    monthly_growth_rate: float,
    monthly_liability_paydown: float,
    extra_monthly_contribution: float,
) -> list[dict[str, Any]]:
    investments = float(assets["investments"])
    other_savings = float(assets["other_savings"])
    bank_balances = float(assets["bank_balances"])
    crypto = float(assets["crypto"])
    liabilities = float(total_liabilities)
    today = date.today()

    series: list[dict[str, Any]] = []
    for month in range(1, months + 1):
        investments *= 1 + monthly_growth_rate
        other_savings += extra_monthly_contribution
        liabilities = max(0.0, liabilities - monthly_liability_paydown)
        total_assets = investments + other_savings + bank_balances + crypto
        series.append(
            {
                "month": month,
                "date": _add_months(today, month).isoformat(),
                "net_worth": round(total_assets - liabilities, 2),
            }
        )
    return series


def _monthly_liability_paydown(user_id: str) -> float:
    try:
        from services.liabilities.ingestion import get_liabilities_data

        data = get_liabilities_data(user_id)
    except Exception:
        return 0.0

    total = 0.0
    for card in data.get("credit_cards", []):
        total += float(card.get("minimum_payment") or 0.0)
    for key in ("student_loans", "auto_loans", "personal_loans"):
        for loan in data.get(key, []):
            total += float(loan.get("monthly_payment") or 0.0)
    for mortgage in data.get("mortgages", []):
        total += float(mortgage.get("monthly_payment") or 0.0)
    return total


def _add_months(start: date, months: int) -> date:
    month_index = start.month - 1 + months
    year = start.year + month_index // 12
    month = month_index % 12 + 1
    day = min(start.day, calendar.monthrange(year, month)[1])
    return date(year, month, day)


def _insight(
    months: int,
    baseline_end: float,
    scenario_end: float,
    monthly_contribution_delta: float,
) -> str:
    if monthly_contribution_delta <= 0:
        return (
            f"At your current trajectory, you're projected to reach a net worth of "
            f"£{baseline_end:,.2f} in {months} months."
        )
    difference = round(scenario_end - baseline_end, 2)
    return (
        f"If you contribute an extra £{monthly_contribution_delta:,.2f}/month starting "
        f"now, you'd have £{difference:,.2f} more in net worth after {months} months — "
        f"reaching approximately £{scenario_end:,.2f}, versus £{baseline_end:,.2f} on your "
        f"current path."
    )
