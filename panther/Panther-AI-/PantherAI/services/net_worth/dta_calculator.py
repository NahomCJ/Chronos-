"""Debt-to-asset ratio calculator for connected accounts."""

from __future__ import annotations

import math
from typing import Any

from .aggregation import calculate_net_worth


def calculate_dta(user_id: str) -> dict[str, Any]:
    net_worth = calculate_net_worth(user_id)
    total_debt = float(net_worth["total_liabilities"])
    total_assets = float(net_worth["total_assets"])

    if total_assets <= 0:
        dta_ratio = math.inf if total_debt > 0 else 0.0
    else:
        dta_ratio = round(total_debt / total_assets, 4)

    status = _status(total_debt, total_assets, dta_ratio)
    return {
        "user_id": net_worth["user_id"],
        "total_debt": round(total_debt, 2),
        "total_assets": round(total_assets, 2),
        "dta_ratio": dta_ratio,
        "dta_status": status,
        "insight": _insight(status, dta_ratio),
    }


def _status(total_debt: float, total_assets: float, ratio: float) -> str:
    if total_debt > total_assets:
        return "CRITICAL"
    if ratio >= 0.5:
        return "HIGH"
    if ratio >= 0.3:
        return "MODERATE"
    return "HEALTHY"


def _insight(status: str, ratio: float) -> str:
    if math.isinf(ratio):
        ratio_text = "unavailable because connected assets are zero"
    else:
        ratio_text = f"{ratio * 100:.1f}%"

    if status == "CRITICAL":
        return (
            f"Connected liabilities are higher than connected assets, so the DTA ratio is {ratio_text}."
        )
    return f"Connected liabilities are {ratio_text} of connected assets, in the {status.lower()} range."
