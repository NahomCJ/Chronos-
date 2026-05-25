"""
services/blockhub/connector.py
================================
HTTP client for the BlockHub Node.js backend (B6).

Provides portfolio holdings, current prices, and P&L data.
Falls back to mock data in development when the backend is unreachable.

Sync wrappers are used so they can be called from Kevin's sync tool loop.

Environment:
    BLOCKHUB_URL           — default: http://localhost:3002
    CHRONOS_INTERNAL_TOKEN — shared service-to-service auth token
    ENVIRONMENT            — "development" enables mock fallback
"""

from __future__ import annotations

import os
from datetime import datetime, timezone
from typing import Any

import httpx
from dotenv import load_dotenv

load_dotenv()

BLOCKHUB_URL = os.getenv("BLOCKHUB_URL", "http://localhost:3002")
CHRONOS_INTERNAL_TOKEN = os.getenv("CHRONOS_INTERNAL_TOKEN", "")
IS_DEV = os.getenv("ENVIRONMENT", "development") == "development"


def get_portfolio(user_id: str) -> dict[str, Any]:
    """
    Returns portfolio summary: total value, holdings, allocation percentages.
    """
    data = _call_blockhub_sync(user_id, "/api/portfolio/summary")
    return data if data is not None else _mock_portfolio(user_id)


def get_crypto_pnl(user_id: str) -> dict[str, Any]:
    """
    Returns P&L summary: total_pnl, pnl_percentage, realized, unrealized.
    """
    data = _call_blockhub_sync(user_id, "/api/portfolio/pnl")
    return data if data is not None else _mock_pnl(user_id)


def get_position_summary(user_id: str) -> list[dict[str, Any]]:
    """
    Returns list of open positions with current price and per-position P&L.
    """
    data = _call_blockhub_sync(user_id, "/api/portfolio/positions")
    return data if data is not None else _mock_positions(user_id)


def _call_blockhub_sync(user_id: str, path: str) -> dict | list | None:
    """Makes a synchronous authenticated HTTP call to the BlockHub backend."""
    headers = {"X-User-Id": user_id}
    if CHRONOS_INTERNAL_TOKEN:
        headers["X-Internal-Token"] = CHRONOS_INTERNAL_TOKEN

    try:
        with httpx.Client(timeout=10.0) as client:
            resp = client.get(f"{BLOCKHUB_URL}{path}", headers=headers)
            resp.raise_for_status()
            return resp.json()
    except (httpx.RequestError, httpx.HTTPStatusError):
        if IS_DEV:
            return None  # Caller uses mock data
        raise


# ---------------------------------------------------------------------------
# Mock data for local development
# ---------------------------------------------------------------------------


def _mock_portfolio(user_id: str) -> dict:
    return {
        "user_id": user_id,
        "total_value_usd": 12450.00,
        "total_cost_basis": 9800.00,
        "unrealized_pnl": 2650.00,
        "pnl_percentage": 27.04,
        "holdings": [
            {
                "symbol": "BTC",
                "name": "Bitcoin",
                "quantity": 0.15,
                "value_usd": 9375.00,
                "allocation_pct": 75.3,
            },
            {
                "symbol": "ETH",
                "name": "Ethereum",
                "quantity": 2.5,
                "value_usd": 2250.00,
                "allocation_pct": 18.1,
            },
            {
                "symbol": "SOL",
                "name": "Solana",
                "quantity": 7.0,
                "value_usd": 825.00,
                "allocation_pct": 6.6,
            },
        ],
        "last_updated": datetime.now(timezone.utc).isoformat(),
        "mock": True,
    }


def _mock_pnl(user_id: str) -> dict:
    return {
        "user_id": user_id,
        "total_pnl_usd": 2650.00,
        "total_pnl_percentage": 27.04,
        "realized_pnl": 450.00,
        "unrealized_pnl": 2200.00,
        "last_30d_pnl": 820.00,
        "mock": True,
    }


def _mock_positions(user_id: str) -> list:
    return [
        {
            "symbol": "BTC",
            "quantity": 0.15,
            "avg_buy_price": 42000.00,
            "current_price": 62500.00,
            "value_usd": 9375.00,
            "pnl_usd": 3075.00,
            "pnl_pct": 48.81,
        },
        {
            "symbol": "ETH",
            "quantity": 2.5,
            "avg_buy_price": 2200.00,
            "current_price": 900.00,
            "value_usd": 2250.00,
            "pnl_usd": -1250.00,
            "pnl_pct": -22.73,
        },
        {
            "symbol": "SOL",
            "quantity": 7.0,
            "avg_buy_price": 90.00,
            "current_price": 117.86,
            "value_usd": 825.00,
            "pnl_usd": 195.00,
            "pnl_pct": 30.95,
        },
    ]
