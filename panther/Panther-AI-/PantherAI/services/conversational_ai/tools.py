"""
services/conversational_ai/tools.py
=====================================
All tools Kevin can call, organized by domain.

TOOL_DEFINITIONS: Full list of OpenAI-compatible schemas.
TOOLS_BY_DOMAIN: Filtered subsets for each routing domain.
execute_tool(): Dispatcher that routes tool calls to the right service.
"""

from __future__ import annotations

import calendar
import re
from collections import defaultdict
from datetime import date, timedelta
from typing import Any

from services.banking.mock_api import get_balance, get_transactions, get_upcoming_bills
from services.risk_assessment.risk_assesment import assess_payment_risk

_MONTH_NAMES = {name.lower(): i for i, name in enumerate(calendar.month_name) if name}
_MONTH_ABBR  = {name.lower(): i for i, name in enumerate(calendar.month_abbr) if name}


def _resolve_month(month_arg: str | None) -> tuple[int, int]:
    """
    Converts a month argument to (year, month) integers.

    Accepts: None/'current', 'last', month name ('April'), 'YYYY-MM'.
    Returns today's month if unrecognised.
    """
    today = date.today()
    if not month_arg or month_arg.lower() == "current":
        return today.year, today.month
    if month_arg.lower() == "last":
        first = today.replace(day=1) - timedelta(days=1)
        return first.year, first.month
    # YYYY-MM
    m = re.fullmatch(r"(\d{4})-(\d{2})", month_arg.strip())
    if m:
        return int(m.group(1)), int(m.group(2))
    # Month name or abbreviation
    lower = month_arg.lower().strip()
    num = _MONTH_NAMES.get(lower) or _MONTH_ABBR.get(lower[:3])
    if num:
        year = today.year if num <= today.month else today.year - 1
        return year, num
    return today.year, today.month


# ---------------------------------------------------------------------------
# Tool definitions (OpenAI-compatible format)
# ---------------------------------------------------------------------------

