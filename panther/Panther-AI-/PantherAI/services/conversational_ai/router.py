"""
services/conversational_ai/router.py
======================================
Query domain router (B5). Classifies a user message into one of 5 domains.

Domains:
  banking     — balance, bills, transfers, cash flow, spending, transactions
  crypto      — portfolio, holdings, prices, P&L, trades
  investment  — advice, risk tolerance, goals, allocation, financial planning
  marketplace — product search, TickPay, checkout, buying products
  unified     — spans multiple domains

Uses Claude Haiku for speed. Falls back to keyword matching if API is unavailable.

Environment:
    ANTHROPIC_API_KEY — required for Claude-based classification
"""

from __future__ import annotations

import os
from typing import Literal

from dotenv import load_dotenv

load_dotenv()

Domain = Literal["banking", "crypto", "investment", "marketplace", "unified"]

ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")

_VALID_DOMAINS = {"banking", "crypto", "investment", "marketplace", "unified"}

_PROMPT = """\
Classify the user's message into exactly one domain.

Domains:
- banking: balance, bills, transfers, cash flow, spending, transactions, payments
- crypto: portfolio, holdings, Bitcoin, Ethereum, crypto prices, trades, DeFi
- investment: investment advice, risk tolerance, goals, ETFs, stocks, allocation, retirement
- marketplace: buy products, search products, checkout, TickPay, shop, order items
- unified: spans multiple domains or completely unclear

Examples:
"What's my balance?" → banking
"How much BTC do I have?" → crypto
"Should I invest in ETFs?" → investment
"Buy me Nike Air Max shoes" → marketplace
"What's my net worth including crypto?" → unified
"Send $100 to John" → banking
"Is it a good time to buy Ethereum?" → crypto
"Can I afford to invest $500?" → unified

Message: {message}

Respond with ONLY the domain word. No explanation, no punctuation."""


def route_query(text: str) -> Domain:
    """
    Classifies a message into a domain.

    Uses Claude Haiku when available, keyword matching as fallback.

    >>> route_query("What's my balance?")
    'banking'
    >>> route_query("How much Bitcoin do I have?")
    'crypto'
    """
    if ANTHROPIC_API_KEY:
        try:
            return _claude_classify(text)
        except Exception:
            pass

    return _rule_based_route(text)


def _claude_classify(text: str) -> Domain:
    import anthropic

    client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)
    response = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=10,
        messages=[{"role": "user", "content": _PROMPT.format(message=text)}],
    )
    domain = response.content[0].text.strip().lower()
    if domain in _VALID_DOMAINS:
        return domain
    return "banking"


def _rule_based_route(text: str) -> Domain:
    """Fast keyword fallback when API is unavailable."""
    lower = text.lower()

    scores: dict[str, int] = {
        "crypto": sum(
            k in lower
            for k in {
                "bitcoin",
                "btc",
                "ethereum",
                "eth",
                "crypto",
                "portfolio",
                "holdings",
                "blockchain",
                "defi",
                "nft",
                "solana",
                "sol",
            }
        ),
        "investment": sum(
            k in lower
            for k in {
                "invest",
                "etf",
                "stock",
                "allocation",
                "risk tolerance",
                "goal",
                "retire",
                "wealth",
                "financial plan",
                "diversif",
            }
        ),
        "marketplace": sum(
            k in lower
            for k in {
                "buy",
                "shop",
                "purchase",
                "checkout",
                "tickpay",
                "product",
                "order",
                "shoe",
                "clothes",
                "amazon",
                "nike",
            }
        ),
    }

    top_score = max(scores.values())
    if top_score == 0:
        return "banking"

    top_domains = [d for d, s in scores.items() if s == top_score]
    if len(top_domains) > 1:
        return "unified"

    return top_domains[0]
