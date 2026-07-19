"""
seed_mock_data.py
=================
Inserts the 3 demo users (Marcus, Sarah, Bob) into Supabase.

USAGE
-----
1. Install deps (only needed once):
       pip install supabase python-dotenv

2. Create a .env file at the project root:
       SUPABASE_URL=https://xxxx.supabase.co
       SUPABASE_KEY=your-service-role-or-anon-key

3. Run:
       python seed_mock_data.py

Safe to run multiple times — it skips users that already exist.
"""

import os
from datetime import date, timedelta
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL: str = os.environ["SUPABASE_URL"]
SUPABASE_KEY: str = os.environ["SUPABASE_KEY"]

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


# ---------------------------------------------------------------------------
# Helper: calculate a due_day (calendar day) from "due in N days from today"
# ---------------------------------------------------------------------------
def due_day_from_now(days: int) -> int:
    return (date.today() + timedelta(days=days)).day


# ---------------------------------------------------------------------------
# SEED DATA
# ---------------------------------------------------------------------------
USERS = [
    {"id": "user_marcus", "email": "marcus@demo.com", "monthly_rent": 1500.00},
    {"id": "user_sarah", "email": "sarah@demo.com", "monthly_rent": 1200.00},
    {"id": "user_bob", "email": "bob@demo.com", "monthly_rent": 1400.00},
]

ACCOUNTS = [
    {"user_id": "user_marcus", "balance": 1600.00},
    {"user_id": "user_sarah", "balance": 5000.00},
    {"user_id": "user_bob", "balance": 2200.00},
]

BILLS = [
    # Marcus — HIGH RISK: rent due in 3 days, utilities + Netflix close behind
    {
        "user_id": "user_marcus",
        "name": "Rent",
        "amount": 1500.00,
        "due_day": due_day_from_now(3),
    },
    {
        "user_id": "user_marcus",
        "name": "Utilities",
        "amount": 120.00,
        "due_day": due_day_from_now(5),
    },
    {
        "user_id": "user_marcus",
        "name": "Netflix",
        "amount": 15.99,
        "due_day": due_day_from_now(7),
    },
    # Sarah — LOW RISK: only rent, 15 days away
    {
        "user_id": "user_sarah",
        "name": "Rent",
        "amount": 1200.00,
        "due_day": due_day_from_now(15),
    },
    # Bob — MEDIUM RISK: rent + car payment both due soon
    {
        "user_id": "user_bob",
        "name": "Rent",
        "amount": 1400.00,
        "due_day": due_day_from_now(7),
    },
    {
        "user_id": "user_bob",
        "name": "Car Payment",
        "amount": 300.00,
        "due_day": due_day_from_now(5),
    },
]

BNPLS = [
    # Marcus — 2 active BNPLs, no late payments
    {
        "user_id": "user_marcus",
        "total_amount": 400.00,
        "num_payments": 4,
        "status": "active",
    },
    {
        "user_id": "user_marcus",
        "total_amount": 200.00,
        "num_payments": 2,
        "status": "active",
    },
    # Sarah — no BNPLs
    # Bob — 1 active BNPL with a late payment
    {
        "user_id": "user_bob",
        "total_amount": 600.00,
        "num_payments": 6,
        "status": "late",
    },
]

# Transactions reference account IDs which we get after inserting accounts.
TRANSACTIONS_BY_USER = {
    "user_marcus": [
        {
            "merchant_name": "STARBUCKS",
            "amount": -4.50,
            "date": str(date.today() - timedelta(days=5)),
        },
        {
            "merchant_name": "UBER",
            "amount": -12.30,
            "date": str(date.today() - timedelta(days=5)),
        },
    ],
    "user_sarah": [
        {
            "merchant_name": "WHOLE FOODS",
            "amount": -89.50,
            "date": str(date.today() - timedelta(days=5)),
        },
    ],
    "user_bob": [
        {
            "merchant_name": "CHEVRON",
            "amount": -65.00,
            "date": str(date.today() - timedelta(days=6)),
        },
    ],
}


# ---------------------------------------------------------------------------
# SEEDING FUNCTIONS
# ---------------------------------------------------------------------------
def seed_users():
    print("\n▶ Seeding users...")
    for user in USERS:
        existing = supabase.table("users").select("id").eq("id", user["id"]).execute()
        if existing.data:
            print(f"  ⚠ Skipped (already exists): {user['id']}")
        else:
            supabase.table("users").insert(user).execute()
            print(f"  ✓ Inserted: {user['id']}")


def seed_accounts() -> dict:
    """Returns {user_id: account_id} map for use when seeding transactions."""
    print("\n▶ Seeding accounts...")
    account_map = {}
    for acct in ACCOUNTS:
        existing = (
            supabase.table("accounts")
            .select("id")
            .eq("user_id", acct["user_id"])
            .execute()
        )
        if existing.data:
            account_id = existing.data[0]["id"]
            print(f"  ⚠ Skipped (already exists): account for {acct['user_id']}")
        else:
            res = supabase.table("accounts").insert(acct).execute()
            account_id = res.data[0]["id"]
            print(f"  ✓ Inserted: account for {acct['user_id']} (id={account_id})")
        account_map[acct["user_id"]] = account_id
    return account_map


def seed_bills():
    print("\n▶ Seeding bills...")
    for bill in BILLS:
        # Simple duplicate check by user + name
        existing = (
            supabase.table("bills")
            .select("id")
            .eq("user_id", bill["user_id"])
            .eq("name", bill["name"])
            .execute()
        )
        if existing.data:
            print(f"  ⚠ Skipped (already exists): {bill['name']} for {bill['user_id']}")
        else:
            supabase.table("bills").insert(bill).execute()
            print(f"  ✓ Inserted: {bill['name']} for {bill['user_id']}")


def seed_bnpls():
    print("\n▶ Seeding BNPLs...")
    for bnpl in BNPLS:
        existing = (
            supabase.table("bnpls")
            .select("id")
            .eq("user_id", bnpl["user_id"])
            .eq("total_amount", bnpl["total_amount"])
            .execute()
        )
        if existing.data:
            print(
                f"  ⚠ Skipped (already exists): BNPL ${bnpl['total_amount']} for {bnpl['user_id']}"
            )
        else:
            supabase.table("bnpls").insert(bnpl).execute()
            print(f"  ✓ Inserted: BNPL ${bnpl['total_amount']} for {bnpl['user_id']}")


def seed_transactions(account_map: dict):
    print("\n▶ Seeding transactions...")
    for user_id, txns in TRANSACTIONS_BY_USER.items():
        account_id = account_map.get(user_id)
        if not account_id:
            print(f"  ✗ No account found for {user_id}, skipping transactions.")
            continue
        for txn in txns:
            existing = (
                supabase.table("transactions")
                .select("id")
                .eq("account_id", account_id)
                .eq("merchant_name", txn["merchant_name"])
                .eq("date", txn["date"])
                .execute()
            )
            if existing.data:
                print(f"  ⚠ Skipped: {txn['merchant_name']} for {user_id}")
            else:
                supabase.table("transactions").insert(
                    {"account_id": account_id, **txn}
                ).execute()
                print(f"  ✓ Inserted: {txn['merchant_name']} for {user_id}")


# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    print("🌱 CHRONOS — Seeding demo data into Supabase")
    print("=" * 50)

    seed_users()
    account_map = seed_accounts()
    seed_bills()
    seed_bnpls()
    seed_transactions(account_map)

    print("\n Done! Supabase now has 3 demo users: Marcus, Sarah, Bob.")
