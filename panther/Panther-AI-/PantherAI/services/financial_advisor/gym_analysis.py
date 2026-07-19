"""
services/financial_advisor/gym_analysis.py
============================================
Gym/fitness membership analysis: flags cost relative to typical pricing for
the member's location, and flags redundant/duplicate memberships.

Pricing bands are rough US market heuristics (standard chain gym vs. boutique
studio), not a live pricing feed — labeled as an estimate in the output.
"""

from __future__ import annotations

import re
from typing import Any

from services.financial_advisor.categorizer import SUB_FITNESS_GYM

_BOUTIQUE_KEYWORDS = re.compile(
    r"\b(equinox|orangetheory|orange theory|corepower|pure barre|crossfit|f45|"
    r"soulcycle|barry'?s|peloton)\b",
    re.I,
)

# monthly price bands: (standard_low, standard_high, boutique_low, boutique_high)
_HIGH_COST_BAND = (30.0, 90.0, 120.0, 250.0)
_MID_COST_BAND = (20.0, 70.0, 90.0, 180.0)
_LOW_COST_BAND = (10.0, 50.0, 70.0, 150.0)

_HIGH_COST_MARKERS = (
    "new york", "nyc", "manhattan", "brooklyn", "san francisco", "sf", "bay area",
    "los angeles", "la", "santa monica", "boston", "seattle", "washington dc",
    "washington, dc", "san diego", "honolulu", "miami beach",
)
_LOW_COST_MARKERS = (
    "rural", "small town",
)


def _cost_tier(location: str | None) -> tuple[str, tuple[float, float, float, float]]:
    loc = (location or "").lower()
    if any(marker in loc for marker in _HIGH_COST_MARKERS):
        return "high_cost_area", _HIGH_COST_BAND
    if any(marker in loc for marker in _LOW_COST_MARKERS):
        return "low_cost_area", _LOW_COST_BAND
    return "average_cost_area", _MID_COST_BAND


def analyze_gym_spending(
    transactions: list[dict[str, Any]], default_location: str | None
) -> dict[str, Any]:
    """Analyzes categorized transactions for gym/fitness spend.

    Expects `transactions` already enriched by categorizer.categorize_expenses
    (each item has subcategory_id, monthly_amount, merchant, location).
    """
    gym_txns = [t for t in transactions if t["subcategory_id"] == SUB_FITNESS_GYM]
    if not gym_txns:
        return {
            "has_gym_membership": False,
            "memberships": [],
            "flags": [],
            "total_monthly_cost": 0.0,
        }

    memberships = []
    flags = []
    for txn in gym_txns:
        location = txn.get("location") or default_location
        tier, (std_lo, std_hi, bou_lo, bou_hi) = _cost_tier(location)
        is_boutique = bool(_BOUTIQUE_KEYWORDS.search(txn["merchant"]))
        lo, hi = (bou_lo, bou_hi) if is_boutique else (std_lo, std_hi)
        amount = txn["monthly_amount"]

        if amount > hi:
            pricing_flag = "above_typical_for_area"
            note = (
                f"${amount:,.2f}/mo at {txn['merchant']} is above the typical "
                f"${lo:,.0f}-${hi:,.0f}/mo range for a "
                f"{'boutique studio' if is_boutique else 'standard gym'} in "
                f"a {tier.replace('_', ' ')}."
            )
        elif amount < lo:
            pricing_flag = "below_typical_for_area"
            note = (
                f"${amount:,.2f}/mo at {txn['merchant']} is below the typical "
                f"range for the area — good value, no action needed."
            )
        else:
            pricing_flag = "typical_for_area"
            note = f"${amount:,.2f}/mo at {txn['merchant']} is in the typical range for the area."

        memberships.append(
            {
                "merchant": txn["merchant"],
                "monthly_cost": amount,
                "location_used": location,
                "cost_tier": tier,
                "is_boutique": is_boutique,
                "typical_range": {"low": lo, "high": hi},
                "pricing_flag": pricing_flag,
                "note": note,
            }
        )
        if pricing_flag == "above_typical_for_area":
            flags.append(
                {
                    "type": "OVERPRICED_FOR_AREA",
                    "message": note + " Consider negotiating your rate, switching to an off-peak/basic tier, or a cheaper standard gym nearby.",
                }
            )

    if len({m["merchant"] for m in memberships}) > 1:
        merchant_list = ", ".join(sorted({m["merchant"] for m in memberships}))
        flags.append(
            {
                "type": "MULTIPLE_MEMBERSHIPS",
                "message": (
                    f"Active memberships at {len(set(m['merchant'] for m in memberships))} "
                    f"different fitness merchants ({merchant_list}) — check for overlap "
                    "and consider consolidating to one."
                ),
            }
        )

    return {
        "has_gym_membership": True,
        "memberships": memberships,
        "flags": flags,
        "total_monthly_cost": round(sum(m["monthly_cost"] for m in memberships), 2),
        "pricing_estimate_disclaimer": (
            "Typical price ranges are rough US market estimates based on area cost "
            "tier and gym type, not a live pricing feed."
        ),
    }
