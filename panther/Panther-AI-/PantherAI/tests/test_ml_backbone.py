from fastapi.testclient import TestClient

from main import app
from services.cashflow import cashflow_predictor
from services.cashflow.cashflow_predictor import predict_cashflow
from services.subscriptions.detector import (
    detect_subscriptions,
    get_cached_recurring_charges,
)

client = TestClient(app)


def test_cashflow_demo_users_have_expected_risk_bands():
    marcus = predict_cashflow("user_marcus", days=[30])
    sarah = predict_cashflow("user_sarah", days=[30])
    bob = predict_cashflow("user_bob", days=[30])

    assert marcus["overdraft_risk"] == "HIGH"
    assert marcus["days_until_zero"] <= 14
    assert marcus["confidence"] == "high"

    assert sarah["overdraft_risk"] == "LOW"
    assert sarah["days_until_zero"] > 30

    assert bob["overdraft_risk"] == "MEDIUM"


def test_cashflow_low_confidence_when_history_under_30_days(monkeypatch):
    monkeypatch.setattr(
        cashflow_predictor,
        "get_transactions",
        lambda user_id, days_back=370: [
            {"merchant": "PAYROLL", "amount": 1000.0, "date": "2026-05-01"},
            {"merchant": "COFFEE", "amount": -5.0, "date": "2026-05-03"},
        ],
    )
    monkeypatch.setattr(cashflow_predictor, "get_balance", lambda user_id: 995.0)
    monkeypatch.setattr(cashflow_predictor, "get_upcoming_bills", lambda *a, **k: [])
    monkeypatch.setattr(cashflow_predictor, "detect_subscriptions", lambda *a, **k: [])

    forecast = predict_cashflow("user_short", days=[7])

    assert forecast["confidence"] == "low"
    assert len(forecast["projected_balance_series"]) == 7


def test_subscription_detector_finds_marcus_core_patterns():
    charges = detect_subscriptions("user_marcus", persist=True)
    merchants = {charge["merchant"] for charge in charges}

    assert {"Netflix", "Spotify", "Rent"}.issubset(merchants)
    assert all(charge["next_charge_date"] for charge in charges)
    assert get_cached_recurring_charges("user_marcus") == charges


def test_cashflow_forecast_endpoint_returns_chart_ready_json():
    response = client.get(
        "/api/insights/cashflow-forecast",
        params={"user_id": "user_marcus", "days": 30},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["overdraft_risk"] == "HIGH"
    assert len(data["projected_balance_series"]) == 30
    assert {"date", "projected_balance"} <= set(data["projected_balance_series"][0])


def test_subscriptions_endpoint_returns_marcus_patterns_and_total():
    response = client.get(
        "/api/insights/subscriptions",
        params={"user_id": "user_marcus"},
    )

    assert response.status_code == 200
    data = response.json()
    merchants = {charge["merchant"] for charge in data["subscriptions"]}
    assert {"Netflix", "Spotify", "Rent"}.issubset(merchants)
    assert data["monthly_total"] >= 1526.98
    assert all("unused_for_30_days" in charge for charge in data["subscriptions"])
