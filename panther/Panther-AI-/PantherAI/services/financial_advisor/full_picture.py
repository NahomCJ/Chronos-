"""
services/financial_advisor/full_picture.py
=============================================
The "full capability" financial advice pipeline: pulls a user's connected
data — Plaid transactions/BNPL exposure (services.banking.mock_api) and
Veryfi receipt line items (services.receipts.mock_api) — merges them, and
runs the merged picture through the existing financial_advisor engine
(analyzer/categorizer/advice_engine) to produce a full advice report.

Both data sources already go through a Plaid/Supabase/mock (and
Veryfi/Supabase/mock) priority chain in their respective modules, so this
pipeline is real today against mock data and requires no changes once real
Plaid tokens / Veryfi credentials are wired in for a user — same routes,
same response shape.

Two outputs, on purpose:
  - `brief`: a handful of headline numbers. This is what a UI surface
    should show inline — NOT another bulky category grid.
  - `full_report` / `item_level_breakdown`: the full-capability detail,
    for a surface that explicitly wants to drill in later.

Item-level breakdown is the genuinely new capability Veryfi unlocks: a
Plaid transaction says "$129.99 at AMAZON, category Electronics". A
matched receipt says $49.99 of that was actually a supplement purchase —
detail no bank feed can produce on its own.
"""

from __future__ import annotations

from typing import Any

from services.banking.mock_api import get_active_bnpl_amount, get_transactions
from services.financial_advisor.analyzer import analyze_person
from services.financial_advisor.categorizer import (
    categorize_transaction,
    category_name,
    subcategory_name,
)
from services.receipts.mock_api import get_receipts

# Rough BNPL amortization assumption for demo purposes only (typical
# buy-now-pay-later plans split a balance across ~4 installments). Real
# per-plan schedules should replace this once BNPL data exposes them.
_ASSUMED_BNPL_INSTALLMENTS = 4

# Subcategories too generic to call out as a standout "hidden spend" flag.
_UNREMARKABLE_SUBCATEGORIES = {"sub_groceries", "sub_general_misc"}


def _normalize_merchant(name: str) -> str:
    return "".join(ch for ch in (name or "").upper() if ch.isalnum())


def merge_transactions_with_receipts(
    transactions: list[dict[str, Any]], receipts: list[dict[str, Any]]
) -> tuple[list[dict[str, Any]], int]:
    """
    Attaches matching receipt line items onto their Plaid transaction.

    Matches on normalized merchant name + exact amount (rather than date,
    since a bank's posted date and a receipt's purchase date routinely
    differ by a day or two) so the same total from both sources is treated
    as the same purchase. Each receipt is consumed at most once so repeat
    purchases at the same merchant/amount don't all claim the same receipt.

    Returns (enriched_transactions, itemized_count).
    """
    receipt_index: dict[tuple[str, float], list[dict[str, Any]]] = {}
    for r in receipts:
        key = (_normalize_merchant(r["merchant"]), round(float(r["total"]), 2))
        receipt_index.setdefault(key, []).append(r)

    enriched: list[dict[str, Any]] = []
    itemized_count = 0
    for t in transactions:
        merged = dict(t)
        key = (_normalize_merchant(t.get("merchant", "")), round(abs(float(t.get("amount") or 0.0)), 2))
        bucket = receipt_index.get(key)
        if bucket:
            receipt = bucket.pop(0)
            merged["itemized"] = True
            merged["receipt_id"] = receipt["id"]
            merged["line_items"] = receipt["line_items"]
            itemized_count += 1
        else:
            merged["itemized"] = False
        enriched.append(merged)
    return enriched, itemized_count


