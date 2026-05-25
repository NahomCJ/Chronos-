"""
scripts/backfill_categories.py
===============================
One-time script to categorize existing transactions that have no subcategory.

Run this after deploying the classifier integration to populate categories
for all historical transactions already in Supabase.

Usage:
    cd src_git
    python scripts/backfill_categories.py

    # Dry run (prints what would happen, writes nothing):
    python scripts/backfill_categories.py --dry-run

    # Limit to N transactions (useful for testing):
    python scripts/backfill_categories.py --limit 50
"""

import argparse
import os
import sys

from dotenv import load_dotenv

# Allow imports from src_git root
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

load_dotenv()

from supabase import create_client
from services.categorizer import categorize

supabase = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_KEY"])


def backfill(dry_run: bool = False, limit: int = None):
    """
    Fetches all transactions without a subcategory and categorizes them.

    Args:
        dry_run: If True, prints results but writes nothing to Supabase.
        limit:   Max number of transactions to process. None = all.
    """
    print(f"{'[DRY RUN] ' if dry_run else ''}Starting backfill...")

    # Fetch uncategorized transactions
    query = (
        supabase.table("transactions")
        .select("id, merchant_name")
        .is_("subcategory", "null")
        .order("date", desc=True)
    )
    if limit:
        query = query.limit(limit)

    res = query.execute()
    transactions = res.data

    if not transactions:
        print("Nothing to backfill — all transactions already categorized.")
        return

    print(f"Found {len(transactions)} uncategorized transactions.")

    updated = 0
    skipped = 0

    for t in transactions:
        merchant = t.get("merchant_name") or "Unknown"
        result = categorize(merchant)

        if dry_run:
            print(
                f"  [{result['source']}] {merchant!r:40s} → {result['subcategory']} "
                f"(conf: {result['confidence']:.2f})"
            )
            updated += 1
            continue

        try:
            supabase.table("transactions").update({
                "subcategory": result["subcategory"],
                "category_confidence": result["confidence"],
                "category_source": result["source"],
                "user_corrected": False,
            }).eq("id", t["id"]).execute()
            updated += 1
        except Exception as e:
            print(f"  ⚠ Failed to update {t['id']}: {e}")
            skipped += 1

    print(f"\n{'[DRY RUN] ' if dry_run else ''}Done.")
    print(f"  Categorized : {updated}")
    if skipped:
        print(f"  Skipped     : {skipped}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Backfill transaction categories")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print results without writing to Supabase",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Max number of transactions to process",
    )
    args = parser.parse_args()
    backfill(dry_run=args.dry_run, limit=args.limit)
