"""
Plaid Investments Holdings ingestion with consent gating and field minimization.

Mirrors services/liabilities/ingestion.py's structure: a 6-hour synced cache,
a consent gate backed by the same plaid_tokens.authorized_products column, a
real-Plaid-with-mock-fallback fetch, and minimized field storage (raw Plaid
responses are never persisted).
"""

from __future__ import annotations

import os
from copy import deepcopy
from datetime import datetime, timedelta, timezone
from typing import Any

from cachetools import TTLCache
from dotenv import load_dotenv

from core.logger import log

load_dotenv()

SYNC_TTL_SECONDS = 6 * 60 * 60
RETENTION_DAYS = 90

_SYNC_CACHE: TTLCache[str, dict[str, Any]] = TTLCache(
    maxsize=10_000, ttl=SYNC_TTL_SECONDS
)
_LOCAL_USER_INVESTMENTS: dict[str, dict[str, Any]] = {}


class InvestmentsConsentError(PermissionError):
    """Raised when a user has not authorized Plaid Investments access."""


def sync_investments(user_id: str, force: bool = False) -> dict[str, Any]:
    """
    Syncs a user's investment holdings from Plaid when available, with a
    6-hour cache.

    In offline/local mode, returns deterministic mock holdings for demo users.
    """
    normalized_user_id = normalize_user_id(user_id)
    if not has_investments_consent(normalized_user_id):
        raise InvestmentsConsentError("Plaid Investments product is not authorized")

    if not force and normalized_user_id in _SYNC_CACHE:
        return deepcopy(_SYNC_CACHE[normalized_user_id])

    log.contract(
        "sync_investments",
        user_id=normalized_user_id,
        synced_at=datetime.now(timezone.utc).isoformat(),
    )

    plaid_payload = _fetch_plaid_investments(normalized_user_id)
    if plaid_payload is None:
        data = _mock_investments(normalized_user_id)
    else:
        data = _extract_investments(plaid_payload)

    data["user_id"] = normalized_user_id
    data["synced_at"] = datetime.now(timezone.utc).isoformat()
    data["retention_expires_at"] = (
        datetime.now(timezone.utc) + timedelta(days=RETENTION_DAYS)
    ).isoformat()
    _persist_investments(normalized_user_id, data)
    _SYNC_CACHE[normalized_user_id] = deepcopy(data)
    return deepcopy(data)


def get_investments_data(user_id: str) -> dict[str, Any]:
    """Returns cached/synced investment holdings for service-layer analysis."""
    return sync_investments(user_id)


def has_investments_consent(user_id: str) -> bool:
    normalized_user_id = normalize_user_id(user_id)
    if normalized_user_id in _LOCAL_INVESTMENTS_CONSENT:
        return _LOCAL_INVESTMENTS_CONSENT[normalized_user_id]

    sb = _get_supabase()
    if not sb:
        return False

    try:
        res = (
            sb.table("plaid_tokens")
            .select("*")
            .eq("user_id", normalized_user_id)
            .execute()
        )
        if not res.data:
            return False
        row = res.data[0]
        products = row.get("products") or row.get("authorized_products")
        if products is None:
            return bool(row.get("investments_authorized"))
        if isinstance(products, str):
            products = [part.strip() for part in products.split(",")]
        return "investments" in {str(product).lower() for product in products}
    except Exception as exc:
        log.failure(
            "has_investments_consent",
            error_type=type(exc).__name__,
            message=str(exc),
            user_id=normalized_user_id,
        )
        return False


def normalize_user_id(user_id: str) -> str:
    value = str(user_id or "").strip().lower()
    if value.startswith("user_"):
        return value
    return f"user_{value}"


