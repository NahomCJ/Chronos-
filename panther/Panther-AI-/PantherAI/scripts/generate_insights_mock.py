"""
generate_insights_mock.py
=========================
Generates realistic mock transactions for the 3 demo users (Marcus, Sarah, Bob)
by sampling merchant descriptions from the ground truth parquet and attaching
synthetic amounts and dates.

Output: datasets/mock/mock_transactions.json

USAGE
-----
    python scripts/generate_insights_mock.py

The insights API reads this file in dev mode. No Supabase connection needed.

WHY THIS APPROACH
-----------------
The parquet has 1M+ real merchant descriptions but no amounts or dates.
We sample from it to get realistic merchant names per category, then
assign amounts from per-category distributions that reflect real-world spending.
Each user has a spending personality tuned to the demo narrative:
  - Marcus: HIGH RISK — food/drink overspender, rent due in 3 days
  - Sarah:  LOW RISK  — disciplined, travel + wellness focused
  - Bob:    MEDIUM RISK — transport-heavy, one BNPL late payment
"""

import json
import random
from datetime import date, timedelta
from pathlib import Path

import pandas as pd

# ---------------------------------------------------------------------------
# CONFIG
# ---------------------------------------------------------------------------
PARQUET_PATH = Path("datasets/processed/panther_ground_truth_v3.parquet")
OUTPUT_PATH = Path("datasets/mock/mock_transactions.json")
SEED = 42
TODAY = date(2026, 3, 17)  # frozen for reproducibility

random.seed(SEED)


# ---------------------------------------------------------------------------
# AMOUNT RANGES PER CATEGORY
# Tuple: (min, max) in USD. Drawn from a uniform distribution then rounded.
# These reflect median real-world spending per transaction type.
# ---------------------------------------------------------------------------
AMOUNT_RANGES: dict[str, tuple[float, float]] = {
    "cat_food_drink": (8.0, 95.0),
    "cat_transport": (10.0, 75.0),
    "cat_shopping": (20.0, 250.0),
    "cat_home_utilities": (40.0, 180.0),
    "cat_entertainment_leisure": (10.0, 90.0),
    "cat_health_wellbeing": (20.0, 180.0),
    "cat_personal": (15.0, 80.0),
    "cat_travel": (100.0, 500.0),
    "cat_financial_services": (10.0, 300.0),
    "cat_family": (20.0, 120.0),
    "cat_pets": (15.0, 100.0),
    "cat_cash": (20.0, 200.0),
}

# ---------------------------------------------------------------------------
# USER SPENDING PROFILES
# Each user gets a category weight map (higher = more transactions in that cat)
# and a date range within the last 60 days.
# ---------------------------------------------------------------------------
SPENDING_CATEGORIES = list(AMOUNT_RANGES.keys())

USERS = {
    "user_marcus": {
        "n_transactions": 55,
        "weights": {
            "cat_food_drink": 0.35,  # overspender — eats out constantly
            "cat_transport": 0.20,
            "cat_shopping": 0.15,
            "cat_entertainment_leisure": 0.10,
            "cat_home_utilities": 0.08,
            "cat_health_wellbeing": 0.04,
            "cat_personal": 0.04,
            "cat_financial_services": 0.02,
            "cat_cash": 0.01,
            "cat_travel": 0.01,
            "cat_family": 0.00,
            "cat_pets": 0.00,
        },
        # Amount multiplier: Marcus spends more per transaction
        "amount_multiplier": 1.3,
    },
    "user_sarah": {
        "n_transactions": 40,
        "weights": {
            "cat_food_drink": 0.20,
            "cat_health_wellbeing": 0.22,  # disciplined — gym, pharmacy
            "cat_shopping": 0.15,
            "cat_travel": 0.15,  # traveler
            "cat_home_utilities": 0.10,
            "cat_transport": 0.08,
            "cat_entertainment_leisure": 0.05,
            "cat_personal": 0.03,
            "cat_financial_services": 0.01,
            "cat_family": 0.01,
            "cat_pets": 0.00,
            "cat_cash": 0.00,
        },
        "amount_multiplier": 0.9,
    },
    "user_bob": {
        "n_transactions": 45,
        "weights": {
            "cat_transport": 0.35,  # drives everywhere, gas + tolls
            "cat_food_drink": 0.20,
            "cat_shopping": 0.15,
            "cat_home_utilities": 0.10,
            "cat_financial_services": 0.08,  # debt payments
            "cat_entertainment_leisure": 0.05,
            "cat_health_wellbeing": 0.03,
            "cat_personal": 0.02,
            "cat_pets": 0.01,
            "cat_family": 0.01,
            "cat_travel": 0.00,
            "cat_cash": 0.00,
        },
        "amount_multiplier": 1.0,
    },
}


