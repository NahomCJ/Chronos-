"""Mock source data for the Week 1 net worth lane.

Live Plaid Investments, BlockHub account-link metadata, and cross-lane source
registry wiring arrive in integration week. Until then these fixtures make the
net worth and health score calculations deterministic for demo users while
still exercising missing-source behavior.
"""

from __future__ import annotations

from copy import deepcopy
from typing import Any

EXPECTED_SOURCES = ("banking", "investments", "crypto", "liabilities", "income")

_SOURCE_CONNECTIONS: dict[str, set[str]] = {
    "user_marcus": {"banking", "liabilities", "income"},
    "user_sarah": {"banking", "investments", "crypto", "liabilities", "income"},
    "user_bob": {"banking", "investments", "liabilities", "income"},
}

_INVESTMENT_FIXTURES: dict[str, dict[str, Any]] = {
    "user_marcus": {
        "total_value": 0.0,
        "holding_count": 0,
        "asset_classes": [],
        "diversified": False,
    },
    "user_sarah": {
        "total_value": 62_000.0,
        "holding_count": 9,
        "asset_classes": ["equities", "bonds", "retirement"],
        "diversified": True,
    },
    "user_bob": {
        "total_value": 18_000.0,
        "holding_count": 2,
        "asset_classes": ["equities"],
        "diversified": False,
    },
}

_CRYPTO_FIXTURES: dict[str, dict[str, Any]] = {
    "user_sarah": {
        "total_value": 12_450.0,
        "holding_count": 3,
        "connected": True,
    }
}

_OTHER_SAVINGS_FIXTURES: dict[str, float] = {
    "user_marcus": 0.0,
    "user_sarah": 15_000.0,
    "user_bob": 8_000.0,
}


def normalize_user_id(user_id: str) -> str:
    value = str(user_id or "").strip().lower()
    if value.startswith("user_"):
        return value
    return f"user_{value}"


def connected_sources(user_id: str) -> set[str]:
    return set(_SOURCE_CONNECTIONS.get(normalize_user_id(user_id), set()))


def has_source(user_id: str, source: str) -> bool:
    return source in connected_sources(user_id)


def investment_fixture(user_id: str) -> dict[str, Any]:
    return deepcopy(
        _INVESTMENT_FIXTURES.get(
            normalize_user_id(user_id),
            {
                "total_value": 0.0,
                "holding_count": 0,
                "asset_classes": [],
                "diversified": False,
            },
        )
    )


def crypto_fixture(user_id: str) -> dict[str, Any]:
    return deepcopy(
        _CRYPTO_FIXTURES.get(
            normalize_user_id(user_id),
            {"total_value": 0.0, "holding_count": 0, "connected": False},
        )
    )


def other_savings_fixture(user_id: str) -> float:
    return float(_OTHER_SAVINGS_FIXTURES.get(normalize_user_id(user_id), 0.0))
