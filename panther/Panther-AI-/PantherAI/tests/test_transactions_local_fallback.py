"""
Regression tests for local transaction fallback.

These tests keep the mobile integration sprint runnable without live Supabase
credentials. Production still uses Supabase when it is reachable.
"""

from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_transactions_fallback_lists_mock_data():
    response = client.get("/api/transactions", params={"user_id": "user_marcus"})

    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 20
    assert data[0]["id"].startswith("mock-user_marcus-")
    assert "subcategory" in data[0]


def test_transactions_fallback_persists_patch_in_memory():
    list_response = client.get("/api/transactions", params={"user_id": "user_marcus"})
    transaction_id = list_response.json()[0]["id"]

    patch_response = client.patch(
        f"/api/transactions/{transaction_id}",
        json={"subcategory": "sub_general_misc"},
    )
    get_response = client.get(f"/api/transactions/{transaction_id}")

    assert patch_response.status_code == 200
    assert patch_response.json()["user_corrected"] is True
    assert get_response.status_code == 200
    assert get_response.json()["subcategory"] == "sub_general_misc"
    assert get_response.json()["user_corrected"] is True


def test_transactions_fallback_rejects_invalid_category():
    list_response = client.get("/api/transactions", params={"user_id": "user_marcus"})
    transaction_id = list_response.json()[0]["id"]

    response = client.patch(
        f"/api/transactions/{transaction_id}",
        json={"subcategory": "not_a_real_subcategory"},
    )

    assert response.status_code == 422
