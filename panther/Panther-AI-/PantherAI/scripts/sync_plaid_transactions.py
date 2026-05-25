"""
scripts/sync_plaid_transactions.py
====================================
Syncs recent Plaid transactions into Supabase for all users who have
connected their bank account.

WHY THIS EXISTS:
  get_transactions() calls Plaid live every time, which is fine for MVP.
  This script is for batch syncing — useful for:
    - Keeping Supabase up-to-date as a cache
    - Kevin (the chatbot) querying transaction history without hitting Plaid every message
    - Future: webhook handler when Plaid pushes new transactions

USAGE:
    # Sync last 30 days for all connected users
    python scripts/sync_plaid_transactions.py

    # Sync specific user
    python scripts/sync_plaid_transactions.py --user user_marcus

    # Sync last N days
    python scripts/sync_plaid_transactions.py --days 7
"""

import argparse
import os
import sys
from datetime import date, timedelta

from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

# Add project root to path so we can import services
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.banking.plaid_client import get_plaid_client

supabase = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_KEY"])


# ---------------------------------------------------------------------------
def get_connected_users(user_id: str | None = None) -> list[dict]:
    """Returns all users who have a Plaid access token."""
    query = supabase.table("plaid_tokens").select("user_id, access_token, institution")
    if user_id:
        query = query.eq("user_id", user_id)
    res = query.execute()
    return res.data or []


def get_account_id(user_id: str) -> str | None:
    """Returns the Supabase account UUID for a user."""
    res = supabase.table("accounts").select("id").eq("user_id", user_id).execute()
    return res.data[0]["id"] if res.data else None


def sync_user_transactions(user_id: str, access_token: str, days_back: int = 30) -> int:
    """
    Fetches transactions from Plaid and upserts them into Supabase.
    Returns number of transactions synced.
    """
    from plaid.model.transactions_get_request import TransactionsGetRequest
    from plaid.model.transactions_get_request_options import TransactionsGetRequestOptions
    import plaid

    account_id = get_account_id(user_id)
    if not account_id:
        print(f"  ✗ No Supabase account found for {user_id}, skipping.")
        return 0

    client = get_plaid_client()
    start_date = date.today() - timedelta(days=days_back)
    end_date   = date.today()

    try:
        response = client.transactions_get(
            TransactionsGetRequest(
                access_token=access_token,
                start_date=start_date,
                end_date=end_date,
                options=TransactionsGetRequestOptions(count=100),
            )
        )
    except plaid.ApiException as e:
        print(f"  ✗ Plaid error for {user_id}: {e.body}")
        return 0

    transactions = response["transactions"]
    if not transactions:
        print(f"  — No transactions found for {user_id}")
        return 0

    # Upsert into Supabase
    # We use plaid's transaction_id as a stable dedup key
    rows = []
    for t in transactions:
        rows.append({
            "account_id":    account_id,
            "merchant_name": t.get("merchant_name") or t.get("name", "Unknown"),
            "amount":        -abs(float(t["amount"])),  # flip: Plaid positive = debit
            "date":          str(t["date"]),
            "plaid_txn_id":  t["transaction_id"],       # for dedup (add column if needed)
        })

    # Simple insert — skip duplicates by checking date range
    # (For production, add plaid_txn_id UNIQUE constraint to transactions table)
    inserted = 0
    for row in rows:
        existing = (
            supabase.table("transactions")
            .select("id")
            .eq("account_id", account_id)
            .eq("merchant_name", row["merchant_name"])
            .eq("date", row["date"])
            .eq("amount", row["amount"])
            .execute()
        )
        if not existing.data:
            # Remove plaid_txn_id if column doesn't exist yet
            row_to_insert = {k: v for k, v in row.items() if k != "plaid_txn_id"}
            supabase.table("transactions").insert(row_to_insert).execute()
            inserted += 1

    return inserted


# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Sync Plaid transactions to Supabase")
    parser.add_argument("--user", help="Sync specific user_id only", default=None)
    parser.add_argument("--days", help="Days back to sync (default: 30)", type=int, default=30)
    args = parser.parse_args()

    print(f"\n🔄 CHRONOS — Plaid Transaction Sync (last {args.days} days)")
    print("=" * 55)

    users = get_connected_users(user_id=args.user)

    if not users:
        if args.user:
            print(f"⚠ No Plaid token found for {args.user}.")
        else:
            print("⚠ No users have connected their bank yet.")
        print("  Run the Plaid Link flow first (POST /api/plaid/exchange-token).")
        return

    total_synced = 0
    for user in users:
        user_id     = user["user_id"]
        institution = user.get("institution") or "Unknown bank"
        print(f"\n👤 {user_id} ({institution})")
        count = sync_user_transactions(user_id, user["access_token"], days_back=args.days)
        print(f"  ✓ Synced {count} new transaction(s)")
        total_synced += count

    print(f"\n✅ Done. Total new transactions synced: {total_synced}")


if __name__ == "__main__":
    main()
