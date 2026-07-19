"""
services/conversational_ai/payment_executor.py
===============================================
Executes voice payment commands via the Chronos Node.js backend.

Calls POST /api/transfers/create on the Chronos backend.
Falls back to a mock response in development when the backend is unreachable.

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

CHRONOS_BACKEND_URL = os.getenv("CHRONOS_BACKEND_URL", "http://localhost:3001")
CHRONOS_INTERNAL_TOKEN = os.getenv("CHRONOS_INTERNAL_TOKEN", "")
IS_DEV = os.getenv("ENVIRONMENT", "development") == "development"


async def execute_transfer(user_id: str, payment_intent: dict) -> dict[str, Any]:
    """
    Executes a transfer by calling the Chronos Node.js backend.

    Args:
        user_id: Authenticated user ID.
        payment_intent: Parsed PaymentIntent with amount and recipient.

    Returns:
        Transfer result dict with transfer_id and status.

    Raises:
        RuntimeError: If the backend call fails (and not in dev mode).
    """
    payload = {
        "userId": user_id,
        "recipient": payment_intent["recipient"],
        "amount": payment_intent["amount"],
        "currency": payment_intent.get("currency", "USD"),
        "description": "Voice-initiated transfer",
        "source": "voice_command",
    }

    headers = {}
    if CHRONOS_INTERNAL_TOKEN:
        headers["X-Internal-Token"] = CHRONOS_INTERNAL_TOKEN

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                f"{CHRONOS_BACKEND_URL}/api/transfers/create",
                json=payload,
                headers=headers,
            )
            resp.raise_for_status()
            return resp.json()
    except httpx.HTTPStatusError as e:
        raise RuntimeError(
            f"Transfer failed ({e.response.status_code}): {e.response.text}"
        )
    except httpx.RequestError:
        if IS_DEV:
            return _mock_transfer(user_id, payment_intent)
        raise RuntimeError(
            "Cannot reach Chronos backend. Make sure CHRONOS_BACKEND_URL is set."
        )


def _mock_transfer(user_id: str, payment_intent: dict) -> dict:
    """Returns a mock transfer result for local development."""
    return {
        "transfer_id": f"mock_{uuid.uuid4().hex[:8]}",
        "status": "COMPLETED",
        "amount": payment_intent["amount"],
        "recipient": payment_intent["recipient"],
        "currency": payment_intent.get("currency", "USD"),
        "user_id": user_id,
        "mock": True,
    }