# ---------------------------------------------------------------------------
# WARNINGS — pre-defined per user to match demo narrative
# ---------------------------------------------------------------------------
WARNINGS = {
    "user_marcus": [
        {
            "id": "w_marcus_001",
            "timestamp": str(TODAY - timedelta(days=2)) + "T09:15:00Z",
            "source": "cash_flow",
            "risk_level": "HIGH",
            "title": "Food & Drink spending 38% above your average",
            "message": "$890 spent this month vs. $645 avg — and it's only day 17.",
            "context": {
                "category": "cat_food_drink",
                "current_spend": 890,
                "average_spend": 645,
            },
            "outcome": {
                "user_action": "acknowledged",
                "action_label": "User acknowledged",
            },
        },
        {
            "id": "w_marcus_002",
            "timestamp": str(TODAY - timedelta(days=5)) + "T14:32:00Z",
            "source": "cash_flow",
            "risk_level": "HIGH",
            "title": "Rent due in 3 days — balance may not cover it",
            "message": "Balance: $1,600. Rent: $1,500. You'll have $100 left.",
            "context": {
                "projected_balance": 100,
                "triggering_bill": {"name": "Rent", "amount": 1500, "due_in_days": 3},
            },
            "outcome": {
                "user_action": "acknowledged",
                "action_label": "User acknowledged",
            },
        },
        {
            "id": "w_marcus_003",
            "timestamp": str(TODAY - timedelta(days=10)) + "T18:05:00Z",
            "source": "bnpl",
            "risk_level": "MEDIUM",
            "title": "2 active BNPL plans detected",
            "message": "Total outstanding: $600. Combined with rent, your debt ratio is elevated.",
            "context": {
                "bnpl_score": 58,
                "num_active_plans": 2,
                "total_outstanding": 600,
            },
            "outcome": {
                "user_action": "acknowledged",
                "action_label": "User acknowledged",
            },
        },
    ],
    "user_sarah": [
        {
            "id": "w_sarah_001",
            "timestamp": str(TODAY - timedelta(days=8)) + "T11:20:00Z",
            "source": "cash_flow",
            "risk_level": "LOW",
            "title": "Travel spending higher than usual",
            "message": "$340 on travel this week — 2x your weekly average.",
            "context": {
                "category": "cat_travel",
                "current_spend": 340,
                "weekly_average": 170,
            },
            "outcome": {
                "user_action": "acknowledged",
                "action_label": "User acknowledged",
            },
        },
    ],
    "user_bob": [
        {
            "id": "w_bob_001",
            "timestamp": str(TODAY - timedelta(days=3)) + "T10:45:00Z",
            "source": "bnpl",
            "risk_level": "HIGH",
            "title": "BNPL payment is late",
            "message": "Your $600 BNPL plan has a missed payment. Risk score: 78.",
            "context": {
                "bnpl_score": 78,
                "num_active_plans": 1,
                "total_outstanding": 600,
                "risk_factors": ["1 late BNPL payment"],
            },
            "outcome": {"user_action": "cancelled", "action_label": "User cancelled"},
        },
        {
            "id": "w_bob_002",
            "timestamp": str(TODAY - timedelta(days=7)) + "T16:10:00Z",
            "source": "cash_flow",
            "risk_level": "MEDIUM",
            "title": "Transport spending is 28% above average",
            "message": "$520 on transport this month vs. $405 avg.",
            "context": {
                "category": "cat_transport",
                "current_spend": 520,
                "average_spend": 405,
            },
            "outcome": {
                "user_action": "proceeded",
                "action_label": "User proceeded anyway",
            },
        },
    ],
}


