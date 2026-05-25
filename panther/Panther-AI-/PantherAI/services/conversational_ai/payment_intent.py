"""
services/conversational_ai/payment_intent.py
=============================================
Parses natural language transaction commands into structured TransactionIntent objects.

Supported types:
  transfer  — "Send $100 to John",  "Wire $500 to Alice"
  request   — "Request $50 from Sarah",  "Ask John for $200"
  exchange  — "Exchange $100 USD to EUR",  "Convert 50 dollars to Bitcoin"
  purchase  — "Buy the premium plan for $9.99",  "Order the gold membership"
  trade     — "Buy 0.5 BTC",  "Sell $1000 of Ethereum",  "Buy 10 shares of Apple"
  invest    — "Invest $500 in S&P 500",  "Put $200 into index fund"
"""

from __future__ import annotations

import re
from typing import Optional

# ---------------------------------------------------------------------------
# Amount
# ---------------------------------------------------------------------------

_AMOUNT_RE = re.compile(
    r"\$?([\d,]+(?:\.\d{1,2})?)\s*(?:dollars?|usd|gbp|eur|btc|eth)?",
    re.IGNORECASE,
)

# ---------------------------------------------------------------------------
# Asset / currency vocabularies
# ---------------------------------------------------------------------------

_CRYPTO_ASSETS = {
    "btc", "bitcoin", "eth", "ethereum", "sol", "solana",
    "usdc", "usdt", "xrp", "ripple", "ada", "cardano",
    "bnb", "doge", "dogecoin", "matic", "polygon", "avax", "avalanche",
}

_INVESTMENT_TERMS = {
    "s&p", "s&p 500", "sp500", "nasdaq", "dow jones", "dow",
    "index fund", "index", "etf", "mutual fund", "fund",
    "bond", "bonds", "treasury", "portfolio",
    "reit", "401k", "ira", "roth",
}

_TO_CURRENCY_RE = re.compile(
    r"(?:to|into|for)\s+(usd|eur|gbp|jpy|cad|aud|chf|btc|eth|bitcoin|ethereum|usdc|usdt)",
    re.IGNORECASE,
)

_RECIPIENT_RE = re.compile(
    r"(?:to|for)\s+([A-Za-z][A-Za-z0-9_\s]{1,30}?)(?:\s|$|[.,])",
)

_FROM_RE = re.compile(
    r"from\s+([A-Za-z][A-Za-z0-9_\s]{1,30}?)(?:\s|$|[.,])",
)

# ---------------------------------------------------------------------------
# Action keyword sets
# ---------------------------------------------------------------------------

_TRANSFER_WORDS  = {"send", "transfer", "wire", "move", "give", "pay"}
_REQUEST_WORDS   = {"request", "collect", "receive", "get paid", "charge"}
_EXCHANGE_WORDS  = {"exchange", "convert", "swap", "change"}
_PURCHASE_WORDS  = {"purchase", "order", "checkout", "buy", "get"}
_TRADE_WORDS     = {"trade", "buy", "sell", "long", "short"}
_INVEST_WORDS    = {"invest", "put into", "add to", "allocate", "contribute", "deposit into"}


# ---------------------------------------------------------------------------
# Public entry point
# ---------------------------------------------------------------------------

def parse_payment_intent(text: str) -> Optional[dict]:
    """
    Parses text for a transaction command.

    Returns a TransactionIntent dict or None if no transaction is detected.
    """
    lower = text.lower().strip()
    amount = _extract_amount(lower)
    intent_type = _classify_intent(lower)

    if not intent_type:
        return None

    builders = {
        "trade":    _build_trade_intent,
        "invest":   _build_invest_intent,
        "exchange": _build_exchange_intent,
        "request":  _build_request_intent,
        "purchase": _build_purchase_intent,
        "transfer": _build_transfer_intent,
    }

    return builders[intent_type](lower, amount)


# ---------------------------------------------------------------------------
# Classifier  (most-specific first)
# ---------------------------------------------------------------------------

