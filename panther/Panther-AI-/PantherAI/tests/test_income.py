from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from main import app
from services.conversational_ai.router import _rule_based_route
from services.conversational_ai.tools import TOOL_DEFINITIONS, execute_tool
from services.income import (
    IncomeConsentError,
    analyze_income_stability,
    get_paycheck_plan,
    get_tax_awareness,
    sync_income,
)
from services.income import ingestion

client = TestClient(app)


@pytest.fixture(autouse=True)
def clear_income_cache():
    ingestion._SYNC_CACHE.clear()
    ingestion._LOCAL_SANITIZED_INCOME.clear()
    yield
    ingestion._SYNC_CACHE.clear()
    ingestion._LOCAL_SANITIZED_INCOME.clear()


def test_sync_income_prioritizes_payroll_over_bank(monkeypatch):
    payroll_payload = {
        "payroll_income": [
            {
                "account_id": "payroll_test",
                "pay_frequency": "MONTHLY",
                "pay_stubs": [
                    {
                        "gross_earnings": {"current_pay": 4100.0},
                        "net_earnings": {"current_pay": 3000.0},
                        "pay_period_start_date": "2026-05-01",
                        "pay_period_end_date": "2026-05-31",
                    }
                ],
            }
        ]
    }
    bank_payload = {
        "bank_income": [
            {
                "income_sources": [
                    {
                        "income_source_id": "bank_test",
                        "income_category": "GIG_ECONOMY",
                        "monthly_income": 9999.0,
                        "transaction_count": 9,
                    }
                ]
            }
        ]
    }
    monkeypatch.setattr(
        ingestion,
        "_fetch_plaid_income",
        lambda _user_id: (payroll_payload, bank_payload),
    )

    data = sync_income("sarah", force=True)

    assert data["has_payroll_connection"] is True
    assert data["income_type"] == "MIXED"
    assert data["estimated_monthly_income"] == 4100.0
    assert data["source_priority"] == "PAYROLL"


def test_sync_income_falls_back_to_bank_income(monkeypatch):
    bank_payload = {
        "bank_income": [
            {
                "income_sources": [
                    {
                        "income_source_id": "bank_marcus",
                        "income_category": "GIG_ECONOMY",
                        "monthly_income": 2400.0,
                        "transaction_count": 12,
                    }
                ]
            }
        ]
    }
    monkeypatch.setattr(
        ingestion,
        "_fetch_plaid_income",
        lambda _user_id: (None, bank_payload),
    )

    data = sync_income("marcus", force=True)

    assert data["has_payroll_connection"] is False
    assert data["income_type"] == "IRREGULAR"
    assert data["estimated_monthly_income"] == 2400.0
    assert data["source_priority"] == "BANK"


def test_sync_income_zero_unknown_and_consent_cases():
    zero = sync_income("zero_income", force=True)
    assert zero["income_type"] == "UNKNOWN"
    assert zero["estimated_monthly_income"] == 0.0
    assert zero["income_sources"] == []

    with pytest.raises(IncomeConsentError):
        sync_income("no_consent", force=True)

    with pytest.raises(ValueError):
        sync_income("user_missing", force=True)


def test_income_storage_is_bracketed_and_minimized():
    sync_income("sarah", force=True)
    stored = ingestion._LOCAL_SANITIZED_INCOME["user_sarah"]
    stored_text = str(stored)

    assert "6500" not in stored_text
    assert "78000" not in stored_text
    assert "raw" not in stored_text.lower()
    assert "employer" not in stored_text.lower()
    assert stored["estimated_monthly_income_range"].endswith("range")


def test_stability_profiles_for_marcus_and_sarah():
    marcus = analyze_income_stability("marcus")
    sarah = analyze_income_stability("sarah")

    assert marcus["stability_status"] in {"VOLATILE", "IRREGULAR"}
    assert marcus["expected_next_income_date"] is None

    assert sarah["stability_status"] == "STABLE"
    assert sarah["expected_next_income_date"] is not None
    assert sarah["expected_next_income_date"].day == 1


def test_paycheck_plan_flags_marcus_and_calculates_sarah_daily_spend():
    marcus = get_paycheck_plan("marcus")
    sarah = get_paycheck_plan("sarah")

    assert marcus["will_overdraft"] is True
    assert marcus["overdraft_risk_date"] is not None
    assert marcus["balance_after_bills"] < 0

    assert sarah["will_overdraft"] is False
    assert sarah["days_until_next_income"] > 0
    assert sarah["recommended_daily_spend"] == pytest.approx(
        sarah["balance_after_bills"] / sarah["days_until_next_income"],
        abs=0.01,
    )


def test_tax_awareness_flags_and_no_tax_liability_language():
    marcus = get_tax_awareness("marcus")
    sarah = get_tax_awareness("sarah")

    marcus_flags = {flag["flag_type"] for flag in marcus["tax_flags"]}
    sarah_flags = {flag["flag_type"] for flag in sarah["tax_flags"]}

    assert "SELF_EMPLOYMENT_INCOME" in marcus_flags
    assert "HIGHER_RATE_BAND" in sarah_flags
    for payload in (marcus, sarah):
        text = str(payload).lower()
        assert "you owe" not in text
        assert "tax owed" not in text
        for flag in payload["tax_flags"]:
            assert (
                flag["advisor_prompt"]
                == "You may want to speak to a qualified tax advisor or check HMRC directly."
            )
            assert flag["message"].endswith(flag["advisor_prompt"])


@pytest.mark.parametrize(
    "path",
    [
        "/api/income/stability",
        "/api/income/paycheck-plan",
        "/api/income/tax-awareness",
        "/api/income/summary",
    ],
)
@pytest.mark.parametrize("user_id", ["marcus", "sarah"])
def test_income_endpoints_return_json(path: str, user_id: str):
    response = client.get(path, params={"user_id": user_id})

    assert response.status_code == 200
    assert isinstance(response.json(), dict)


@pytest.mark.parametrize(
    "path",
    [
        "/api/income/stability",
        "/api/income/paycheck-plan",
        "/api/income/tax-awareness",
        "/api/income/summary",
    ],
)
def test_income_endpoints_return_403_without_consent(path: str):
    response = client.get(path, params={"user_id": "no_consent"})

    assert response.status_code == 403


def test_kevin_income_tools_are_registered_and_ai_safe():
    tool_names = {item["function"]["name"] for item in TOOL_DEFINITIONS}
    assert {
        "get_income_stability",
        "get_paycheck_plan",
        "get_tax_awareness",
    }.issubset(tool_names)

    assert _rule_based_route("when do I get paid?") == "banking"
    assert _rule_based_route("do I need to worry about tax?") == "banking"

    stability = execute_tool("get_income_stability", "sarah", {})
    tax = execute_tool("get_tax_awareness", "sarah", {})
    combined = str({"stability": stability, "tax": tax})

    assert "average_monthly_income" not in stability
    assert "estimated_annual_income" not in tax
    assert "6500" not in combined
    assert "78000" not in combined
    assert "range" in combined
