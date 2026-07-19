"""
services/banking/plaid_client.py
=================================
Plaid SDK setup and core client.
All other Plaid files import from here — never instantiate the client elsewhere.

SANDBOX MODE:
  We use Plaid Sandbox for development. No real bank credentials needed.
  Sandbox test credentials:
    username: user_good
    password: pass_good
"""

import os
from typing import Any

from dotenv import load_dotenv

load_dotenv()

# ---------------------------------------------------------------------------
# Config - read from .env
# ---------------------------------------------------------------------------
PLAID_CLIENT_ID = os.getenv("PLAID_CLIENT_ID", "")
PLAID_SECRET = os.getenv("PLAID_SECRET", "")
PLAID_ENV = os.getenv("PLAID_ENV", "sandbox")  # sandbox | development | production

# ---------------------------------------------------------------------------
# Singleton client
# ---------------------------------------------------------------------------
_client: Any | None = None


def get_plaid_client() -> Any:
    """
    Returns a configured Plaid API client (singleton).
    Import and call this wherever you need Plaid access.

    >>> client = get_plaid_client()
    """
    global _client
    if _client is not None:
        return _client

    if not PLAID_CLIENT_ID or not PLAID_SECRET:
        raise RuntimeError("PLAID_CLIENT_ID and PLAID_SECRET must be configured")

    import plaid
    from plaid.api import plaid_api

    env_map = {
        "sandbox": plaid.Environment.Sandbox,
        "development": plaid.Environment.Sandbox,
        "production": plaid.Environment.Production,
    }
    configuration = plaid.Configuration(
        host=env_map.get(PLAID_ENV, plaid.Environment.Sandbox),
        api_key={
            "clientId": PLAID_CLIENT_ID,
            "secret": PLAID_SECRET,
        },
    )
    api_client = plaid.ApiClient(configuration)
    _client = plaid_api.PlaidApi(api_client)
    return _client


# ---------------------------------------------------------------------------
# Constants used across Plaid modules
#
# "investments" and "liabilities" were added so the Link token actually
# requests entitlement for the Investments Holdings and Liabilities products —
# services/investments/ingestion.py and services/liabilities/ingestion.py call
# investments_holdings_get/liabilities_get against whatever access token this
# Link flow produces, so the token needs to carry that product entitlement.
# ---------------------------------------------------------------------------
PLAID_PRODUCTS = ["transactions", "investments", "liabilities"]
PLAID_COUNTRY_CODES = ["US"]