def _classify_intent(lower: str) -> Optional[str]:
    has_trade_word   = any(w in lower for w in _TRADE_WORDS)
    has_crypto       = any(c in lower for c in _CRYPTO_ASSETS)
    has_stock        = bool(re.search(r"\b(shares?|stocks?|equity)\b", lower))
    has_invest_word  = any(w in lower for w in _INVEST_WORDS)
    has_invest_term  = any(t in lower for t in _INVESTMENT_TERMS)
    has_exchange     = any(w in lower for w in _EXCHANGE_WORDS)
    has_request_word = any(w in lower for w in _REQUEST_WORDS)
    has_from         = bool(_FROM_RE.search(lower))
    has_purchase     = any(w in lower for w in _PURCHASE_WORDS)
    has_transfer     = any(w in lower for w in _TRANSFER_WORDS)

    if has_trade_word and (has_crypto or has_stock):
        return "trade"
    if has_invest_word or (has_trade_word and has_invest_term):
        return "invest"
    if has_exchange:
        return "exchange"
    if has_request_word and has_from:
        return "request"
    if has_purchase and not has_crypto and not has_invest_term:
        return "purchase"
    if has_transfer:
        return "transfer"
    return None


# ---------------------------------------------------------------------------
# Intent builders
# ---------------------------------------------------------------------------

def _build_transfer_intent(lower: str, amount: Optional[float]) -> Optional[dict]:
    if not amount:
        return None
    m = _RECIPIENT_RE.search(lower)
    if not m:
        return None
    return {
        "type": "transfer",
        "amount": amount,
        "recipient": m.group(1).strip().title(),
        "currency": _detect_currency(lower),
        "confirmed": False,
    }


def _build_request_intent(lower: str, amount: Optional[float]) -> Optional[dict]:
    if not amount:
        return None
    m = _FROM_RE.search(lower)
    if not m:
        return None
    return {
        "type": "request",
        "amount": amount,
        "from_user": m.group(1).strip().title(),
        "currency": _detect_currency(lower),
        "confirmed": False,
    }


def _build_exchange_intent(lower: str, amount: Optional[float]) -> Optional[dict]:
    if not amount:
        return None
    m = _TO_CURRENCY_RE.search(lower)
    if not m:
        return None
    return {
        "type": "exchange",
        "amount": amount,
        "from_currency": _detect_currency(lower),
        "to_currency": m.group(1).upper(),
        "confirmed": False,
    }


def _build_purchase_intent(lower: str, amount: Optional[float]) -> Optional[dict]:
    item = "item"
    for word in _PURCHASE_WORDS:
        if word in lower:
            after = lower.split(word, 1)[-1].strip()
            m = re.match(r"([A-Za-z][A-Za-z0-9\s]{2,40}?)(?:\s+for\s+\$?[\d,]+|\s*$)", after)
            if m:
                item = m.group(1).strip().title()
            break
    return {
        "type": "purchase",
        "item": item,
        "amount": amount,
        "currency": _detect_currency(lower),
        "confirmed": False,
    }


def _build_trade_intent(lower: str, amount: Optional[float]) -> Optional[dict]:
    direction = "sell" if ("sell" in lower or "short" in lower) else "buy"

    asset = None
    for crypto in _CRYPTO_ASSETS:
        if crypto in lower:
            asset = crypto.upper() if len(crypto) <= 4 else crypto.title()
            break

    if not asset:
        m = re.search(r"\b([A-Z]{2,5})\b", lower.upper())
        if m:
            asset = m.group(1)

    if not asset:
        return None

    return {
        "type": "trade",
        "direction": direction,
        "asset": asset,
        "amount": amount,
        "currency": _detect_currency(lower),
        "confirmed": False,
    }


def _build_invest_intent(lower: str, amount: Optional[float]) -> Optional[dict]:
    if not amount:
        return None

    fund = "your portfolio"
    for term in sorted(_INVESTMENT_TERMS, key=len, reverse=True):
        if term in lower:
            fund = term.upper() if term in {"etf", "ira", "reit"} else term.title()
            break

    m = re.search(r"(?:into|in)\s+([A-Za-z0-9\s&]{3,40}?)(?:\s|$|[.,])", lower)
    if m:
        fund = m.group(1).strip().title()

    return {
        "type": "invest",
        "amount": amount,
        "fund": fund,
        "currency": _detect_currency(lower),
        "confirmed": False,
    }


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _extract_amount(lower: str) -> Optional[float]:
    m = _AMOUNT_RE.search(lower)
    if not m:
        return None
    try:
        return float(m.group(1).replace(",", ""))
    except ValueError:
        return None


def _detect_currency(lower: str) -> str:
    if "eur" in lower or "euro" in lower:
        return "EUR"
    if "gbp" in lower or "pound" in lower:
        return "GBP"
    if "btc" in lower or "bitcoin" in lower:
        return "BTC"
    if "eth" in lower or "ethereum" in lower:
        return "ETH"
    return "USD"
