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
from dotenv import load_dotenv

import plaid
from plaid.api import plaid_api
from plaid.model.products import Products
from plaid.model.country_code import CountryCode

load_dotenv()

# ---------------------------------------------------------------------------
# Config — read from .env
# ---------------------------------------------------------------------------
PLAID_CLIENT_ID = os.environ["PLAID_CLIENT_ID"]
PLAID_SECRET = os.environ["PLAID_SECRET"]
PLAID_ENV = os.getenv("PLAID_ENV", "sandbox")  # sandbox | development | production

# Map env string → Plaid host
_ENV_MAP = {
    "sandbox": plaid.Environment.Sandbox,
    "development": plaid.Environment.Sandbox,
    "production": plaid.Environment.Production,
}

# ---------------------------------------------------------------------------
# Singleton client
# ---------------------------------------------------------------------------
_client: plaid_api.PlaidApi | None = None


def get_plaid_client() -> plaid_api.PlaidApi:
    """
    Returns a configured Plaid API client (singleton).
    Import and call this wherever you need Plaid access.

    >>> client = get_plaid_client()
    """
    global _client
    if _client is not None:
        return _client

    configuration = plaid.Configuration(
        host=_ENV_MAP.get(PLAID_ENV, plaid.Environment.Sandbox),
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
# ---------------------------------------------------------------------------
PLAID_PRODUCTS = [Products("transactions")]
PLAID_COUNTRY_CODES = [CountryCode("US")]