# ---------------------------------------------------------------------------
# LOAD PARQUET — sample pool per category
# ---------------------------------------------------------------------------
def build_description_pool(parquet_path: Path) -> dict[str, list[str]]:
    """
    Returns {category: [description, ...]} with 300 unique descriptions per category.
    Filtered to USA/USD spending transactions (no income).
    """
    print("Loading parquet...")
    df = pd.read_parquet(parquet_path)

    # Keep only spending categories, USD, USA
    spend_cats = list(AMOUNT_RANGES.keys())
    df = df[
        (df["category"].isin(spend_cats))
        & (df["country"] == "USA")
        & (df["currency"] == "USD")
    ]

    pool: dict[str, list[str]] = {}
    for cat in spend_cats:
        descriptions = (
            df[df["category"] == cat]["description"].dropna().unique().tolist()
        )
        # Shuffle and cap at 300 to keep pool manageable
        random.shuffle(descriptions)
        pool[cat] = descriptions[:300]
        print(f"  {cat}: {len(pool[cat])} unique descriptions")

    return pool


# ---------------------------------------------------------------------------
# TRANSACTION GENERATION
# ---------------------------------------------------------------------------
def pick_amount(category: str, multiplier: float) -> float:
    lo, hi = AMOUNT_RANGES[category]
    raw = random.uniform(lo * multiplier, hi * multiplier)
    # Round to 2 decimal places, cents ending in 0, 5, 9 (realistic)
    return round(raw, 2)


def pick_date(days_back_max: int = 60) -> str:
    """Pick a random date within the last N days, biased toward recent."""
    offset = int(random.triangular(0, days_back_max, 10))  # peak at 10 days ago
    return str(TODAY - timedelta(days=offset))


def generate_transactions(
    user_id: str,
    profile: dict,
    pool: dict[str, list[str]],
) -> list[dict]:
    n = profile["n_transactions"]
    weights_map = profile["weights"]
    multiplier = profile["amount_multiplier"]

    categories = list(weights_map.keys())
    weights = [weights_map[c] for c in categories]

    txn_id = 0
    transactions = []

    for _ in range(n):
        cat = random.choices(categories, weights=weights, k=1)[0]
        descriptions = pool.get(cat, [])

        if not descriptions:
            continue

        description = random.choice(descriptions)
        amount = pick_amount(cat, multiplier)
        txn_date = pick_date()

        # Determine subcategory from description — we don't have it mapped,
        # so we tag it as the category for now (Thom's classifier will override this)
        transactions.append(
            {
                "id": f"txn_{user_id}_{txn_id:04d}",
                "user_id": user_id,
                "merchant_name": description,
                "amount": -round(amount, 2),  # negative = spending
                "category": cat,
                "subcategory": None,  # will be filled by classifier
                "date": txn_date,
                "currency": "USD",
            }
        )
        txn_id += 1

    # Sort by date descending
    transactions.sort(key=lambda t: t["date"], reverse=True)
    return transactions


# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
def main():
    pool = build_description_pool(PARQUET_PATH)

    output: dict = {"users": {}}

    for user_id, profile in USERS.items():
        print(f"\nGenerating transactions for {user_id}...")
        txns = generate_transactions(user_id, profile, pool)

        output["users"][user_id] = {
            "transactions": txns,
            "warnings": WARNINGS.get(user_id, []),
        }

        total_spent = sum(abs(t["amount"]) for t in txns)
        print(f"  {len(txns)} transactions | total spent: ${total_spent:,.2f}")

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w") as f:
        json.dump(output, f, indent=2)

    print(f"\nSaved to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
