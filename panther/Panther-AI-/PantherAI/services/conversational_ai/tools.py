"""
services/conversational_ai/tools.py
=====================================
All tools Kevin can call, organized by domain.

TOOL_DEFINITIONS: Full list of OpenAI-compatible schemas.
TOOLS_BY_DOMAIN: Filtered subsets for each routing domain.
execute_tool(): Dispatcher that routes tool calls to the right service.
"""

from __future__ import annotations

from collections import defaultdict
from datetime import date, timedelta
from typing import Any

from services.banking.mock_api import get_balance, get_transactions, get_upcoming_bills
from services.risk_assessment.risk_assesment import assess_payment_risk


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
                "Get a summary of the user's spending for the current month. "
                "Returns total spent, transaction count, and recent transactions. "
                "Call this when the user asks about their spending, expenses, or "
                "how much they've spent this month."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "days_back": {
                        "type": "integer",
                        "description": "Number of days to look back. Defaults to 30.",
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
TOOL_DEFINITIONS: list[dict[str, Any]] = _BANKING_TOOLS + _CRYPTO_TOOLS

# Domain-filtered subsets (B5 routing integration)
TOOLS_BY_DOMAIN: dict[str, list[dict[str, Any]]] = {
    "banking": _BANKING_TOOLS,
    "crypto": _CRYPTO_TOOLS,
    "investment": _BANKING_TOOLS + _CRYPTO_TOOLS,  # Advisor needs both to assess full picture
    "marketplace": _BANKING_TOOLS,  # TickPay affordability checks
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
        days = arguments.get("days_back", 30)
        txns = get_transactions(user_id, days_back=days)
        spending = [t for t in txns if t["amount"] < 0]
        total = sum(abs(t["amount"]) for t in spending)
        income = sum(t["amount"] for t in txns if t["amount"] > 0)
        return {
            "total_spent": round(total, 2),
            "total_income": round(income, 2),
            "transaction_count": len(spending),
            "period_days": days,
            "period_label": f"Last {days} days",
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
