"""
tests/test_kevin_chat.py
=========================
Tests for Kevin chat core (mock mode — no LLM API key required).

Tests verify:
  1. Affordability question -> response references balance and risk
  2. Balance inquiry -> response includes correct balance
  3. Bills inquiry -> response references upcoming bills
  4. General chat -> response doesn't leak financial data details
  5. Unknown user_id -> raises ValueError
  6. Conversation history threads correctly (multi-turn)
  7. Tool executor returns correct data from Sprint 0 services
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pytest

from services.conversational_ai.kevin import kevin_chat
from services.conversational_ai.tools import execute_tool


# ---- Test 1: Affordability question ----
def test_affordability_question():
    result = kevin_chat("user_marcus", "Can I afford to spend $200 on new shoes?")
    assert "response" in result
    assert "check_affordability" in result["tools_called"]
    assert result["context_used"]["balance"] == 1600.0
    assert result["context_used"]["amount_requested"] == 200.0
    assert "risk_level" in result["context_used"]


# ---- Test 2: Balance inquiry ----
def test_balance_inquiry():
    result = kevin_chat("user_marcus", "What's my balance?")
    assert "1,600" in result["response"] or "1600" in result["response"]
    assert "check_balance" in result["tools_called"]


# ---- Test 3: Bills inquiry ----
def test_bills_inquiry():
    result = kevin_chat("user_marcus", "What bills do I have coming up?")
    assert "get_upcoming_bills" in result["tools_called"]
    assert "Rent" in result["response"]


# ---- Test 4: General chat fallback ----
def test_general_chat():
    result = kevin_chat("user_marcus", "Tell me a joke")
    assert "response" in result
    # General chat should not call any banking tools
    assert result["tools_called"] == []


# ---- Test 5: Unknown user raises ValueError ----
def test_unknown_user():
    with pytest.raises(ValueError, match="Unknown user"):
        kevin_chat("user_nonexistent", "What's my balance?")


# ---- Test 6: Multi-turn conversation ----
def test_conversation_history_threads():
    result1 = kevin_chat("user_marcus", "What's my balance?")
    conv = result1["conversation_history"]

    assert conv["user_id"] == "user_marcus"
    assert len(conv["messages"]) == 2  # user + assistant
    assert conv["messages"][0]["role"] == "user"
    assert conv["messages"][1]["role"] == "assistant"

    result2 = kevin_chat(
        "user_marcus",
        "And my bills?",
        conversation_history=conv["messages"],
        history_user_id=conv["user_id"],
    )
    assert len(result2["conversation_history"]["messages"]) == 4  # 2 old + 2 new
    assert result2["conversation_history"]["user_id"] == "user_marcus"


# ---- Test 7: Tool executor ----
def test_tool_executor_check_balance():
    result = execute_tool("check_balance", "user_marcus", {})
    assert result["balance"] == 1600.0


def test_tool_executor_check_affordability():
    result = execute_tool("check_affordability", "user_marcus", {"amount": 200.0})
    assert result["balance"] == 1600.0
    assert result["amount_requested"] == 200.0
    assert "risk_level" in result


def test_tool_executor_get_upcoming_bills():
    result = execute_tool("get_upcoming_bills", "user_marcus", {})
    assert len(result["upcoming_bills"]) > 0
    assert any(b["name"] == "Rent" for b in result["upcoming_bills"])


def test_tool_executor_unknown_tool():
    result = execute_tool("nonexistent_tool", "user_marcus", {})
    assert "error" in result
