"""
routers/transactions/router.py
==============================
Transactions API — fetch, inspect, and correct categorized transactions.

Endpoints:
    GET  /api/transactions          List transactions for a user (with filters)
    GET  /api/transactions/:id      Single transaction by ID
    PATCH /api/transactions/:id     User corrects a category (feedback loop)
"""

import os
from datetime import date, timedelta
from typing import Optional

from dotenv import load_dotenv
from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from supabase import create_client

from core.logger import log, contract
from services.categorizer import categorize

load_dotenv()

router = APIRouter(prefix="/api/transactions", tags=["transactions"])

supabase = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_KEY"])


# ---------------------------------------------------------------------------
# Response / Request models
# ---------------------------------------------------------------------------

class TransactionOut(BaseModel):
    id: str
    user_id: str
    merchant_name: str
    amount: float
    date: str
    subcategory: Optional[str] = None
    category_confidence: Optional[float] = None
    category_source: Optional[str] = None
    user_corrected: bool = False


class PatchCategoryRequest(BaseModel):
    subcategory: str  # e.g. "sub_food_coffee"


class PatchCategoryResponse(BaseModel):
    id: str
    subcategory: str
    user_corrected: bool


# ---------------------------------------------------------------------------
# GET /api/transactions
# ---------------------------------------------------------------------------

@router.get("", response_model=list[TransactionOut])
@contract
def list_transactions(
    user_id: str = Query(..., description="User ID, e.g. user_marcus"),
    days: int = Query(30, description="How many days back to fetch"),
    category: Optional[str] = Query(None, description="Filter by subcategory slug"),
    merchant: Optional[str] = Query(None, description="Filter by merchant name (partial match)"),
    start_date: Optional[str] = Query(None, description="Start date YYYY-MM-DD"),
    end_date: Optional[str] = Query(None, description="End date YYYY-MM-DD"),
):
    """
    Returns categorized transactions for a user.

    Filters: days back, subcategory, merchant (partial), date range.
    """
    # Resolve account_id for this user
    acct = supabase.table("accounts").select("id").eq("user_id", user_id).execute()
    if not acct.data:
        raise HTTPException(status_code=404, detail=f"No account found for user: {user_id}")
    account_id = acct.data[0]["id"]

    # Build date range
    since = start_date or str(date.today() - timedelta(days=days))
    until = end_date or str(date.today())

    query = (
        supabase.table("transactions")
        .select("id, account_id, merchant_name, amount, date, subcategory, category_confidence, category_source, user_corrected")
        .eq("account_id", account_id)
        .gte("date", since)
        .lte("date", until)
        .order("date", desc=True)
    )

    if category:
        query = query.eq("subcategory", category)
    if merchant:
        query = query.ilike("merchant_name", f"%{merchant}%")

    res = query.execute()

    return [
        TransactionOut(
            id=t["id"],
            user_id=user_id,
            merchant_name=t["merchant_name"],
            amount=float(t["amount"]),
            date=t["date"],
            subcategory=t.get("subcategory"),
            category_confidence=t.get("category_confidence"),
            category_source=t.get("category_source"),
            user_corrected=t.get("user_corrected", False),
        )
        for t in res.data
    ]


# ---------------------------------------------------------------------------
# GET /api/transactions/:id
# ---------------------------------------------------------------------------

@router.get("/{transaction_id}", response_model=TransactionOut)
@contract
def get_transaction(transaction_id: str):
    """
    Returns a single transaction by its ID.
    """
    res = (
        supabase.table("transactions")
        .select("id, account_id, merchant_name, amount, date, subcategory, category_confidence, category_source, user_corrected")
        .eq("id", transaction_id)
        .execute()
    )
    if not res.data:
        raise HTTPException(status_code=404, detail=f"Transaction not found: {transaction_id}")

    t = res.data[0]

    # Resolve user_id from account_id
    acct = supabase.table("accounts").select("user_id").eq("id", t["account_id"]).execute()
    user_id = acct.data[0]["user_id"] if acct.data else "unknown"

    return TransactionOut(
        id=t["id"],
        user_id=user_id,
        merchant_name=t["merchant_name"],
        amount=float(t["amount"]),
        date=t["date"],
        subcategory=t.get("subcategory"),
        category_confidence=t.get("category_confidence"),
        category_source=t.get("category_source"),
        user_corrected=t.get("user_corrected", False),
    )


# ---------------------------------------------------------------------------
# PATCH /api/transactions/:id
# ---------------------------------------------------------------------------

@router.patch("/{transaction_id}", response_model=PatchCategoryResponse)
@contract
def correct_category(transaction_id: str, body: PatchCategoryRequest):
    """
    User corrects the category of a transaction.

    Marks user_corrected=True so the feedback loop can identify
    human-verified labels for future classifier retraining.
    """
    # Verify transaction exists
    check = supabase.table("transactions").select("id").eq("id", transaction_id).execute()
    if not check.data:
        raise HTTPException(status_code=404, detail=f"Transaction not found: {transaction_id}")

    supabase.table("transactions").update({
        "subcategory": body.subcategory,
        "category_source": "user_correction",
        "category_confidence": 1.0,
        "user_corrected": True,
    }).eq("id", transaction_id).execute()

    log.contract("correct_category", transaction_id=transaction_id, new_subcategory=body.subcategory)

    return PatchCategoryResponse(
        id=transaction_id,
        subcategory=body.subcategory,
        user_corrected=True,
    )
