"""Net worth aggregation across connected financial sources.

Investments now sync from real Plaid Investments Holdings via
services/investments/ingestion.py (falling back to deterministic mock
holdings when a user hasn't authorized/connected that product). Crypto and
"other savings" still use deterministic mocks — crypto lives in BlockHub, not
Plaid, so wiring it up is a separate cross-service integration; banking,
income, and liabilities already have local lane services, so this module
calls them and treats missing consent/data as a partial picture rather than a
hard failure.
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from services.banking.mock_api import get_balance
from services.income.ingestion import IncomeConsentError
from services.investments.ingestion import InvestmentsConsentError, get_investments_data
from services.liabilities.ingestion import LiabilitiesConsentError, get_liabilities_data

from .mock_data import (
    EXPECTED_SOURCES,
    connected_sources,
    crypto_fixture,
    has_source,
    normalize_user_id,
    other_savings_fixture,
)


LOW_COMPLETENESS_CAVEAT = (
    " This estimate is based on the accounts you've connected. Connect more "
    "accounts for a fuller picture."
)


def calculate_net_worth(user_id: str) -> dict[str, Any]:
    """Calculates net worth from connected assets minus connected liabilities.

    Missing non-core sources are represented as zero-valued buckets and listed in
    ``missing_sources``. The function only raises ``ValueError`` when the primary
    banking user itself is unknown, matching the rest of the Panther API.
    """

    normalized_user_id = normalize_user_id(user_id)
    missing_sources: list[str] = []
    connected = connected_sources(normalized_user_id)

    bank_balances = _bank_balance(normalized_user_id)
    if "banking" not in connected:
        connected.add("banking")

    investments, investment_holdings = _investment_value(
        normalized_user_id, missing_sources
    )
    crypto = _crypto_value(normalized_user_id, missing_sources)
    other_savings = _other_savings_value(normalized_user_id)
    liabilities, liability_items, liabilities_connected = _liabilities_breakdown(
        normalized_user_id
    )
    if not liabilities_connected:
        missing_sources.append("liabilities")
        connected.discard("liabilities")

    if not _income_connected(normalized_user_id):
        missing_sources.append("income")
        connected.discard("income")

    for source in EXPECTED_SOURCES:
        if source not in connected and source not in missing_sources:
            missing_sources.append(source)

    assets_breakdown = {
        "bank_balances": round(bank_balances, 2),
        "investments": round(investments, 2),
        "crypto": round(crypto, 2),
        "other_savings": round(other_savings, 2),
    }
    liabilities_breakdown = {
        "credit_card_debt": round(liabilities["credit_card_debt"], 2),
        "loans": round(liabilities["loans"], 2),
        "mortgage": round(liabilities["mortgage"], 2),
    }
    total_assets = round(sum(assets_breakdown.values()), 2)
    total_liabilities = round(sum(liabilities_breakdown.values()), 2)
    net_worth = round(total_assets - total_liabilities, 2)
    data_completeness = round(
        (len(EXPECTED_SOURCES) - len(set(missing_sources))) / len(EXPECTED_SOURCES), 2
    )

    return {
        "user_id": normalized_user_id,
        "net_worth": net_worth,
        "total_assets": total_assets,
        "total_liabilities": total_liabilities,
        "assets_breakdown": assets_breakdown,
        "liabilities_breakdown": liabilities_breakdown,
        "investment_holdings": investment_holdings,
        "liability_items": liability_items,
        "data_completeness": data_completeness,
        "missing_sources": sorted(set(missing_sources), key=EXPECTED_SOURCES.index),
        "calculated_at": datetime.now(timezone.utc).isoformat(),
        "insight": _insight(net_worth, data_completeness),
    }


def _bank_balance(user_id: str) -> float:
    return float(get_balance(user_id))


def _investment_value(
    user_id: str, missing_sources: list[str]
) -> tuple[float, list[dict[str, Any]]]:
    try:
        data = get_investments_data(user_id)
        return float(data.get("total_value") or 0.0), data.get("holdings", [])
    except InvestmentsConsentError:
        missing_sources.append("investments")
        return 0.0, []


def _crypto_value(user_id: str, missing_sources: list[str]) -> float:
    if not has_source(user_id, "crypto"):
        missing_sources.append("crypto")
        return 0.0
    return float(crypto_fixture(user_id).get("total_value") or 0.0)


def _other_savings_value(user_id: str) -> float:
    return other_savings_fixture(user_id)


def _liabilities_breakdown(
    user_id: str,
) -> tuple[dict[str, float], list[dict[str, Any]], bool]:
    try:
        from services.liabilities.credit_card import analyze_credit_cards
        from services.liabilities.loans import analyze_loans
        from services.liabilities.mortgage import analyze_mortgage

        credit_cards = analyze_credit_cards(user_id)
        loans = analyze_loans(user_id)
        mortgage = analyze_mortgage(user_id)
        raw = get_liabilities_data(user_id)
        breakdown = {
            "credit_card_debt": float(
                credit_cards.get("total_credit_card_debt") or 0.0
            ),
            "loans": float(loans.get("total_loan_debt") or 0.0),
            "mortgage": float(mortgage.get("outstanding_balance") or 0.0),
        }
        return breakdown, _liability_items(raw), True
    except LiabilitiesConsentError:
        return ({"credit_card_debt": 0.0, "loans": 0.0, "mortgage": 0.0}, [], False)


def _liability_items(raw: dict[str, Any]) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for card in raw.get("credit_cards", []):
        items.append(
            {
                "name": "Credit Card",
                "category": "credit_card",
                "value": round(float(card.get("balance") or 0.0), 2),
                "account_id": card.get("account_id"),
            }
        )
    for loan in raw.get("student_loans", []):
        items.append(
            {
                "name": "Student Loan",
                "category": "student_loan",
                "value": round(float(loan.get("outstanding_balance") or 0.0), 2),
                "account_id": loan.get("account_id"),
            }
        )
    for loan in raw.get("auto_loans", []):
        items.append(
            {
                "name": "Auto Loan",
                "category": "auto_loan",
                "value": round(float(loan.get("outstanding_balance") or 0.0), 2),
                "account_id": loan.get("account_id"),
            }
        )
    for loan in raw.get("personal_loans", []):
        items.append(
            {
                "name": "Personal Loan",
                "category": "personal_loan",
                "value": round(float(loan.get("outstanding_balance") or 0.0), 2),
                "account_id": loan.get("account_id"),
            }
        )
    for mortgage in raw.get("mortgages", []):
        items.append(
            {
                "name": "Mortgage",
                "category": "mortgage",
                "value": round(float(mortgage.get("outstanding_balance") or 0.0), 2),
                "account_id": mortgage.get("account_id"),
            }
        )
    return items


def _income_connected(user_id: str) -> bool:
    if not has_source(user_id, "income"):
        return False
    try:
        from services.income.ingestion import get_income_data

        get_income_data(user_id)
        return True
    except IncomeConsentError:
        return False


def _insight(net_worth: float, data_completeness: float) -> str:
    pct = round(data_completeness * 100)
    base = (
        f"Your connected accounts show a net worth of £{net_worth:,.2f}, "
        f"covering {pct}% of your connected financial picture."
    )
    if data_completeness < 0.6:
        return base + LOW_COMPLETENESS_CAVEAT
    return base