_BANKING_TOOLS: list[dict[str, Any]] = [
    {
        "type": "function",
        "function": {
            "name": "check_balance",
            "description": (
                "Get the current account balance for a user. "
                "Call this when the user asks about their balance, "
                "how much money they have, or their account status."
            ),
            "parameters": {
                "type": "object",
                "properties": {},
                "required": [],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "check_affordability",
            "description": (
                "Check if the user can safely afford a purchase. "
                "Returns a risk assessment considering their balance, "
                "upcoming bills, and BNPL obligations. "
                "Call this when the user asks if they can afford, spend, "
                "buy, or purchase something."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "amount": {
                        "type": "number",
                        "description": "The dollar amount the user wants to spend.",
                    },
                },
                "required": ["amount"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_upcoming_bills",
            "description": (
                "Get the user's upcoming bills due within the next N days. "
                "Call this when the user asks about bills, payments due, "
                "or when something is due."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "days_ahead": {
                        "type": "integer",
                        "description": "Number of days to look ahead. Defaults to 7.",
                    },
                },
                "required": [],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_spending_summary",
            "description": (
                "Get a summary of the user's spending for a given month. "
                "Returns total spent, income, transaction count, and recent transactions. "
                "Call this when the user asks about their spending, expenses, or "
                "how much they spent in a specific month."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "month": {
                        "type": "string",
                        "description": (
                            "Month to summarize. Accepts: 'current', 'last', a month name "
                            "('April', 'March'), or 'YYYY-MM' format. Defaults to 'current'."
                        ),
                    },
                },
                "required": [],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_category_breakdown",
            "description": (
                "Get spending broken down by category. "
                "Returns a ranked list of spending categories with totals. "
                "Call this when the user asks where their money is going, "
                "or wants a breakdown of their spending."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "days_back": {
                        "type": "integer",
                        "description": "Number of days to analyze. Defaults to 30.",
                    },
                },
                "required": [],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_recurring_charges",
            "description": (
                "Get a list of recurring charges and subscriptions. "
                "Detects merchants that charge monthly (Netflix, Spotify, etc.). "
                "Call this when the user asks about subscriptions, recurring payments, "
                "or what they're paying monthly."
            ),
            "parameters": {
                "type": "object",
                "properties": {},
                "required": [],
            },
        },
    },
]

_MARKETPLACE_TOOLS: list[dict[str, Any]] = [
    {
        "type": "function",
        "function": {
            "name": "search_products",
            "description": (
                "Search for products matching a natural-language query within a budget. "
                "Returns ranked results with BNPL eligibility for the user. "
                "Call this when the user wants to find, buy, or shop for a product."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Natural-language product search, e.g. 'Nike Air Max under $200'.",
                    },
                    "budget": {
                        "type": "number",
                        "description": "Optional price ceiling in USD. Omit if user did not specify one.",
                    },
                },
                "required": ["query"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "check_bnpl_for_product",
            "description": (
                "Check whether the user can afford a specific product on BNPL installments. "
                "Returns risk score, eligibility, and maximum safe installment count. "
                "Call this when the user asks 'can I buy X on BNPL', 'what's my BNPL limit for Y', "
                "or after search_products to give a BNPL recommendation."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "product_name": {
                        "type": "string",
                        "description": "Name of the product being evaluated.",
                    },
                    "price": {
                        "type": "number",
                        "description": "Price of the product in USD.",
                    },
                    "num_payments": {
                        "type": "integer",
                        "description": "Number of installments to check. Defaults to 3.",
                    },
                },
                "required": ["product_name", "price"],
            },
        },
    },
]

_CRYPTO_TOOLS: list[dict[str, Any]] = [
    {
        "type": "function",
        "function": {
            "name": "get_portfolio",
            "description": (
                "Get the user's crypto portfolio summary. "
                "Returns total value, holdings, allocation percentages, and overall P&L. "
                "Call this when the user asks about their crypto portfolio, "
                "holdings, or total crypto value."
            ),
            "parameters": {
                "type": "object",
                "properties": {},
                "required": [],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_crypto_pnl",
            "description": (
                "Get the user's crypto profit and loss summary. "
                "Returns total P&L, realized vs unrealized gains, and 30-day performance. "
                "Call this when the user asks about gains, losses, profit, "
                "or portfolio performance."
            ),
            "parameters": {
                "type": "object",
                "properties": {},
                "required": [],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_position_summary",
            "description": (
                "Get details for each open crypto position. "
                "Returns per-asset quantity, average buy price, current price, and P&L. "
                "Call this when the user asks about a specific coin, "
                "their BTC/ETH/SOL position, or individual asset performance."
            ),
            "parameters": {
                "type": "object",
                "properties": {},
                "required": [],
            },
        },
    },
]

# All tools available to Kevin
TOOL_DEFINITIONS: list[dict[str, Any]] = _BANKING_TOOLS + _CRYPTO_TOOLS + _MARKETPLACE_TOOLS

# Domain-filtered subsets (B5 routing integration)
TOOLS_BY_DOMAIN: dict[str, list[dict[str, Any]]] = {
    "banking": _BANKING_TOOLS,
    "crypto": _CRYPTO_TOOLS,
    "investment": _BANKING_TOOLS + _CRYPTO_TOOLS,  # Advisor needs both to assess full picture
    "marketplace": _BANKING_TOOLS + _MARKETPLACE_TOOLS,  # TickPay: affordability + product search
    "unified": TOOL_DEFINITIONS,
}


# ---------------------------------------------------------------------------
# Tool executor
# ---------------------------------------------------------------------------


def execute_tool(tool_name: str, user_id: str, arguments: dict[str, Any]) -> dict[str, Any]:
    """
    Dispatches a tool call to the corresponding service.

    Args:
        tool_name: Function name from the LLM's tool call.
        user_id: The authenticated user making the request.
        arguments: Arguments extracted by the LLM.

    Returns:
        Dict with tool result, ready to be sent back to the LLM.

    Raises:
        ValueError: If user_id is unknown (propagated from banking services).
    """
    # --- Banking tools ---
    if tool_name == "check_balance":
        balance = get_balance(user_id)
        return {"balance": balance}

    elif tool_name == "check_affordability":
        amount = arguments["amount"]
        risk = assess_payment_risk(user_id, amount)
        balance = get_balance(user_id)
        bills = get_upcoming_bills(user_id)
        return {
            "balance": balance,
            "amount_requested": amount,
            "risk_level": risk["risk_level"].value,
            "is_risky": risk["is_risky"],
            "projected_balance": risk["projected_balance"],
            "warning_message": risk["warning_message"],
            "upcoming_bills": bills,
        }

    elif tool_name == "get_upcoming_bills":
        days = arguments.get("days_ahead", 7)
        bills = get_upcoming_bills(user_id, days_ahead=days)
        balance = get_balance(user_id)
        total_bills = sum(b["amount"] for b in bills)
        shortfall = max(0, total_bills - balance)
        return {
            "upcoming_bills": bills,
            "balance": balance,
            "total_bills": round(total_bills, 2),
            "shortfall": round(shortfall, 2),
        }

    elif tool_name == "get_spending_summary":
        year, month = _resolve_month(arguments.get("month"))
        _, last_day = calendar.monthrange(year, month)
        month_start = date(year, month, 1)
        month_end = date(year, month, last_day)
        days_back = (date.today() - month_start).days + 1

        txns = get_transactions(user_id, days_back=days_back)
        # Filter to the exact calendar month
        txns = [
            t for t in txns
            if month_start <= date.fromisoformat(t["date"]) <= month_end
        ]
        spending = [t for t in txns if t["amount"] < 0]
        total = sum(abs(t["amount"]) for t in spending)
        income = sum(t["amount"] for t in txns if t["amount"] > 0)
        month_label = f"{calendar.month_name[month]} {year}"
        return {
            "total_spent": round(total, 2),
            "total_income": round(income, 2),
            "transaction_count": len(spending),
            "period_label": month_label,
            "month": month,
            "year": year,
            "recent_transactions": spending[:10],
        }

    elif tool_name == "get_category_breakdown":
        days = arguments.get("days_back", 30)
        txns = get_transactions(user_id, days_back=days)
        by_category: dict[str, float] = defaultdict(float)
        for t in txns:
            if t["amount"] < 0:
                cat = t.get("category", "Other")
                by_category[cat] += abs(t["amount"])
        sorted_cats = sorted(by_category.items(), key=lambda x: x[1], reverse=True)
        total = sum(v for v in by_category.values())
        return {
            "categories": [
                {
                    "name": k,
                    "total": round(v, 2),
                    "pct": round(v / total * 100, 1) if total else 0,
                }
                for k, v in sorted_cats
            ],
            "total_spending": round(total, 2),
            "period_days": days,
        }

    elif tool_name == "get_recurring_charges":
        # Detect merchants appearing in 2+ of the last 3 months
        txns_90 = get_transactions(user_id, days_back=90)
        spending = [t for t in txns_90 if t["amount"] < 0]

        today = date.today()
        # Bucket into month offsets: 0=current, 1=last, 2=two ago
        def month_offset(txn_date: str) -> int:
            d = date.fromisoformat(txn_date)
            diff = (today.year - d.year) * 12 + (today.month - d.month)
            return diff

        # Aggregate merchant → set of months + avg amount
        merchant_months: dict[str, set] = defaultdict(set)
        merchant_amounts: dict[str, list] = defaultdict(list)
        for t in spending:
            offset = month_offset(t["date"])
            if offset <= 2:
                merchant_months[t["merchant"]].add(offset)
                merchant_amounts[t["merchant"]].append(abs(t["amount"]))

        # Recurring = appeared in 2+ months with similar amounts
        recurring = []
        for merchant, months in merchant_months.items():
            if len(months) >= 2:
                amounts = merchant_amounts[merchant]
                avg_amount = sum(amounts) / len(amounts)
                # Amounts must be consistent (within 20% variance)
                if max(amounts) - min(amounts) <= avg_amount * 0.2:
                    recurring.append(
                        {
                            "merchant": merchant,
                            "amount": round(avg_amount, 2),
                            "frequency": "monthly",
                            "months_detected": len(months),
                        }
                    )

        recurring.sort(key=lambda x: x["amount"], reverse=True)
        total_monthly = sum(r["amount"] for r in recurring)
        return {
            "recurring_charges": recurring,
            "total_monthly": round(total_monthly, 2),
            "count": len(recurring),
        }

    # --- Marketplace tools (D7) ---
    elif tool_name == "search_products":
        from services.marketplace.product_search_agent import parse_and_search
        from services.marketplace.bnpl_filter import apply_bnpl_filter

        query = arguments["query"]
        budget = arguments.get("budget")
        # Embed budget in the query string if passed separately
        if budget and f"${budget}" not in query and str(budget) not in query:
            query = f"{query} under ${budget}"

        results = parse_and_search(query, max_results=10)
        tagged = apply_bnpl_filter(results, user_id)
        return {
            "query": query,
            "results": tagged,
            "count": len(tagged),
        }

    elif tool_name == "check_bnpl_for_product":
        from services.bnpl_risk_scoring.bnpl_risk_scoring import calculate_bnpl_risk_score
        from services.marketplace.bnpl_filter import _find_max_safe_installments

        product_name = arguments["product_name"]
        price = arguments["price"]
        num_payments = arguments.get("num_payments", 3)

        score_result = calculate_bnpl_risk_score(user_id, price, num_payments)
        max_safe = _find_max_safe_installments(user_id, price)

        return {
            "product_name": product_name,
            "price": price,
            "num_payments_checked": num_payments,
            "risk_score": score_result["score"],
            "risk_level": score_result["risk_level"].value if hasattr(score_result["risk_level"], "value") else score_result["risk_level"],
            "bnpl_eligible": score_result["risk_level"] != "HIGH" and str(score_result["risk_level"]) != "HIGH",
            "max_safe_installments": max_safe,
            "risk_factors": score_result["risk_factors"],
            "recommendation": score_result["recommendation"],
        }

    # --- Crypto / BlockHub tools ---
    elif tool_name == "get_portfolio":
        from services.blockhub.connector import get_portfolio

        return get_portfolio(user_id)

    elif tool_name == "get_crypto_pnl":
        from services.blockhub.connector import get_crypto_pnl

        return get_crypto_pnl(user_id)

    elif tool_name == "get_position_summary":
        from services.blockhub.connector import get_position_summary

        positions = get_position_summary(user_id)
        return {"positions": positions}

    else:
        return {"error": f"Unknown tool: {tool_name}"}
