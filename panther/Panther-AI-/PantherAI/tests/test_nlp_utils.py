"""
tests/test_nlp_utils.py
========================
Tests for extract_amount() utility.
Intent detection is now handled by Qwen via tool calling — see test_kevin_chat.py.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from services.conversational_ai.nlp_utils import extract_amount


def test_extract_amount_dollar_sign():
    assert extract_amount("Can I spend $200 on shoes?") == 200.0


def test_extract_amount_with_commas():
    assert extract_amount("Can I spend $1,234.56?") == 1234.56


def test_extract_amount_dollars_word():
    assert extract_amount("It costs 99 dollars") == 99.0


def test_extract_amount_bucks():
    assert extract_amount("about 50 bucks") == 50.0


def test_extract_amount_none():
    assert extract_amount("No amount here") is None


def test_extract_amount_with_decimals():
    assert extract_amount("$49.99 for a shirt") == 49.99
