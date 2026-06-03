"""
Plaid Liabilities ingestion with consent gating and field minimization.

The service stores only extracted liability fields used by Panther. It never
persists raw Plaid responses.
"""

from __future__ import annotations

import os
from copy import deepcopy
from datetime import date, datetime, timedelta, timezone
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
_LOCAL_USER_LIABILITIES: dict[str, dict[str, Any]] = {}


class LiabilitiesConsentError(PermissionError):
    """Raised when a user has not authorized Plaid Liabilities access."""


def sync_liabilities(user_id: str, force: bool = False) -> dict[str, Any]:
    """
    Syncs a user's liabilities from Plaid when available, with a 6-hour cache.

    In offline/local mode, returns deterministic mock liabilities for demo users.
    """
    normalized_user_id = normalize_user_id(user_id)
    if not has_liabilities_consent(normalized_user_id):
        raise LiabilitiesConsentError("Plaid Liabilities product is not authorized")

    if not force and normalized_user_id in _SYNC_CACHE:
        return deepcopy(_SYNC_CACHE[normalized_user_id])

    log.contract(
        "sync_liabilities",
        user_id=normalized_user_id,
        synced_at=datetime.now(timezone.utc).isoformat(),
    )

    plaid_payload = _fetch_plaid_liabilities(normalized_user_id)
    if plaid_payload is None:
        data = _mock_liabilities(normalized_user_id)
    else:
        data = _extract_liabilities(plaid_payload)

    data["user_id"] = normalized_user_id
    data["synced_at"] = datetime.now(timezone.utc).isoformat()
    data["retention_expires_at"] = (
        datetime.now(timezone.utc) + timedelta(days=RETENTION_DAYS)
    ).isoformat()
    _persist_liabilities(normalized_user_id, data)
    _SYNC_CACHE[normalized_user_id] = deepcopy(data)
    return deepcopy(data)


def get_liabilities_data(user_id: str) -> dict[str, Any]:
    """Returns cached/synced liabilities for service-layer analysis."""
    return sync_liabilities(user_id)


