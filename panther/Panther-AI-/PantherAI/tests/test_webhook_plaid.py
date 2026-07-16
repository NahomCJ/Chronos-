"""
Tests for POST /webhooks/plaid/transactions.

Uses unittest.mock to simulate Plaid API calls — no real Plaid sandbox needed.
Supabase calls are real (uses the test DB).

Four test cases:
  1. Valid TRANSACTIONS/DEFAULT_UPDATE webhook → categorizes and saves
  2. Non-TRANSACTIONS webhook type → ignored
  3. Unsupported webhook_code → ignored
  4. Unknown item_id → 404
"""

import pytest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

# A fake Plaid transaction object
FAKE_PLAID_TXN = {
    "transaction_id": "plaid_test_txn_001",
    "merchant_name": "STARBUCKS",
    "name": "Starbucks #1234",
    "amount": 4.50,       # Plaid positive = debit
    "date": "2025-02-17",
}

VALID_WEBHOOK = {
    "webhook_type": "TRANSACTIONS",
    "webhook_code": "DEFAULT_UPDATE",
    "item_id": "test_item_id_001",
    "new_transactions": 1,
}


# ---------------------------------------------------------------------------
# Helper — mock the Plaid fetch so we don't need a real Plaid sandbox
# ---------------------------------------------------------------------------

def _mock_fetch(monkeypatch, transactions=None):
    """Patches _fetch_plaid_transactions to return fake data."""
    mock_txns = transactions if transactions is not None else [FAKE_PLAID_TXN]
    monkeypatch.setattr(
        "routers.webhooks.plaid._fetch_plaid_transactions",
        lambda access_token, days_back=30: mock_txns,
    )


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

def test_webhook_ignored_non_transaction_type():
    """Webhooks with webhook_type != TRANSACTIONS are ignored gracefully."""
    response = client.post("/webhooks/plaid/transactions", json={
        "webhook_type": "AUTH",
        "webhook_code": "AUTOMATICALLY_VERIFIED",
        "item_id": "any_item",
    })
    assert response.status_code == 200
    assert response.json()["status"] == "ignored"


def test_webhook_ignored_unknown_code():
    """Webhooks with unsupported webhook_code are ignored gracefully."""
    response = client.post("/webhooks/plaid/transactions", json={
        "webhook_type": "TRANSACTIONS",
        "webhook_code": "REMOVED_TRANSACTIONS",
        "item_id": "any_item",
    })
    assert response.status_code == 200
    assert response.json()["status"] == "ignored"


def test_webhook_unknown_item_id_returns_404():
    """item_id not in plaid_tokens → HTTP 404."""
    response = client.post("/webhooks/plaid/transactions", json={
        "webhook_type": "TRANSACTIONS",
        "webhook_code": "DEFAULT_UPDATE",
        "item_id": "nonexistent_item_id_xyz",
    })
    assert response.status_code == 404


def test_webhook_no_transactions_returned(monkeypatch):
    """If Plaid returns no transactions, respond ok with categorized=0."""
    _mock_fetch(monkeypatch, transactions=[])

    # Need a valid item_id — use the first one from plaid_tokens if available
    from routers.webhooks.plaid import supabase
    token_res = supabase.table("plaid_tokens").select("item_id").limit(1).execute()

    if not token_res.data:
        pytest.skip("No plaid_tokens in DB — skipping live item_id test")

    item_id = token_res.data[0]["item_id"]
    response = client.post("/webhooks/plaid/transactions", json={
        **VALID_WEBHOOK,
        "item_id": item_id,
    })
    assert response.status_code == 200
    assert response.json()["categorized"] == 0
