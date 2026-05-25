"""
Tests for the Transactions API endpoints.

Three endpoints covered:
  GET  /api/transactions          — list transactions with filters
  GET  /api/transactions/:id      — single transaction by ID
  PATCH /api/transactions/:id     — user category correction

Test users: user_marcus, user_sarah, user_bob (seeded in Supabase).
Assumes backfill_categories.py has already been run (transactions have subcategories).
"""

import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


# ---------------------------------------------------------------------------
# GET /api/transactions
# ---------------------------------------------------------------------------

def test_list_transactions_returns_results():
    """user_marcus has transactions — list should return at least one."""
    response = client.get("/api/transactions", params={"user_id": "user_marcus"})
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0


def test_list_transactions_have_category_fields():
    """Every returned transaction must include category fields."""
    response = client.get("/api/transactions", params={"user_id": "user_marcus"})
    assert response.status_code == 200
    for txn in response.json():
        assert "subcategory" in txn
        assert "category_confidence" in txn
        assert "category_source" in txn
        assert "user_corrected" in txn


def test_list_transactions_filter_by_merchant():
    """Merchant filter (partial match) returns only matching transactions."""
    response = client.get("/api/transactions", params={
        "user_id": "user_marcus",
        "merchant": "STARBUCKS",
    })
    assert response.status_code == 200
    data = response.json()
    assert all("STARBUCKS" in t["merchant_name"].upper() for t in data)


def test_list_transactions_filter_by_category():
    """Category filter returns only transactions with that subcategory."""
    response = client.get("/api/transactions", params={
        "user_id": "user_marcus",
        "category": "sub_restaurants_bars",
    })
    assert response.status_code == 200
    data = response.json()
    assert all(t["subcategory"] == "sub_restaurants_bars" for t in data)


def test_list_transactions_unknown_user_returns_404():
    """Unknown user_id → HTTP 404."""
    response = client.get("/api/transactions", params={"user_id": "user_ghost"})
    assert response.status_code == 404


def test_list_transactions_days_filter():
    """days=1 returns fewer or equal results than days=365."""
    r1 = client.get("/api/transactions", params={"user_id": "user_marcus", "days": 1})
    r2 = client.get("/api/transactions", params={"user_id": "user_marcus", "days": 365})
    assert r1.status_code == 200
    assert r2.status_code == 200
    assert len(r1.json()) <= len(r2.json())


# ---------------------------------------------------------------------------
# GET /api/transactions/:id
# ---------------------------------------------------------------------------

def test_get_transaction_by_id():
    """Fetch a known transaction by ID — must return correct fields."""
    # First get a valid ID from the list
    list_res = client.get("/api/transactions", params={"user_id": "user_marcus"})
    assert list_res.status_code == 200
    transactions = list_res.json()
    assert len(transactions) > 0

    txn_id = transactions[0]["id"]
    response = client.get(f"/api/transactions/{txn_id}")
    assert response.status_code == 200

    data = response.json()
    assert data["id"] == txn_id
    assert "merchant_name" in data
    assert "amount" in data
    assert "date" in data


def test_get_transaction_not_found():
    """Non-existent transaction ID → HTTP 404."""
    response = client.get("/api/transactions/00000000-0000-0000-0000-000000000000")
    assert response.status_code == 404


# ---------------------------------------------------------------------------
# PATCH /api/transactions/:id
# ---------------------------------------------------------------------------

def test_patch_category_correction():
    """User can correct a transaction's category — user_corrected becomes True."""
    # Get a valid transaction ID
    list_res = client.get("/api/transactions", params={"user_id": "user_marcus"})
    assert list_res.status_code == 200
    txn_id = list_res.json()[0]["id"]

    response = client.patch(f"/api/transactions/{txn_id}", json={
        "subcategory": "sub_general_misc",
    })
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == txn_id
    assert data["subcategory"] == "sub_general_misc"
    assert data["user_corrected"] is True


def test_patch_category_persisted():
    """After a PATCH, GET on the same ID reflects the corrected category."""
    list_res = client.get("/api/transactions", params={"user_id": "user_sarah"})
    assert list_res.status_code == 200
    txn_id = list_res.json()[0]["id"]

    client.patch(f"/api/transactions/{txn_id}", json={"subcategory": "sub_groceries"})

    get_res = client.get(f"/api/transactions/{txn_id}")
    assert get_res.status_code == 200
    assert get_res.json()["subcategory"] == "sub_groceries"
    assert get_res.json()["user_corrected"] is True


def test_patch_category_not_found():
    """PATCH on non-existent transaction → HTTP 404."""
    response = client.patch(
        "/api/transactions/00000000-0000-0000-0000-000000000000",
        json={"subcategory": "sub_general_misc"},
    )
    assert response.status_code == 404
