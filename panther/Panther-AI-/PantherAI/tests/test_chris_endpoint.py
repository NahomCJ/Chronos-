"""
tests/test_chris_endpoint.py
==============================
Tests for POST /api/chris/chat endpoint.

1. Valid request returns 200 with expected shape
2. Unknown user_id returns 404
3. Empty message returns 422
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_valid_request_returns_200():
    resp = client.post("/api/chris/chat", json={
        "user_id": "user_marcus",
        "message": "What's my balance?",
    })
    assert resp.status_code == 200
    data = resp.json()
    assert "response" in data
    assert "tools_called" in data
    assert "context_used" in data


def test_unknown_user_returns_404():
    resp = client.post("/api/chris/chat", json={
        "user_id": "user_nonexistent",
        "message": "What's my balance?",
    })
    assert resp.status_code == 404
    assert "Unknown user" in resp.json()["detail"]


def test_empty_message_returns_422():
    resp = client.post("/api/chris/chat", json={
        "user_id": "user_marcus",
        "message": "   ",
    })
    assert resp.status_code == 422
