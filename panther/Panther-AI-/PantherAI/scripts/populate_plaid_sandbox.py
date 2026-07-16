"""
populate_plaid_sandbox.py
=========================
One-shot: bootstraps Plaid Sandbox data for the three demo users.

What it does:
  1. For each user, creates a sandbox public_token against a fake bank.
  2. Exchanges it for an access_token (the token that fetches real data).
  3. Upserts plaid_tokens row.
  4. Pulls recent transactions via /transactions/get and inserts them into
     the `transactions` table, tagged with the user's Supabase account_id.

Why this exists:
  Plaid Sandbox replaces a real Plaid Link frontend flow. Instead of clicking
  through a fake bank UI, /sandbox/public_token/create mints a public_token
  directly for a chosen test institution. This lets us populate realistic
  transaction history without running the frontend.

Usage:
    python scripts/populate_plaid_sandbox.py               # all 3 users
    python scripts/populate_plaid_sandbox.py --days 90     # pull 90 days
    python scripts/populate_plaid_sandbox.py --user user_marcus
"""

from __future__ import annotations

import argparse
import os
import sys
from datetime import date, datetime, timedelta

import plaid
from dotenv import load_dotenv
from plaid.model.item_public_token_exchange_request import (
    ItemPublicTokenExchangeRequest,
)
from plaid.model.products import Products
from plaid.model.sandbox_public_token_create_request import (
    SandboxPublicTokenCreateRequest,
)
from plaid.model.transactions_get_request import TransactionsGetRequest
from plaid.model.transactions_get_request_options import TransactionsGetRequestOptions
from supabase import create_client

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.banking.plaid_client import get_plaid_client  # noqa: E402

load_dotenv(".env")


supabase = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_KEY"])


# Assign one institution per user for variety. These are the three primary
# Plaid Sandbox institutions that return full transactions history.
USERS = [
    {
        "user_id": "user_marcus",
        "institution_id": "ins_109508",
        "institution_name": "First Platypus Bank",
    },
    {
        "user_id": "user_sarah",
        "institution_id": "ins_109509",
        "institution_name": "Tartan Bank",
    },
    {
        "user_id": "user_bob",
        "institution_id": "ins_109510",
        "institution_name": "Houndstooth Bank",
    },
]


def get_account_id(user_id: str) -> str | None:
    res = supabase.table("accounts").select("id").eq("user_id", user_id).execute()
    return res.data[0]["id"] if res.data else None


def create_sandbox_access_token(client, institution_id: str) -> str:
    req = SandboxPublicTokenCreateRequest(
        institution_id=institution_id,
        initial_products=[Products("transactions")],
    )
    public_token = client.sandbox_public_token_create(req)["public_token"]

    exchange = client.item_public_token_exchange(
        ItemPublicTokenExchangeRequest(public_token=public_token)
    )
    return exchange["access_token"], exchange["item_id"]


def upsert_plaid_token(
    user_id: str, access_token: str, item_id: str, institution: str
) -> None:
    supabase.table("plaid_tokens").upsert(
        {
            "user_id": user_id,
            "access_token": access_token,
            "item_id": item_id,
            "institution": institution,
            "updated_at": datetime.utcnow().isoformat(),
        },
        on_conflict="user_id",
    ).execute()


def pull_transactions(client, access_token: str, days_back: int) -> list[dict]:
    """Calls /transactions/get with simple pagination."""
    start = date.today() - timedelta(days=days_back)
    end = date.today()
    all_rows: list[dict] = []
    offset = 0

    while True:
        try:
            resp = client.transactions_get(
                TransactionsGetRequest(
                    access_token=access_token,
                    start_date=start,
                    end_date=end,
                    options=TransactionsGetRequestOptions(count=500, offset=offset),
                )
            )
        except plaid.ApiException as e:
            # Plaid Sandbox often returns PRODUCT_NOT_READY for 30-60s after
            # public_token creation. Caller should retry.
            raise RuntimeError(f"Plaid transactions_get failed: {e.body}") from e

        txns = resp["transactions"]
        all_rows.extend(txns)
        total = resp["total_transactions"]
        if len(all_rows) >= total or not txns:
            break
        offset += len(txns)

    return all_rows


def insert_transactions(account_id: str, txns: list[dict]) -> int:
    if not txns:
        return 0

    rows = []
    for t in txns:
        merchant = t.get("merchant_name") or t.get("name") or "Unknown"
        # Plaid convention: positive amount = debit (money leaving). Flip so
        # the codebase's convention holds (negative = spend, positive = income).
        rows.append(
            {
                "id": t["transaction_id"],
                "account_id": account_id,
                "merchant_name": merchant,
                "amount": -abs(float(t["amount"])),
                "date": str(t["date"]),
                "user_corrected": False,
            }
        )

    supabase.table("transactions").upsert(
        rows, on_conflict="id", ignore_duplicates=True
    ).execute()
    return len(rows)


def populate_user(client, user: dict, days_back: int) -> int:
    user_id = user["user_id"]
    print(f"\n▶ {user_id} ({user['institution_name']})")

    account_id = get_account_id(user_id)
    if not account_id:
        print(
            f"  ✗ No Supabase account for {user_id}. Run scripts/seed_mock_data.py first."
        )
        return 0

    access_token, item_id = create_sandbox_access_token(client, user["institution_id"])
    upsert_plaid_token(user_id, access_token, item_id, user["institution_name"])
    print(f"  ✓ plaid_tokens upserted (item_id={item_id[:12]}…)")

    # Sandbox backfills the history inside the Item; a small poll loop handles
    # the PRODUCT_NOT_READY window without blindly sleeping.
    last_err = None
    txns: list[dict] = []
    for attempt in range(6):
        try:
            txns = pull_transactions(client, access_token, days_back)
            break
        except RuntimeError as e:
            last_err = e
            if "PRODUCT_NOT_READY" in str(e):
                import time

                time.sleep(3)
                continue
            raise
    else:
        raise RuntimeError(f"Transactions never ready for {user_id}: {last_err}")

    inserted = insert_transactions(account_id, txns)
    print(f"  ✓ {inserted} transactions upserted ({days_back}d window)")
    return inserted


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--user", help="Populate only this user_id")
    parser.add_argument("--days", type=int, default=60, help="Days of history to pull")
    args = parser.parse_args()

    print("🌱 CHRONOS — Plaid Sandbox bootstrap")
    print("=" * 50)

    client = get_plaid_client()
    targets = [u for u in USERS if not args.user or u["user_id"] == args.user]
    if not targets:
        print(f"⚠ No user matches {args.user!r}")
        return

    total = 0
    for user in targets:
        total += populate_user(client, user, args.days)

    print(f"\n✅ Done. {total} transactions inserted across {len(targets)} user(s).")


if __name__ == "__main__":
    main()