def _fetch_plaid_investments(user_id: str) -> dict[str, Any] | None:
    token = _get_plaid_access_token(user_id)
    if not token:
        return None

    try:
        from plaid.model.investments_holdings_get_request import (
            InvestmentsHoldingsGetRequest,
        )

        from services.banking.plaid_client import get_plaid_client

        response = get_plaid_client().investments_holdings_get(
            InvestmentsHoldingsGetRequest(access_token=token)
        )
        return response.to_dict() if hasattr(response, "to_dict") else dict(response)
    except Exception as exc:
        log.failure(
            "_fetch_plaid_investments",
            error_type=type(exc).__name__,
            message=str(exc),
            user_id=user_id,
            detail="Plaid Investments fetch failed; falling back to local investments",
        )
        return None


_ASSET_CLASS_MAP = {
    "equity": "equities",
    "etf": "equities",
    "mutual fund": "equities",
    "fixed income": "bonds",
    "cash": "cash",
    "cryptocurrency": "crypto",
    "derivative": "other",
    "loan": "other",
}


def _asset_class(security: dict[str, Any]) -> str:
    security_type = str(security.get("type") or "").lower()
    return _ASSET_CLASS_MAP.get(security_type, "other")


def _extract_investments(payload: dict[str, Any]) -> dict[str, Any]:
    securities_by_id = {
        str(security.get("security_id")): security
        for security in payload.get("securities", [])
        if security.get("security_id")
    }

    holdings = [
        {
            "account_id": str(holding.get("account_id") or ""),
            "security_id": str(holding.get("security_id") or ""),
            "name": (
                securities_by_id.get(str(holding.get("security_id")), {}).get("name")
                or securities_by_id.get(str(holding.get("security_id")), {}).get(
                    "ticker_symbol"
                )
                or "Unknown holding"
            ),
            "ticker_symbol": securities_by_id.get(
                str(holding.get("security_id")), {}
            ).get("ticker_symbol"),
            "asset_class": _asset_class(
                securities_by_id.get(str(holding.get("security_id")), {})
            ),
            "quantity": _float(holding.get("quantity")),
            "price": _float(holding.get("institution_price")),
            "value": _float(holding.get("institution_value")),
        }
        for holding in payload.get("holdings", [])
    ]

    return _summarize_holdings(holdings)


def _summarize_holdings(holdings: list[dict[str, Any]]) -> dict[str, Any]:
    total_value = round(sum(item["value"] for item in holdings), 2)
    asset_classes = sorted({item["asset_class"] for item in holdings if item["value"] > 0})
    return {
        "holdings": holdings,
        "total_value": total_value,
        "holding_count": len(holdings),
        "asset_classes": asset_classes,
        "diversified": len(asset_classes) >= 2,
    }


def _persist_investments(user_id: str, data: dict[str, Any]) -> None:
    _LOCAL_USER_INVESTMENTS[user_id] = deepcopy(data)
    sb = _get_supabase()
    if not sb:
        return

    try:
        cutoff = (
            datetime.now(timezone.utc) - timedelta(days=RETENTION_DAYS)
        ).isoformat()
        sb.table("user_investments").delete().eq("user_id", user_id).lt(
            "synced_at", cutoff
        ).execute()
        sb.table("user_investments").upsert(
            {
                "user_id": user_id,
                "holdings": data["holdings"],
                "total_value": data["total_value"],
                "holding_count": data["holding_count"],
                "asset_classes": data["asset_classes"],
                "diversified": data["diversified"],
                "synced_at": data["synced_at"],
                "retention_expires_at": data["retention_expires_at"],
            },
            on_conflict="user_id",
        ).execute()
    except Exception as exc:
        log.failure(
            "_persist_investments",
            error_type=type(exc).__name__,
            message=str(exc),
            user_id=user_id,
            detail="user_investments write failed; local cache retained",
        )


def _get_supabase():
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    if not url or not key:
        return None
    try:
        from supabase import create_client

        return create_client(url, key)
    except Exception:
        return None


def _get_plaid_access_token(user_id: str) -> str | None:
    sb = _get_supabase()
    if not sb:
        return None
    try:
        res = (
            sb.table("plaid_tokens")
            .select("access_token")
            .eq("user_id", user_id)
            .execute()
        )
        if res.data:
            return res.data[0]["access_token"]
    except Exception:
        return None
    return None


