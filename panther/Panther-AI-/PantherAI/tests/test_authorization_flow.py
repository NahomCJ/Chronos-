"""
Tests for POST /api/authorize-payment (Phase 2 — real services).

Four test cases:
  1. High-risk user with BNPL payment (user_marcus)
  2. Low-risk user with standard payment (user_sarah)
  3. BNPL request missing num_payments → 400
  4. Unknown user → 404
"""

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_high_risk_bnpl_user():
    """user_marcus, $200 BNPL with 4 payments → pending, HIGH cash_flow, BNPL present."""
    response = client.post("/api/authorize-payment", json={
        "user_id": "user_marcus",
        "amount": 200.00,
        "merchant": "AMAZON",
        "payment_type": "bnpl",
        "num_payments": 4,
    })
    assert response.status_code == 200
    data = response.json()

    assert data["status"] == "pending"
    assert "authorization_id" in data

    # Cash flow assertions — real service computes projected balance
    cf = data["warning"]["cash_flow"]
    assert cf["risk_level"] == "HIGH"
    assert cf["is_risky"] is True
    assert cf["projected_balance"] < 0  # Marcus can't cover bills + this payment

    # BNPL assertions — real service returns computed score
    bnpl = data["warning"]["bnpl"]
    assert bnpl is not None
    assert isinstance(bnpl["score"], int)
    assert bnpl["risk_level"] in ("HIGH", "MEDIUM", "LOW")
    assert isinstance(bnpl["risk_factors"], list)

    # Combined message is a single displayable string containing BNPL info
    assert isinstance(data["warning"]["combined_message"], str)
    assert "BNPL Risk:" in data["warning"]["combined_message"]

    # Enum serialization: values must be plain strings, not "RiskLevel.HIGH"
    assert "RiskLevel." not in cf["risk_level"]
    assert "RiskLevel." not in bnpl["risk_level"]


def test_low_risk_standard_payment():
    """user_sarah, $50 standard → LOW cash_flow, bnpl is null."""
    response = client.post("/api/authorize-payment", json={
        "user_id": "user_sarah",
        "amount": 50.00,
        "merchant": "COFFEE_SHOP",
        "payment_type": "standard",
    })
    assert response.status_code == 200
    data = response.json()

    assert data["warning"]["cash_flow"]["risk_level"] == "LOW"
    assert data["warning"]["cash_flow"]["is_risky"] is False
    assert data["warning"]["bnpl"] is None
    assert "BNPL Risk:" not in data["warning"]["combined_message"]

    # Enum serialization check
    assert "RiskLevel." not in data["warning"]["cash_flow"]["risk_level"]


def test_bnpl_missing_num_payments():
    """BNPL request without num_payments → HTTP 400."""
    response = client.post("/api/authorize-payment", json={
        "user_id": "user_marcus",
        "amount": 200.00,
        "merchant": "AMAZON",
        "payment_type": "bnpl",
    })
    assert response.status_code == 400
    assert "num_payments" in response.json()["detail"].lower()


def test_unknown_user_returns_404():
    """Unknown user_id → HTTP 404 with descriptive error message."""
    response = client.post("/api/authorize-payment", json={
        "user_id": "user_nonexistent",
        "amount": 100.00,
        "merchant": "AMAZON",
        "payment_type": "standard",
    })
    assert response.status_code == 404
    assert "unknown user" in response.json()["detail"].lower()
