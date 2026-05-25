"""
services/conversational_ai/payment_executor.py
===============================================
Executes voice transaction commands via the Chronos Node.js backend.

Each transaction type maps to a dedicated Chronos endpoint:
  transfer  → POST /api/transfers/create
  request   → POST /api/requests/create
  exchange  → POST /api/exchange/create
  purchase  → POST /api/purchases/create
  trade     → POST /api/trades/create
  invest    → POST /api/investments/create

Falls back to mock responses in development when the backend is unreachable.

Environment:
    CHRONOS_BACKEND_URL    — default: http://localhost:3001
    CHRONOS_INTERNAL_TOKEN — service-to-service auth header
    ENVIRONMENT            — "development" enables mock fallback
"""

from __future__ import annotations

import os
import uuid
from typing import Any

import httpx
from dotenv import load_dotenv

load_dotenv()

CHRONOS_BACKEND_URL    = os.getenv("CHRONOS_BACKEND_URL", "http://localhost:3001")
CHRONOS_INTERNAL_TOKEN = os.getenv("CHRONOS_INTERNAL_TOKEN", "")
IS_DEV                 = os.getenv("ENVIRONMENT", "development") == "development"


# ---------------------------------------------------------------------------
# Public dispatcher
# ---------------------------------------------------------------------------

async def execute_transaction(user_id: str, intent: dict) -> dict[str, Any]:
    """
    Routes a confirmed TransactionIntent to the correct executor.

    Args:
        user_id: Authenticated user ID.
        intent:  Parsed TransactionIntent dict from payment_intent.py.

    Returns:
        Result dict from the Chronos backend (or mock in dev).

    Raises:
        RuntimeError: On backend error or unknown intent type.
    """
    tx_type = intent.get("type")
    executors = {
        "transfer": execute_transfer,
        "request":  execute_request,
        "exchange": execute_exchange,
        "purchase": execute_purchase,
        "trade":    execute_trade,
        "invest":   execute_invest,
    }
    fn = executors.get(tx_type)
    if not fn:
        raise RuntimeError(f"Unknown transaction type: {tx_type!r}")
    return await fn(user_id, intent)


# ---------------------------------------------------------------------------
# Transfer — send money to someone
# ---------------------------------------------------------------------------

async def execute_transfer(user_id: str, intent: dict) -> dict[str, Any]:
    payload = {
        "userId":    user_id,
        "recipient": intent["recipient"],
        "amount":    intent["amount"],
        "currency":  intent.get("currency", "USD"),
        "description": "Voice-initiated transfer",
        "source": "voice_command",
    }
    return await _post("/api/transfers/create", payload, user_id, intent)


# ---------------------------------------------------------------------------
# Request — ask someone to send you money
# ---------------------------------------------------------------------------

async def execute_request(user_id: str, intent: dict) -> dict[str, Any]:
    payload = {
        "userId":   user_id,
        "fromUser": intent["from_user"],
        "amount":   intent["amount"],
        "currency": intent.get("currency", "USD"),
        "description": "Voice-initiated payment request",
        "source": "voice_command",
    }
    return await _post("/api/requests/create", payload, user_id, intent)


# ---------------------------------------------------------------------------
# Exchange — convert one currency to another
# ---------------------------------------------------------------------------

async def execute_exchange(user_id: str, intent: dict) -> dict[str, Any]:
    payload = {
        "userId":       user_id,
        "amount":       intent["amount"],
        "fromCurrency": intent.get("from_currency", "USD"),
        "toCurrency":   intent["to_currency"],
        "source": "voice_command",
    }
    return await _post("/api/exchange/create", payload, user_id, intent)


# ---------------------------------------------------------------------------
# Purchase — buy a product or service
# ---------------------------------------------------------------------------

async def execute_purchase(user_id: str, intent: dict) -> dict[str, Any]:
    payload = {
        "userId":   user_id,
        "item":     intent.get("item", "item"),
        "amount":   intent.get("amount"),
        "currency": intent.get("currency", "USD"),
        "source": "voice_command",
    }
    return await _post("/api/purchases/create", payload, user_id, intent)


# ---------------------------------------------------------------------------
# Trade — buy or sell crypto / stocks
# ---------------------------------------------------------------------------

async def execute_trade(user_id: str, intent: dict) -> dict[str, Any]:
    payload = {
        "userId":    user_id,
        "direction": intent["direction"],
        "asset":     intent["asset"],
        "amount":    intent.get("amount"),
        "currency":  intent.get("currency", "USD"),
        "orderType": "market",
        "source": "voice_command",
    }
    return await _post("/api/trades/create", payload, user_id, intent)


# ---------------------------------------------------------------------------
# Invest — invest in a fund or portfolio
# ---------------------------------------------------------------------------

async def execute_invest(user_id: str, intent: dict) -> dict[str, Any]:
    payload = {
        "userId":   user_id,
        "fund":     intent.get("fund", "portfolio"),
        "amount":   intent["amount"],
        "currency": intent.get("currency", "USD"),
        "source": "voice_command",
    }
    return await _post("/api/investments/create", payload, user_id, intent)


# ---------------------------------------------------------------------------
# Internal HTTP helper
# ---------------------------------------------------------------------------

async def _post(path: str, payload: dict, user_id: str, intent: dict) -> dict[str, Any]:
    headers = {}
    if CHRONOS_INTERNAL_TOKEN:
        headers["X-Internal-Token"] = CHRONOS_INTERNAL_TOKEN

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                f"{CHRONOS_BACKEND_URL}{path}",
                json=payload,
                headers=headers,
            )
            resp.raise_for_status()
            return resp.json()
    except httpx.HTTPStatusError as e:
        raise RuntimeError(
            f"Transaction failed ({e.response.status_code}): {e.response.text}"
        )
    except httpx.RequestError:
        if IS_DEV:
            return _mock_result(user_id, intent)
        raise RuntimeError(
            "Cannot reach Chronos backend. Make sure CHRONOS_BACKEND_URL is set."
        )


def _mock_result(user_id: str, intent: dict) -> dict:
    """Mock response for local development when Chronos backend is unreachable."""
    return {
        "transaction_id": f"mock_{uuid.uuid4().hex[:8]}",
        "status":         "COMPLETED",
        "type":           intent.get("type"),
        "user_id":        user_id,
        "details":        intent,
        "mock":           True,
    }
