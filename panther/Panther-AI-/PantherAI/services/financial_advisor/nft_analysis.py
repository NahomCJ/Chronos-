"""
services/financial_advisor/nft_analysis.py
=============================================
NFT transaction history analysis: acquisition cost (purchase/mint + gas),
realized cash flow from sales, gas fee drag, collection concentration, and
an illiquidity flag for holdings with no floor-price data.

ADR: NFTs are non-fungible, so per-token lot matching would need a token ID
on every event. Without one, this aggregates by collection and reports a net
cash-flow figure rather than a matched per-item P&L — labeled as such.
Descriptive only, same guardrail as crypto_analysis.py: no buy/sell/hold
recommendations on a specific collection.
"""

from __future__ import annotations

from collections import defaultdict
from typing import Any

GAS_FEE_DRAG_THRESHOLD_PCT = 15.0
COLLECTION_CONCENTRATION_THRESHOLD_PCT = 70.0

_ACQUIRE_EVENTS = {"mint", "purchase"}
_DISPOSE_EVENTS = {"sale"}


def analyze_nft(transactions: list[dict[str, Any]]) -> dict[str, Any]:
    """
    Args:
        transactions: [{"collection": str, "event": "mint"|"purchase"|"sale"|
                         "transfer_in"|"transfer_out", "price": float (0 for transfers),
                         "gas_fee": float (optional, default 0), "date": str (optional),
                         "current_floor_price": float (optional, per-unit, for held items)}]
    """
    if not transactions:
        return {
            "has_nft_activity": False,
            "collections": [],
            "flags": [],
            "total_spent": 0.0,
            "total_gas_fees": 0.0,
            "net_cash_flow": 0.0,
        }

    by_collection: dict[str, dict[str, Any]] = defaultdict(
        lambda: {
            "acquired_count": 0,
            "acquired_cost": 0.0,
            "disposed_count": 0,
            "disposed_proceeds": 0.0,
            "gas_fees": 0.0,
            "floor_prices_seen": [],
        }
    )

    total_gas_fees = 0.0
    total_acquired_cost = 0.0
    total_disposed_proceeds = 0.0

    for t in transactions:
        collection = str(t.get("collection", "Unknown collection")).strip()
        event = str(t.get("event", "")).lower().strip()
        price = float(t.get("price") or 0.0)
        gas_fee = float(t.get("gas_fee") or 0.0)

        bucket = by_collection[collection]
        bucket["gas_fees"] += gas_fee
        total_gas_fees += gas_fee

        if event in _ACQUIRE_EVENTS:
            bucket["acquired_count"] += 1
            bucket["acquired_cost"] += price + gas_fee
            total_acquired_cost += price + gas_fee
        elif event in _DISPOSE_EVENTS:
            bucket["disposed_count"] += 1
            bucket["disposed_proceeds"] += price - gas_fee
            total_disposed_proceeds += price - gas_fee

        if t.get("current_floor_price") is not None:
            bucket["floor_prices_seen"].append(float(t["current_floor_price"]))

    collections = []
    for name, b in by_collection.items():
        held_count = max(0, b["acquired_count"] - b["disposed_count"])
        floor_price = b["floor_prices_seen"][-1] if b["floor_prices_seen"] else None
        estimated_held_value = round(held_count * floor_price, 2) if floor_price is not None else None

        collections.append(
            {
                "collection": name,
                "acquired_count": b["acquired_count"],
                "disposed_count": b["disposed_count"],
                "held_count": held_count,
                "acquisition_cost": round(b["acquired_cost"], 2),
                "disposed_proceeds": round(b["disposed_proceeds"], 2),
                "gas_fees_paid": round(b["gas_fees"], 2),
                "net_cash_flow": round(b["disposed_proceeds"] - b["acquired_cost"], 2),
                "estimated_held_value": estimated_held_value,
                "has_floor_price_data": floor_price is not None,
            }
        )

    collections.sort(key=lambda c: c["acquisition_cost"], reverse=True)

    flags = []
    gas_drag_pct = round((total_gas_fees / total_acquired_cost) * 100, 2) if total_acquired_cost > 0 else 0.0
    if gas_drag_pct >= GAS_FEE_DRAG_THRESHOLD_PCT:
        flags.append(
            {
                "type": "HIGH_GAS_FEE_DRAG",
                "message": (
                    f"Gas fees are ${total_gas_fees:,.2f} — {gas_drag_pct:.1f}% of total acquisition "
                    "cost across NFT purchases/mints. That's a meaningful overhead worth factoring "
                    "into whether these positions can realistically be profitable on resale."
                ),
            }
        )

    illiquid = [c for c in collections if c["held_count"] > 0 and not c["has_floor_price_data"]]
    if illiquid:
        names = ", ".join(c["collection"] for c in illiquid)
        flags.append(
            {
                "type": "UNKNOWN_LIQUIDITY_VALUE",
                "message": (
                    f"Holdings in {names} have no current floor-price data, so their present value "
                    "is unknown — worth checking a marketplace for current floor price before "
                    "counting these toward net worth."
                ),
            }
        )

    if total_acquired_cost > 0:
        top = max(collections, key=lambda c: c["acquisition_cost"])
        concentration_pct = round((top["acquisition_cost"] / total_acquired_cost) * 100, 1)
        if concentration_pct >= COLLECTION_CONCENTRATION_THRESHOLD_PCT:
            flags.append(
                {
                    "type": "COLLECTION_CONCENTRATION",
                    "message": (
                        f"{concentration_pct:.1f}% of total NFT spend is in {top['collection']}. "
                        "This is a concentration fact about spend, not a recommendation."
                    ),
                }
            )

    return {
        "has_nft_activity": True,
        "collections": collections,
        "flags": flags,
        "total_spent": round(total_acquired_cost, 2),
        "total_gas_fees": round(total_gas_fees, 2),
        "net_cash_flow": round(total_disposed_proceeds - total_acquired_cost, 2),
        "disclaimer": (
            "Aggregated by collection, not matched per-token (NFTs are non-fungible and no "
            "token ID was supplied). This is an analysis of your own data, not investment advice."
        ),
    }
