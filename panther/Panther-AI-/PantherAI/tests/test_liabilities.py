from __future__ import annotations

import math

import pytest
from fastapi.testclient import TestClient

from main import app
from services.conversational_ai import chris as chris_module
from routers.liabilities.router import router
from services.conversational_ai.router import _rule_based_route
from services.conversational_ai.tools import (
    TOOLS_BY_DOMAIN,
    TOOL_DEFINITIONS,
    execute_tool,
)
from services.liabilities.credit_card import (
    _payoff_projection,
    analyze_credit_cards,
    contains_directive_language,
)
from services.liabilities.dti_calculator import calculate_dti
from services.liabilities.ingestion import (
    LiabilitiesConsentError,
    sync_liabilities,
)
from services.liabilities.loans import (
    _months_remaining,
    _remaining_interest,
    analyze_loans,
)
from services.liabilities.mortgage import FCA_REDIRECT, analyze_mortgage

client = TestClient(app)


def test_sync_liabilities_returns_structured_demo_data():
    data = sync_liabilities("marcus", force=True)

    assert data["user_id"] == "user_marcus"
    assert data["credit_cards"]
    assert data["student_loans"]
    assert data["auto_loans"]
    assert data["personal_loans"]
    assert data["mortgages"]
    assert "synced_at" in data
    assert "plaid_response" not in data
    assert "raw_response" not in data


def test_sync_liabilities_requires_liabilities_consent():
    with pytest.raises(LiabilitiesConsentError):
        sync_liabilities("no_consent", force=True)


def test_credit_card_analysis_flags_marcus_and_sarah():
    marcus = analyze_credit_cards("marcus")
    sarah = analyze_credit_cards("sarah")

    assert marcus["utilization_status"] == "DANGER"
    assert marcus["utilization_rate"] > 0.70
    assert marcus["highest_apr_card"] == "cc_marcus_store"
    assert any(card["status"] == "OVERDUE" for card in marcus["cards"])
    assert not contains_directive_language(marcus["insight"])

    assert sarah["utilization_status"] == "HEALTHY"
    assert sarah["utilization_rate"] < 0.30
    assert not contains_directive_language(sarah["insight"])


def test_credit_card_payoff_projection_math():
    no_interest = _payoff_projection(balance=1000.0, apr=0.0, monthly_payment=100.0)
    assert no_interest == {"months": 10, "interest": 0.0}

    impossible = _payoff_projection(balance=1000.0, apr=30.0, monthly_payment=1.0)
    assert impossible["months"] is math.inf
    assert impossible["interest"] is math.inf


def test_loan_analysis_and_math_handle_zero_loan_user():
    marcus = analyze_loans("marcus")
    sarah = analyze_loans("sarah")

    assert marcus["total_loan_debt"] == 30700.0
    assert {loan["loan_type"] for loan in marcus["loans"]} == {
        "STUDENT",
        "AUTO",
        "PERSONAL",
    }
    assert all(loan["months_remaining"] >= 0 for loan in marcus["loans"])
    assert all(loan["total_remaining_interest"] >= 0 for loan in marcus["loans"])

    assert sarah["total_loan_debt"] == 0.0
    assert sarah["loans"] == []

    assert _months_remaining(1000.0, 0.0, 100.0, None) == 10
    assert _remaining_interest(1000.0, 100.0, 10) == 0.0


def test_mortgage_pmi_flag_and_required_redirect():
    bob = analyze_mortgage("bob")
    sarah = analyze_mortgage("sarah")

    assert bob["has_mortgage"] is True
    assert bob["ltv_ratio"] == pytest.approx(0.75)
    assert bob["pmi_removal_eligible"] is True
    assert bob["insight"].endswith(FCA_REDIRECT)

    assert sarah["has_mortgage"] is False
    assert sarah["insight"].endswith(FCA_REDIRECT)


def test_dti_thresholds_for_demo_users():
    marcus = calculate_dti("marcus")
    sarah = calculate_dti("sarah")
    bob = calculate_dti("bob")

    assert marcus["dti_status"] == "CRITICAL"
    assert marcus["dti_ratio"] > 0.50
    assert sarah["dti_status"] == "HEALTHY"
    assert bob["dti_status"] == "ELEVATED"


def test_chris_debt_tools_are_registered_and_compliance_safe():
    debt_tool_names = {
        item["function"]["name"]
        for item in TOOL_DEFINITIONS
        if item["function"]["name"].startswith("get_")
    }

    assert {
        "get_credit_card_analysis",
        "get_loan_analysis",
        "get_mortgage_analysis",
        "get_dti_ratio",
    }.issubset(debt_tool_names)
    assert any(
        item["function"]["name"] == "get_dti_ratio"
        for item in TOOLS_BY_DOMAIN["banking"]
    )

    result = execute_tool("get_credit_card_analysis", "marcus", {})
    assert result["disclaimer"] == "This is an analysis of your data, not debt advice."


def test_debt_questions_route_to_banking_fallback():
    assert _rule_based_route("what do I owe?") == "banking"
    assert _rule_based_route("is my mortgage PMI still active?") == "banking"
    assert _rule_based_route("can I afford to invest while paying debt?") == "unified"


def test_chris_answers_debt_questions_with_live_data_and_disclaimer(monkeypatch):
    monkeypatch.setattr(
        chris_module,
        "_get_client",
        lambda: (_ for _ in ()).throw(ConnectionError("force mock")),
    )

    result = chris_module.chris_chat("user_marcus", "what do I owe?")

    assert {
        "get_credit_card_analysis",
        "get_loan_analysis",
        "get_mortgage_analysis",
        "get_dti_ratio",
    }.issubset(set(result["tools_called"]))
    assert result["context_used"]["total_debt"] == 322700.0
    assert "This is an analysis of your data, not debt advice." in result["response"]


@pytest.mark.parametrize(
    "path",
    [
        "/api/liabilities/credit-cards",
        "/api/liabilities/loans",
        "/api/liabilities/mortgage",
        "/api/liabilities/dti",
        "/api/liabilities/summary",
    ],
)
def test_liabilities_endpoints_return_json(path: str):
    response = client.get(path, params={"user_id": "marcus"})

    assert response.status_code == 200
    assert isinstance(response.json(), dict)


@pytest.mark.parametrize(
    "route_path",
    [route.path for route in router.routes if route.path != "/openapi.json"],
)
def test_liabilities_endpoints_return_403_without_consent(route_path: str):
    response = client.get(f"/api{route_path}", params={"user_id": "no_consent"})

    assert response.status_code == 403
