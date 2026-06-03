from __future__ import annotations

import time

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from routers.net_worth.router import router as net_worth_router
from services.conversational_ai import chris as chris_module
from services.conversational_ai.router import _rule_based_route
from services.conversational_ai.tools import TOOL_DEFINITIONS, execute_tool
from services.net_worth import (
    SCORE_DISCLAIMER,
    calculate_dta,
    calculate_health_score,
    calculate_net_worth,
    get_net_worth_trend,
)

app = FastAPI()
app.include_router(net_worth_router, prefix="/api")
client = TestClient(app)


def test_net_worth_full_and_partial_demo_users():
    marcus = calculate_net_worth("marcus")
    sarah = calculate_net_worth("sarah")

    assert marcus["net_worth"] == pytest.approx(-321100.0)
    assert marcus["total_assets"] == pytest.approx(1600.0)
    assert marcus["total_liabilities"] == pytest.approx(322700.0)
    assert marcus["data_completeness"] == pytest.approx(0.6)
    assert marcus["missing_sources"] == ["investments", "crypto"]
    assert "top" not in marcus["insight"].lower()

    assert sarah["net_worth"] == pytest.approx(93700.0)
    assert sarah["data_completeness"] == 1.0
    assert sarah["missing_sources"] == []


def test_health_score_has_all_pillars_and_mandatory_disclaimer():
    marcus = calculate_health_score("marcus")
    sarah = calculate_health_score("sarah")

    assert set(marcus["pillars"]) == {
        "spending",
        "saving",
        "debt",
        "investing",
        "income_stability",
    }
    assert marcus["score_disclaimer"] == SCORE_DISCLAIMER
    assert sarah["score_disclaimer"]
    assert marcus["overall_score"] < sarah["overall_score"] - 30
    assert 20 <= marcus["overall_score"] <= 40
    assert 65 <= sarah["overall_score"] <= 85
    assert "credit score" in sarah["score_disclaimer"]


@pytest.mark.parametrize("period", ["30d", "90d", "365d"])
def test_net_worth_trend_periods(period: str):
    trend = get_net_worth_trend("sarah", period)

    assert trend["period"] == period
    assert trend["data_points"]
    assert trend["trend"] in {"IMPROVING", "DECLINING", "STABLE"}
    assert "on track" not in trend["insight"].lower()


def test_dta_thresholds_for_marcus_and_sarah():
    marcus = calculate_dta("marcus")
    sarah = calculate_dta("sarah")

    assert marcus["dta_status"] == "CRITICAL"
    assert marcus["dta_ratio"] > 1.0
    assert sarah["dta_status"] == "HEALTHY"
    assert sarah["dta_ratio"] < 0.3


def test_chris_net_worth_tools_are_registered_and_safe(monkeypatch):
    monkeypatch.setattr(
        chris_module,
        "_get_client",
        lambda: (_ for _ in ()).throw(ConnectionError("force mock")),
    )
    tool_names = {item["function"]["name"] for item in TOOL_DEFINITIONS}

    assert {
        "get_net_worth",
        "get_financial_health_score",
        "get_net_worth_trend",
    }.issubset(tool_names)
    assert _rule_based_route("what's my net worth?") == "banking"

    score = execute_tool("get_financial_health_score", "sarah", {})
    assert score["score_disclaimer"] == SCORE_DISCLAIMER

    result = chris_module.chris_chat("user_sarah", "how am I doing financially?")
    assert "get_financial_health_score" in result["tools_called"]
    assert SCORE_DISCLAIMER in result["response"]
    assert "compared to" not in result["response"].lower()


@pytest.mark.parametrize(
    "path",
    [
        "/api/net-worth",
        "/api/net-worth/health-score",
        "/api/net-worth/trend",
        "/api/net-worth/dta",
        "/api/net-worth/dashboard",
    ],
)
def test_net_worth_endpoints_return_json(path: str):
    response = client.get(path, params={"user_id": "sarah"})

    assert response.status_code == 200
    assert isinstance(response.json(), dict)


def test_dashboard_endpoint_under_500ms():
    started = time.perf_counter()
    response = client.get("/api/net-worth/dashboard", params={"user_id": "sarah"})
    elapsed_ms = (time.perf_counter() - started) * 1000

    assert response.status_code == 200
    assert elapsed_ms < 500
    assert response.json()["duration_ms"] < 500