def _build_item_level_breakdown(enriched_transactions: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Aggregates matched receipt line items by taxonomy subcategory."""
    totals: dict[str, float] = {}
    for t in enriched_transactions:
        if not t.get("itemized"):
            continue
        for li in t["line_items"]:
            sub_id = categorize_transaction(li["description"])
            totals[sub_id] = round(totals.get(sub_id, 0.0) + float(li["total"]), 2)

    return sorted(
        (
            {
                "subcategory_id": sub_id,
                "subcategory_name": subcategory_name(sub_id),
                "category_name": category_name(sub_id),
                "amount": amount,
            }
            for sub_id, amount in totals.items()
            if amount > 0
        ),
        key=lambda row: row["amount"],
        reverse=True,
    )


def _build_brief(
    full_report: dict[str, Any],
    itemized_count: int,
    item_level_breakdown: list[dict[str, Any]],
) -> dict[str, Any]:
    """Headline-only summary. Deliberately small — full detail lives in
    full_report / item_level_breakdown for whatever surface wants to drill in."""
    summary = full_report["summary"]
    top_advice = full_report["advice"][0] if full_report["advice"] else None

    # Skip past generic buckets (groceries, misc) to find the most notable
    # itemized category — e.g. supplements hidden inside an Amazon order —
    # since that's the actual new signal Veryfi contributes over Plaid alone.
    notable_item = next(
        (row for row in item_level_breakdown if row["subcategory_id"] not in _UNREMARKABLE_SUBCATEGORIES),
        None,
    )
    hidden_spend_note = (
        f"Receipts show ${notable_item['amount']:,.2f} of {notable_item['subcategory_name'].lower()} "
        "spend itemized out of larger merchant charges — detail Plaid alone wouldn't break out."
        if notable_item
        else None
    )

    return {
        "safe_to_spend_today": round(max(summary["monthly_leftover"], 0.0) / 30, 2),
        "monthly_leftover": summary["monthly_leftover"],
        "savings_rate_pct": summary["savings_rate_pct"],
        "itemized_transaction_count": itemized_count,
        "top_advice": top_advice["advice"] if top_advice else None,
        "hidden_spend_note": hidden_spend_note,
    }


def build_full_financial_picture(user_id: str, days_back: int = 30) -> dict[str, Any]:
    """
    Builds the full Plaid + Veryfi financial picture for a user.

    Args:
        user_id: User identifier (e.g. "user_marcus").
        days_back: Transaction lookback window treated as "this month's"
            snapshot for the advice engine (see analyze_person — it expects
            a monthly transaction list, not a raw multi-month ledger).

    Returns:
        {"user_id": str, "brief": {...}, "item_level_breakdown": [...],
         "full_report": {...}}

    Raises:
        ValueError: Unknown user_id.
    """
    transactions = get_transactions(user_id, days_back=days_back)
    # Wider window on the receipts side — a receipt can trail its bank
    # posting date, and matching is done on merchant+amount, not date.
    receipts = get_receipts(user_id, days_back=max(days_back * 3, 90))

    enriched_transactions, itemized_count = merge_transactions_with_receipts(transactions, receipts)

    monthly_income = round(sum(t["amount"] for t in transactions if t["amount"] > 0), 2)
    expense_inputs = [
        {
            "merchant": t["merchant"],
            "amount": abs(t["amount"]),
            "frequency": "monthly",
            "category": t.get("category"),
        }
        for t in transactions
        if t["amount"] < 0
    ]

    debts = []
    active_bnpl_amount = get_active_bnpl_amount(user_id)
    if active_bnpl_amount > 0:
        debts.append(
            {
                "name": "Active BNPL plans",
                "type": "bnpl",
                "balance": round(active_bnpl_amount, 2),
                "monthly_payment": round(active_bnpl_amount / _ASSUMED_BNPL_INSTALLMENTS, 2),
            }
        )

    full_report = analyze_person(
        {
            "monthly_income": monthly_income,
            "transactions": expense_inputs,
            "debts": debts,
        }
    )

    item_level_breakdown = _build_item_level_breakdown(enriched_transactions)
    brief = _build_brief(full_report, itemized_count, item_level_breakdown)

    return {
        "user_id": user_id,
        "brief": brief,
        "item_level_breakdown": item_level_breakdown,
        "full_report": full_report,
    }
