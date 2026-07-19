"""
routers/webhooks/plaid.py
=========================
Plaid webhook handler — auto-categorizes new transactions as they arrive.

Plaid calls POST /webhooks/plaid/transactions whenever:
  - INITIAL_UPDATE: First batch of transactions after bank connection
  - HISTORICAL_UPDATE: Full transaction history loaded
  - DEFAULT_UPDATE: New transactions since last sync

Flow:
  1. Plaid sends webhook with user item_id + list of new transaction IDs
  2. We fetch those transactions from Plaid using transactions_get
  3. Run each merchant name through the classifier
  4. Save to Supabase transactions table with category data

NOTE: Plaid sandbox webhooks can be triggered manually via:
  POST https://sandbox.plaid.com/sandbox/item/fire_webhook
"""

import os
from datetime import date, timedelta
from typing import Any, Dict, List, Optional

from dotenv import load_dotenv
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from core.logger import log
from services.categorizer import categorize, enqueue_low_confidence

load_dotenv()

router = APIRouter(prefix="/webhooks/plaid", tags=["webhooks"])

_supabase = None
_supabase_loaded = False


def _get_supabase():
    global _supabase, _supabase_loaded
    if _supabase_loaded:
        return _supabase

    _supabase_loaded = True
    if not (os.getenv("SUPABASE_URL") and os.getenv("SUPABASE_KEY")):
        return None

    try:
        from supabase import create_client
    except ImportError:
        return None

    _supabase = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_KEY"])
    return _supabase

# Webhook types we care about
TRANSACTION_WEBHOOK_TYPES = {"INITIAL_UPDATE", "HISTORICAL_UPDATE", "DEFAULT_UPDATE"}


# ---------------------------------------------------------------------------
# Request model
# ---------------------------------------------------------------------------

class PlaidWebhookPayload(BaseModel):
    webhook_type: str          # e.g. "TRANSACTIONS"
    webhook_code: str          # e.g. "DEFAULT_UPDATE"
    item_id: str               # Plaid item_id — maps to a user in plaid_tokens
    error: Optional[Any] = None
    new_transactions: Optional[int] = None


# ---------------------------------------------------------------------------
# POST /webhooks/plaid/transactions
# ---------------------------------------------------------------------------

@router.post("/transactions")
def handle_plaid_webhook(payload: PlaidWebhookPayload):
    """
    Receives Plaid transaction webhooks, fetches new transactions,
    runs them through the classifier, and saves to Supabase.

    Plaid docs: https://plaid.com/docs/api/products/transactions/#transactions-webhooks
    """
    log.contract(
        "handle_plaid_webhook",
        item_id=payload.item_id,
        webhook_code=payload.webhook_code,
        new_transactions=payload.new_transactions,
    )

    # Only handle transaction webhooks
    if payload.webhook_type != "TRANSACTIONS":
        return {"status": "ignored", "reason": f"webhook_type={payload.webhook_type} not handled"}

    if payload.webhook_code not in TRANSACTION_WEBHOOK_TYPES:
        return {"status": "ignored", "reason": f"webhook_code={payload.webhook_code} not handled"}

    if payload.error:
        log.failure("handle_plaid_webhook", error_type="PlaidError", message=str(payload.error))
        raise HTTPException(status_code=400, detail=f"Plaid error in webhook: {payload.error}")

    supabase = _get_supabase()
    if supabase is None:
        raise HTTPException(status_code=503, detail="Supabase is not configured")

    # Resolve user_id + access_token from item_id
    token_res = (
        supabase.table("plaid_tokens")
        .select("user_id, access_token")
        .eq("item_id", payload.item_id)
        .execute()
    )
    if not token_res.data:
        raise HTTPException(status_code=404, detail=f"No user found for item_id: {payload.item_id}")

    user_id = token_res.data[0]["user_id"]
    access_token = token_res.data[0]["access_token"]

    # Fetch recent transactions from Plaid (last 30 days covers any new ones)
    transactions = _fetch_plaid_transactions(access_token, days_back=30)

    if not transactions:
        return {"status": "ok", "categorized": 0}

    # Resolve account_id for this user in Supabase
    acct_res = supabase.table("accounts").select("id").eq("user_id", user_id).execute()
    if not acct_res.data:
        raise HTTPException(status_code=404, detail=f"No account found for user: {user_id}")
    account_id = acct_res.data[0]["id"]

    # Categorize and upsert each transaction
    saved = _categorize_and_save(transactions, account_id, user_id)

    log.result("handle_plaid_webhook", duration_ms=0, categorized=saved)
    return {"status": "ok", "categorized": saved}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _fetch_plaid_transactions(access_token: str, days_back: int = 30) -> List[Dict]:
    """Fetches transactions from Plaid for the given access token."""
    try:
        from plaid.model.transactions_get_request import TransactionsGetRequest
        from plaid.model.transactions_get_request_options import TransactionsGetRequestOptions
        from services.banking.plaid_client import get_plaid_client

        client = get_plaid_client()
        start_date = date.today() - timedelta(days=days_back)
        end_date = date.today()

        response = client.transactions_get(
            TransactionsGetRequest(
                access_token=access_token,
                start_date=start_date,
                end_date=end_date,
                options=TransactionsGetRequestOptions(count=100),
            )
        )
        return response["transactions"]
    except Exception as e:
        log.failure("_fetch_plaid_transactions", error_type=type(e).__name__, message=str(e))
        return []


def _categorize_and_save(transactions: List[Dict], account_id: str, user_id: str) -> int:
    """
    Runs each transaction through the classifier and upserts into Supabase.
    Returns the number of transactions saved.
    """
    supabase = _get_supabase()
    if supabase is None:
        return 0

    rows = []
    tier3_pending: list[dict[str, str]] = []
    for t in transactions:
        merchant = t.get("merchant_name") or t.get("name") or "Unknown"
        result = categorize(
            merchant,
            transaction_id=t["transaction_id"],
            user_id=user_id,
            queue_tier3=False,
        )
        if result["source"] == "Low Confidence":
            tier3_pending.append(
                {
                    "transaction_id": t["transaction_id"],
                    "merchant": merchant,
                }
            )

        rows.append({
            "id": t["transaction_id"],        # Plaid transaction_id as PK
            "account_id": account_id,
            "merchant_name": merchant,
            "amount": -abs(float(t["amount"])),  # Plaid positive = debit, we flip
            "date": str(t["date"]),
            "subcategory": result["subcategory"],
            "category_confidence": result["confidence"],
            "category_source": result["source"],
            "user_corrected": False,
        })

    if not rows:
        return 0

    # Upsert — if transaction already exists, skip (don't overwrite user corrections)
    supabase.table("transactions").upsert(
        rows,
        on_conflict="id",
        ignore_duplicates=True,
    ).execute()

    for pending in tier3_pending:
        enqueue_low_confidence(
            transaction_id=pending["transaction_id"],
            user_id=user_id,
            merchant_name=pending["merchant"],
        )

    return len(rows)
