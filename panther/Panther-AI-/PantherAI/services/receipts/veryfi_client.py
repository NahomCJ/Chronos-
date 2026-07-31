"""
services/receipts/veryfi_client.py
====================================
Veryfi SDK setup and core client — receipt/invoice OCR with line-item
itemization. Mirrors services/banking/plaid_client.py: never instantiate
the Veryfi client anywhere else.

Plaid tells us a charge happened ("$87.40 at WHOLE FOODS"). Veryfi reads the
actual receipt and returns the line items behind that charge (groceries vs.
alcohol vs. household goods, each priced). That per-item detail is what
services/financial_advisor/full_picture.py uses to go beyond merchant-level
categorization.

Degrades gracefully: if the Veryfi env vars below aren't set,
is_veryfi_configured() returns False and callers fall back to mock OCR
output (see mock_api.py) instead of hitting this client at all.
"""

from __future__ import annotations

import os
from typing import Any

from dotenv import load_dotenv

load_dotenv()

# ---------------------------------------------------------------------------
# Config - read from .env
# ---------------------------------------------------------------------------
VERYFI_CLIENT_ID = os.getenv("VERYFI_CLIENT_ID", "")
VERYFI_CLIENT_SECRET = os.getenv("VERYFI_CLIENT_SECRET", "")
VERYFI_USERNAME = os.getenv("VERYFI_USERNAME", "")
VERYFI_API_KEY = os.getenv("VERYFI_API_KEY", "")

# ---------------------------------------------------------------------------
# Singleton client
# ---------------------------------------------------------------------------
_client: Any | None = None


def is_veryfi_configured() -> bool:
    """True once all four Veryfi credentials are present in the environment."""
    return bool(
        VERYFI_CLIENT_ID and VERYFI_CLIENT_SECRET and VERYFI_USERNAME and VERYFI_API_KEY
    )


def get_veryfi_client() -> Any:
    """
    Returns a configured Veryfi API client (singleton).
    Import and call this wherever you need Veryfi access.

    Raises RuntimeError if credentials aren't configured — callers should
    check is_veryfi_configured() first and fall back to mock OCR (see
    services/receipts/mock_api.py) instead of calling this directly.
    """
    global _client
    if _client is not None:
        return _client

    if not is_veryfi_configured():
        raise RuntimeError(
            "VERYFI_CLIENT_ID, VERYFI_CLIENT_SECRET, VERYFI_USERNAME and "
            "VERYFI_API_KEY must be configured"
        )

    from veryfi import Client

    _client = Client(
        VERYFI_CLIENT_ID,
        VERYFI_CLIENT_SECRET,
        VERYFI_USERNAME,
        VERYFI_API_KEY,
    )
    return _client