def _float(value: Any, default: float = 0.0) -> float:
    if value is None:
        return float(default)
    try:
        return float(value)
    except (TypeError, ValueError):
        return float(default)


# ---------------------------------------------------------------------------
# Local/offline mode — deterministic demo fixtures.
#
# Totals match the pre-existing services/net_worth/mock_data.py fixtures
# exactly (user_sarah $62,000/9 holdings, user_bob $18,000/2 holdings,
# user_marcus not connected) so replacing the old aggregate-only mock with
# this itemized one doesn't shift any existing net-worth/health-score numbers
# for the demo users — it only adds the per-holding breakdown on top.
# ---------------------------------------------------------------------------
_LOCAL_INVESTMENTS_CONSENT = {
    "user_marcus": False,
    "user_sarah": True,
    "user_bob": True,
    "user_no_consent": False,
}


_LOCAL_INVESTMENTS: dict[str, dict[str, Any]] = {
    "user_sarah": {
        "holdings": [
            {"account_id": "inv_sarah_brokerage", "security_id": "sec_vti", "name": "Vanguard Total Stock Market ETF", "ticker_symbol": "VTI", "asset_class": "equities", "quantity": 62.0, "price": 225.81, "value": 14000.0},
            {"account_id": "inv_sarah_brokerage", "security_id": "sec_vxus", "name": "Vanguard Total International Stock ETF", "ticker_symbol": "VXUS", "asset_class": "equities", "quantity": 105.0, "price": 57.14, "value": 6000.0},
            {"account_id": "inv_sarah_brokerage", "security_id": "sec_aapl", "name": "Apple Inc", "ticker_symbol": "AAPL", "asset_class": "equities", "quantity": 36.0, "price": 236.11, "value": 8500.0},
            {"account_id": "inv_sarah_brokerage", "security_id": "sec_msft", "name": "Microsoft Corp", "ticker_symbol": "MSFT", "asset_class": "equities", "quantity": 17.0, "price": 423.53, "value": 7200.0},
            {"account_id": "inv_sarah_brokerage", "security_id": "sec_bnd", "name": "Vanguard Total Bond Market ETF", "ticker_symbol": "BND", "asset_class": "bonds", "quantity": 116.0, "price": 77.59, "value": 9000.0},
            {"account_id": "inv_sarah_brokerage", "security_id": "sec_agg", "name": "iShares Core US Aggregate Bond ETF", "ticker_symbol": "AGG", "asset_class": "bonds", "quantity": 43.0, "price": 100.0, "value": 4300.0},
            {"account_id": "inv_sarah_401k", "security_id": "sec_401k_td2055", "name": "401(k) Target Date 2055 Fund", "ticker_symbol": None, "asset_class": "retirement", "quantity": 1.0, "price": 8000.0, "value": 8000.0},
            {"account_id": "inv_sarah_brokerage", "security_id": "sec_nvda", "name": "Nvidia Corp", "ticker_symbol": "NVDA", "asset_class": "equities", "quantity": 25.0, "price": 140.0, "value": 3500.0},
            {"account_id": "inv_sarah_brokerage", "security_id": "sec_cash", "name": "Cash sweep", "ticker_symbol": None, "asset_class": "cash", "quantity": 1500.0, "price": 1.0, "value": 1500.0},
        ],
    },
    "user_bob": {
        "holdings": [
            {"account_id": "inv_bob_brokerage", "security_id": "sec_voo", "name": "Vanguard S&P 500 ETF", "ticker_symbol": "VOO", "asset_class": "equities", "quantity": 22.0, "price": 545.45, "value": 12000.0},
            {"account_id": "inv_bob_brokerage", "security_id": "sec_aapl", "name": "Apple Inc", "ticker_symbol": "AAPL", "asset_class": "equities", "quantity": 25.0, "price": 240.0, "value": 6000.0},
        ],
    },
}


def _mock_investments(user_id: str) -> dict[str, Any]:
    holdings = deepcopy(_LOCAL_INVESTMENTS.get(user_id, {"holdings": []})["holdings"])
    return _summarize_holdings(holdings)