def has_liabilities_consent(user_id: str) -> bool:
    normalized_user_id = normalize_user_id(user_id)
    if normalized_user_id in _LOCAL_LIABILITIES_CONSENT:
        return _LOCAL_LIABILITIES_CONSENT[normalized_user_id]

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
            return bool(row.get("liabilities_authorized"))
        if isinstance(products, str):
            products = [part.strip() for part in products.split(",")]
        return "liabilities" in {str(product).lower() for product in products}
    except Exception as exc:
        log.failure(
            "has_liabilities_consent",
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


def _fetch_plaid_liabilities(user_id: str) -> dict[str, Any] | None:
    token = _get_plaid_access_token(user_id)
    if not token:
        return None

    try:
        from plaid.model.liabilities_get_request import LiabilitiesGetRequest
        from services.banking.plaid_client import get_plaid_client

        response = get_plaid_client().liabilities_get(
            LiabilitiesGetRequest(access_token=token)
        )
        return response.to_dict() if hasattr(response, "to_dict") else dict(response)
    except Exception as exc:
        log.failure(
            "_fetch_plaid_liabilities",
            error_type=type(exc).__name__,
            message=str(exc),
            user_id=user_id,
            detail="Plaid Liabilities fetch failed; falling back to local liabilities",
        )
        return None


def _extract_liabilities(payload: dict[str, Any]) -> dict[str, Any]:
    liabilities = payload.get("liabilities") or {}
    accounts_by_id = {
        str(account.get("account_id")): account
        for account in payload.get("accounts", [])
        if account.get("account_id")
    }

    return {
        "credit_cards": [
            _extract_credit_card(card, accounts_by_id)
            for card in liabilities.get("credit", [])
        ],
        "student_loans": [
            _extract_installment_loan(loan, "STUDENT")
            for loan in liabilities.get("student", [])
        ],
        "auto_loans": [
            _extract_installment_loan(loan, "AUTO")
            for loan in liabilities.get("auto", [])
        ],
        "personal_loans": [
            _extract_installment_loan(loan, "PERSONAL")
            for loan in liabilities.get("personal", [])
        ],
        "mortgages": [
            _extract_mortgage(mortgage) for mortgage in liabilities.get("mortgage", [])
        ],
    }


def _extract_credit_card(
    card: dict[str, Any], accounts_by_id: dict[str, dict[str, Any]]
) -> dict[str, Any]:
    account_id = str(card.get("account_id") or "")
    account = accounts_by_id.get(account_id, {})
    aprs = card.get("aprs") or []
    purchase_aprs = [
        float(apr.get("apr_percentage"))
        for apr in aprs
        if apr.get("apr_percentage") is not None
        and str(apr.get("apr_type", "")).lower()
        in {"purchase_apr", "cash_apr", "balance_transfer_apr"}
    ]

    return {
        "account_id": account_id,
        "balance": _float(
            card.get("last_statement_balance"), _account_balance(account)
        ),
        "credit_limit": _float(card.get("credit_limit"), _float(account.get("limit"))),
        "apr": max(purchase_aprs) if purchase_aprs else 0.0,
        "minimum_payment": _float(card.get("minimum_payment_amount")),
        "last_payment_date": _iso_date(card.get("last_payment_date")),
        "last_payment_amount": _float(card.get("last_payment_amount")),
        "next_payment_due": _iso_date(card.get("next_payment_due_date")),
    }


def _extract_installment_loan(loan: dict[str, Any], loan_type: str) -> dict[str, Any]:
    balance = _float(
        loan.get("outstanding_principal_balance"),
        _float(loan.get("last_statement_balance")),
    )
    original = _float(
        loan.get("origination_principal_amount"),
        _float(loan.get("original_principal_balance"), balance),
    )
    interest = loan.get("interest_rate") or {}
    status = loan.get("loan_status") or {}

    return {
        "account_id": str(loan.get("account_id") or ""),
        "loan_type": loan_type,
        "outstanding_balance": balance,
        "original_balance": original,
        "interest_rate": _float(
            interest.get("percentage"), _float(loan.get("interest_rate_percentage"))
        ),
        "monthly_payment": _float(
            loan.get("minimum_payment_amount"), _float(loan.get("monthly_payment"))
        ),
        "origination_date": _iso_date(loan.get("origination_date")),
        "expected_payoff_date": _iso_date(loan.get("expected_payoff_date")),
        "last_payment_date": _iso_date(loan.get("last_payment_date")),
        "loan_status": str(
            status.get("type") or loan.get("loan_status") or "CURRENT"
        ).upper(),
    }


def _extract_mortgage(mortgage: dict[str, Any]) -> dict[str, Any]:
    interest = mortgage.get("interest_rate") or {}
    property_address = mortgage.get("property_address") or {}

    return {
        "account_id": str(mortgage.get("account_id") or ""),
        "outstanding_balance": _float(mortgage.get("outstanding_principal_balance")),
        "original_principal": _float(mortgage.get("origination_principal_amount")),
        "interest_rate": _float(interest.get("percentage")),
        "monthly_payment": _float(
            mortgage.get("next_monthly_payment"),
            _float(mortgage.get("monthly_payment")),
        ),
        "has_pmi": bool(mortgage.get("has_pmi")),
        "payoff_date": _iso_date(mortgage.get("expected_payoff_date")),
        "property_address": {
            "city": property_address.get("city"),
            "region": property_address.get("region"),
            "postal_code": property_address.get("postal_code"),
        },
    }


def _persist_liabilities(user_id: str, data: dict[str, Any]) -> None:
    _LOCAL_USER_LIABILITIES[user_id] = deepcopy(data)
    sb = _get_supabase()
    if not sb:
        return

    try:
        cutoff = (
            datetime.now(timezone.utc) - timedelta(days=RETENTION_DAYS)
        ).isoformat()
        sb.table("user_liabilities").delete().eq("user_id", user_id).lt(
            "synced_at", cutoff
        ).execute()
        sb.table("user_liabilities").upsert(
            {
                "user_id": user_id,
                "credit_cards": data["credit_cards"],
                "student_loans": data["student_loans"],
                "auto_loans": data["auto_loans"],
                "personal_loans": data["personal_loans"],
                "mortgages": data["mortgages"],
                "synced_at": data["synced_at"],
                "retention_expires_at": data["retention_expires_at"],
            },
            on_conflict="user_id",
        ).execute()
    except Exception as exc:
        log.failure(
            "_persist_liabilities",
            error_type=type(exc).__name__,
            message=str(exc),
            user_id=user_id,
            detail="user_liabilities write failed; local cache retained",
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


def _account_balance(account: dict[str, Any]) -> float:
    balances = account.get("balances") or {}
    return _float(balances.get("current"))


def _float(value: Any, default: float = 0.0) -> float:
    if value is None:
        return float(default)
    try:
        return float(value)
    except (TypeError, ValueError):
        return float(default)


def _iso_date(value: Any) -> str | None:
    if not value:
        return None
    if isinstance(value, date):
        return value.isoformat()
    return str(value)[:10]


def _future_date(days: int) -> str:
    return (date.today() + timedelta(days=days)).isoformat()


def _past_date(days: int) -> str:
    return (date.today() - timedelta(days=days)).isoformat()


def _payoff_date(years: int, month: int = 6, day: int = 15) -> str:
    return date(date.today().year + years, month, day).isoformat()


_LOCAL_LIABILITIES_CONSENT = {
    "user_marcus": True,
    "user_sarah": True,
    "user_bob": True,
    "user_no_consent": False,
}


_LOCAL_LIABILITIES: dict[str, dict[str, Any]] = {
    "user_marcus": {
        "gross_monthly_income": 5200.0,
        "credit_cards": [
            {
                "account_id": "cc_marcus_visa",
                "balance": 7800.0,
                "credit_limit": 10000.0,
                "apr": 24.99,
                "minimum_payment": 240.0,
                "last_payment_date": _past_date(45),
                "last_payment_amount": 220.0,
                "next_payment_due": _past_date(2),
            },
            {
                "account_id": "cc_marcus_store",
                "balance": 2200.0,
                "credit_limit": 2500.0,
                "apr": 29.99,
                "minimum_payment": 90.0,
                "last_payment_date": _past_date(20),
                "last_payment_amount": 90.0,
                "next_payment_due": _future_date(5),
            },
        ],
        "student_loans": [
            {
                "account_id": "loan_marcus_student",
                "loan_type": "STUDENT",
                "outstanding_balance": 18000.0,
                "original_balance": 30000.0,
                "interest_rate": 6.2,
                "monthly_payment": 310.0,
                "origination_date": "2019-08-15",
                "expected_payoff_date": _payoff_date(5),
                "last_payment_date": _past_date(18),
                "loan_status": "CURRENT",
            }
        ],
        "auto_loans": [
            {
                "account_id": "loan_marcus_auto",
                "loan_type": "AUTO",
                "outstanding_balance": 9200.0,
                "original_balance": 18000.0,
                "interest_rate": 7.4,
                "monthly_payment": 420.0,
                "origination_date": "2022-04-01",
                "expected_payoff_date": _payoff_date(2),
                "last_payment_date": _past_date(11),
                "loan_status": "CURRENT",
            }
        ],
        "personal_loans": [
            {
                "account_id": "loan_marcus_personal",
                "loan_type": "PERSONAL",
                "outstanding_balance": 3500.0,
                "original_balance": 5000.0,
                "interest_rate": 12.5,
                "monthly_payment": 180.0,
                "origination_date": "2024-02-01",
                "expected_payoff_date": _payoff_date(1),
                "last_payment_date": _past_date(7),
                "loan_status": "CURRENT",
            }
        ],
        "mortgages": [
            {
                "account_id": "mortgage_marcus_home",
                "outstanding_balance": 282000.0,
                "original_principal": 350000.0,
                "interest_rate": 5.75,
                "monthly_payment": 2200.0,
                "has_pmi": True,
                "payoff_date": _payoff_date(24, 4, 1),
                "property_address": {
                    "city": "San Francisco",
                    "region": "CA",
                    "postal_code": "94110",
                },
            }
        ],
    },
    "user_sarah": {
        "gross_monthly_income": 6500.0,
        "credit_cards": [
            {
                "account_id": "cc_sarah_rewards",
                "balance": 750.0,
                "credit_limit": 8000.0,
                "apr": 18.99,
                "minimum_payment": 35.0,
                "last_payment_date": _past_date(12),
                "last_payment_amount": 500.0,
                "next_payment_due": _future_date(16),
            }
        ],
        "student_loans": [],
        "auto_loans": [],
        "personal_loans": [],
        "mortgages": [],
    },
    "user_bob": {
        "gross_monthly_income": 5200.0,
        "credit_cards": [
            {
                "account_id": "cc_bob_cashback",
                "balance": 2500.0,
                "credit_limit": 8000.0,
                "apr": 21.99,
                "minimum_payment": 95.0,
                "last_payment_date": _past_date(16),
                "last_payment_amount": 120.0,
                "next_payment_due": _future_date(8),
            }
        ],
        "student_loans": [],
        "auto_loans": [
            {
                "account_id": "loan_bob_auto",
                "loan_type": "AUTO",
                "outstanding_balance": 7200.0,
                "original_balance": 14000.0,
                "interest_rate": 8.1,
                "monthly_payment": 310.0,
                "origination_date": "2022-10-01",
                "expected_payoff_date": _payoff_date(2),
                "last_payment_date": _past_date(9),
                "loan_status": "CURRENT",
            }
        ],
        "personal_loans": [],
        "mortgages": [
            {
                "account_id": "mortgage_bob_condo",
                "outstanding_balance": 240000.0,
                "original_principal": 320000.0,
                "interest_rate": 4.85,
                "monthly_payment": 1450.0,
                "has_pmi": True,
                "payoff_date": _payoff_date(21, 1, 1),
                "property_address": {
                    "city": "Oakland",
                    "region": "CA",
                    "postal_code": "94612",
                },
            }
        ],
    },
}


def _mock_liabilities(user_id: str) -> dict[str, Any]:
    if user_id not in _LOCAL_LIABILITIES:
        raise ValueError(f"Unknown user: {user_id}")
    return deepcopy(_LOCAL_LIABILITIES[user_id])
