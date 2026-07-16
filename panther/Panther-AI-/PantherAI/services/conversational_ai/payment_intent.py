"""
services/conversational_ai/payment_intent.py
=============================================
Parses natural language payment commands into structured PaymentIntent objects.

Handles:
  "Send $100 to John"
  "Transfer 50 dollars to sarah"
  "Pay Bob $200"
  "Wire $500 to alice"
"""

from __future__ import annotations

import re
from typing import Optional

# Action keywords that indicate a payment command
_ACTION_WORDS = {"send", "transfer", "pay", "wire", "move", "give"}

# Matches: $100, $1,500.00, 100, 1500.50
_AMOUNT_RE = re.compile(r"\$?([\d,]+(?:\.\d{1,2})?)")

# Matches: "to John", "to sarah jones", "for alice"
_RECIPIENT_RE = re.compile(r"(?:to|for)\s+([A-Za-z][A-Za-z0-9_\s]{1,30}?)(?:\s|$|\.|\,)")


def parse_payment_intent(text: str) -> Optional[dict]:
    """
    Parses text for a payment command.

    Returns a PaymentIntent dict or None if not a payment command.

    >>> parse_payment_intent("send $100 to John")
    {'type': 'transfer', 'amount': 100.0, 'recipient': 'john', 'currency': 'USD', 'confirmed': False}

    >>> parse_payment_intent("what's my balance?")
    """
    lower = text.lower()

    # Must contain an action word to be a payment command
    if not any(word in lower for word in _ACTION_WORDS):
        return None

    # Extract amount
    amount_match = _AMOUNT_RE.search(text)
    if not amount_match:
        return None

    try:
        amount = float(amount_match.group(1).replace(",", ""))
    except ValueError:
        return None

    if amount <= 0 or amount > 1_000_000:
        return None

    # Extract recipient (requires "to" or "for" preposition)
    recipient_match = _RECIPIENT_RE.search(lower)
    if not recipient_match:
        return None

    recipient = recipient_match.group(1).strip()
    if not recipient:
        return None

    # Classify action type
    action_type = "transfer"
    if "exchange" in lower or "convert" in lower or "swap" in lower:
        action_type = "exchange"
    elif "pay" in lower:
        action_type = "payment"

    return {
        "type": action_type,
        "amount": amount,
        "recipient": recipient,
        "currency": "USD",
        "confirmed": False,
    }
