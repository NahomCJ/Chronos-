"""
services/financial_advisor/crypto_analysis.py
================================================
Crypto trading transaction history analysis: cost basis, realized/unrealized
P&L, fee drag, concentration risk, and trading-frequency flags.

ADR: cost basis uses average-cost accounting (not FIFO/LIFO lot matching) —
a reasonable approximation for advice purposes given trade-level lot data
usually isn't available from a pasted transaction history. Every P&L figure
is labeled as an estimate for that reason.

Guardrail: this module is descriptive only. It never recommends buying,
selling, or holding a specific asset — it flags concentration, fee drag, and
trading frequency as facts about the user's own data, matching the same
"never recommend specific coins/trades" rule already hard-coded into Chris's
system prompt (services/conversational_ai/chris.py, _CRYPTO_CONTEXT).
"""

from __future__ import annotations

from collections import defaultdict
from datetime import date, datetime
from typing import Any

CONCENTRATION_FLAG_THRESHOLD_PCT = 70.0
FEE_DRAG_FLAG_THRESHOLD_PCT = 1.0
FREQUENT_TRADING_THRESHOLD_COUNT = 10  # trades in the lookback window


def _parse_date(value: str | None) -> date | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(value).date()
    except ValueError:
        return None


def analyze_crypto(
    transactions: list[dict[str, Any]],
    current_prices: dict[str, float] | None = None,
) -> dict[str, Any]:
    """
    Args:
        transactions: [{"asset": "BTC", "side": "buy"|"sell", "quantity": float,
                         "price_per_unit": float, "fee": float (optional, default 0),
                         "date": str (optional, ISO date)}]
        current_prices: {"BTC": 65000.0, ...} — optional, enables unrealized P&L
            and current market value. Without it, only realized P&L is computed.
    """
    if not transactions:
        return {
            "has_crypto_activity": False,
            "holdings": [],
            "flags": [],
            "total_fees_paid": 0.0,
            "total_realized_pnl": 0.0,
            "portfolio_market_value": None,
        }

    current_prices = current_prices or {}
    by_asset: dict[str, dict[str, float]] = defaultdict(
        lambda: {"buy_qty": 0.0, "buy_cost": 0.0, "sell_qty": 0.0, "sell_proceeds": 0.0, "fees": 0.0}
    )
    total_fees = 0.0
    total_volume = 0.0
    trade_dates: list[date] = []

    for t in transactions:
        asset = str(t.get("asset", "")).upper().strip()
        side = str(t.get("side", "")).lower().strip()
        qty = float(t.get("quantity") or 0.0)
        price = float(t.get("price_per_unit") or 0.0)
        fee = float(t.get("fee") or 0.0)
        notional = qty * price

        total_fees += fee
        total_volume += notional
        d = _parse_date(t.get("date"))
        if d:
            trade_dates.append(d)

        bucket = by_asset[asset]
        bucket["fees"] += fee
        if side == "buy":
            bucket["buy_qty"] += qty
            bucket["buy_cost"] += notional + fee
        elif side == "sell":
            bucket["sell_qty"] += qty
            bucket["sell_proceeds"] += notional - fee

    holdings = []
    total_realized_pnl = 0.0
    portfolio_market_value = 0.0 if current_prices else None

    for asset, b in by_asset.items():
        avg_cost = (b["buy_cost"] / b["buy_qty"]) if b["buy_qty"] > 0 else 0.0
        remaining_qty = round(b["buy_qty"] - b["sell_qty"], 8)
        realized_pnl = round(b["sell_proceeds"] - (avg_cost * b["sell_qty"]), 2) if b["sell_qty"] > 0 else 0.0
        total_realized_pnl += realized_pnl

        current_price = current_prices.get(asset)
        market_value = None
        unrealized_pnl = None
        if current_price is not None and remaining_qty > 0:
            market_value = round(remaining_qty * current_price, 2)
            unrealized_pnl = round(remaining_qty * (current_price - avg_cost), 2)
            portfolio_market_value = (portfolio_market_value or 0.0) + market_value

        holdings.append(
            {
                "asset": asset,
                "remaining_quantity": remaining_qty,
                "avg_cost_basis": round(avg_cost, 2),
                "realized_pnl_estimate": realized_pnl,
                "unrealized_pnl_estimate": unrealized_pnl,
                "market_value_estimate": market_value,
                "fees_paid": round(b["fees"], 2),
            }
        )

    flags = []

    fee_drag_pct = round((total_fees / total_volume) * 100, 2) if total_volume > 0 else 0.0
    if fee_drag_pct >= FEE_DRAG_FLAG_THRESHOLD_PCT:
        flags.append(
            {
                "type": "HIGH_TRADING_FEE_DRAG",
                "message": (
                    f"Trading fees total ${total_fees:,.2f} — {fee_drag_pct:.2f}% of total trade "
                    "volume. Frequent small trades compound this; consolidating into fewer, "
                    "larger trades reduces fee drag."
                ),
            }
        )

    if portfolio_market_value and portfolio_market_value > 0:
        top_holding = max(
            (h for h in holdings if h["market_value_estimate"]),
            key=lambda h: h["market_value_estimate"],
            default=None,
        )
        if top_holding:
            concentration_pct = round((top_holding["market_value_estimate"] / portfolio_market_value) * 100, 1)
            if concentration_pct >= CONCENTRATION_FLAG_THRESHOLD_PCT:
                flags.append(
                    {
                        "type": "CONCENTRATION_RISK",
                        "message": (
                            f"{concentration_pct:.1f}% of the crypto portfolio's current value is in "
                            f"{top_holding['asset']}. This is a concentration fact about the current "
                            "holdings, not a recommendation to buy or sell — worth considering whether "
                            "that matches the intended risk tolerance."
                        ),
                    }
                )

    if trade_dates:
        window_start = max(trade_dates) if trade_dates else None
        recent_count = sum(
            1 for d in trade_dates if window_start and (window_start - d).days <= 30
        )
        if recent_count >= FREQUENT_TRADING_THRESHOLD_COUNT:
            flags.append(
                {
                    "type": "FREQUENT_TRADING_PATTERN",
                    "message": (
                        f"{recent_count} trades detected in a 30-day window. Frequent short-term "
                        "trading increases fee drag and may trigger short-term capital gains taxed "
                        "at ordinary income rates rather than long-term rates — worth checking with "
                        "a tax professional on holding-period implications."
                    ),
                }
            )

    return {
        "has_crypto_activity": True,
        "holdings": sorted(holdings, key=lambda h: h["market_value_estimate"] or 0, reverse=True),
        "flags": flags,
        "total_fees_paid": round(total_fees, 2),
        "total_realized_pnl": round(total_realized_pnl, 2),
        "portfolio_market_value": round(portfolio_market_value, 2) if portfolio_market_value else None,
        "disclaimer": (
            "P&L figures use average-cost accounting as an estimate, not matched tax lots. "
            "This is an analysis of your own data, not investment advice."
        ),
    }
