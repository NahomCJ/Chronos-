"""
services/insights/data.py
==========================
Data-access layer for the Dashboard Insights API.

Thin wrapper over `services.banking.mock_api`. Insulates insights endpoints
from the banking data source so swapping Plaid/Supabase/mock never touches
the router or the analytics functions.

Contract: raises ValueError for unknown users so the router can return 404.
Empty list means the user exists but has no data.
"""

from __future__ import annotations

from typing import Any

from services.banking.mock_api import get_transactions, get_warnings_history


def load_transactions(user_id: str, days_back: int = 90) -> list[dict[str, Any]]:
    """
    Loads recent transactions for a user from the banking data source.

    Args:
        user_id (str): User identifier (e.g. "user_marcus").
        days_back (int): Lookback window in days. Default 90 — enough to
            cover top-categories sparklines (3 calendar months) and
            spending-summary month-over-month deltas (60 days) without
            over-fetching.

    Returns:
        list[dict]: Transactions newest-first. Each dict has keys
            "merchant" (str), "amount" (float, negative=debit),
            "date" (str ISO), "category" (str display name).

    Raises:
        ValueError: Unknown user_id.
    """
    return get_transactions(user_id, days_back=days_back)


def load_warnings(user_id: str, limit: int = 1000) -> list[dict[str, Any]]:
    """
    Loads risk warning history for a user from the banking data source.

    Args:
        user_id (str): User identifier (e.g. "user_marcus").
        limit (int): Max warnings to fetch. Default 1000 — the insights
            layer paginates in-memory, so callers should pull the full
            history and slice afterwards.

    Returns:
        list[dict]: Warning records sorted newest-first. Each dict has
            keys "id", "timestamp", "source", "risk_level", "title",
            "message", "context", "outcome".

    Raises:
        ValueError: Unknown user_id.
    """
    return get_warnings_history(user_id, limit=limit)
