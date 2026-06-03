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

from core.logger import log, contract
from services.categorizer import categorize
from services.banking.mock_api import LOCAL_MOCK_DATA

load_dotenv()

router = APIRouter(prefix="/api/transactions", tags=["transactions"])

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

_mock_corrections: dict[str, str] = {}

_VALID_SUBCATEGORIES = {
    "sub_groceries",
    "sub_restaurants_bars",
    "sub_delivery",
    "sub_public_transport",
    "sub_fuel_tolls",
    "sub_taxi_ride",
    "sub_flights",
    "sub_hotels_acc",
    "sub_holidays_trips",
    "sub_medical_pharmacy",
    "sub_fitness_gym",
    "sub_wellness_beauty",
    "sub_supplementation",
    "sub_fashion",
    "sub_electronics",
    "sub_home_general",
    "sub_rent_mortgage",
    "sub_utility_bills",
    "sub_internet_phone",
    "sub_home_maintenance",
    "sub_subscriptions",
    "sub_events_culture",
    "sub_hobbies",
    "sub_education",
    "sub_gifts_donations",
    "sub_family_kids",
    "sub_pets",
    "sub_insurance",
    "sub_taxes_fees",
    "sub_investments",
    "sub_crypto",
    "sub_nfts",
    "sub_debt_loans",
    "sub_savings",
    "sub_cash_transfers",
    "sub_atm_withdrawals",
    "sub_salary",
    "sub_dividends",
    "sub_cashback",
    "sub_interest",
    "sub_refunds",
    "sub_side_hustle",
    "sub_other_income",
    "sub_general_misc",
}


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
    supabase = _get_supabase()
    if supabase is None:
        return _list_mock_transactions(user_id, days, category, merchant, start_date, end_date)

    # Resolve account_id for this user
    try:
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
    except HTTPException:
        raise
    except Exception as e:
        log.failure(
            "list_transactions",
            error_type=type(e).__name__,
            message=str(e),
            user_id=user_id,
            detail="Supabase query failed, falling back to local mock",
        )
        return _list_mock_transactions(user_id, days, category, merchant, start_date, end_date)


# ---------------------------------------------------------------------------
# GET /api/transactions/:id
# ---------------------------------------------------------------------------

@router.get("/{transaction_id}", response_model=TransactionOut)
@contract
def get_transaction(transaction_id: str):
    """
    Returns a single transaction by its ID.
    """
    supabase = _get_supabase()
    if supabase is None:
        return _get_mock_transaction(transaction_id)

    try:
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
    except HTTPException:
        raise
    except Exception as e:
        log.failure(
            "get_transaction",
            error_type=type(e).__name__,
            message=str(e),
            transaction_id=transaction_id,
            detail="Supabase query failed, falling back to local mock",
        )
        return _get_mock_transaction(transaction_id)


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
    _validate_subcategory(body.subcategory)

    supabase = _get_supabase()
    if supabase is None:
        return _patch_mock_transaction(transaction_id, body.subcategory)

    # Verify transaction exists
    try:
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
    except HTTPException:
        raise
    except Exception as e:
        log.failure(
            "correct_category",
            error_type=type(e).__name__,
            message=str(e),
            transaction_id=transaction_id,
            detail="Supabase query failed, falling back to local mock",
        )
        return _patch_mock_transaction(transaction_id, body.subcategory)


def _validate_subcategory(subcategory: str) -> None:
    if subcategory not in _VALID_SUBCATEGORIES:
        raise HTTPException(status_code=422, detail=f"Invalid subcategory: {subcategory}")


def _list_mock_transactions(
    user_id: str,
    days: int,
    category: Optional[str],
    merchant: Optional[str],
    start_date: Optional[str],
    end_date: Optional[str],
) -> list[TransactionOut]:
    if user_id not in LOCAL_MOCK_DATA:
        raise HTTPException(status_code=404, detail=f"No account found for user: {user_id}")

    since = start_date or str(date.today() - timedelta(days=days))
    until = end_date or str(date.today())
    rows = [
        _mock_transaction_out(user_id, index, txn)
        for index, txn in enumerate(LOCAL_MOCK_DATA[user_id].get("transactions", []))
        if since <= txn["date"] <= until
    ]

    if category:
        rows = [txn for txn in rows if txn.subcategory == category]
    if merchant:
        needle = merchant.upper()
        rows = [txn for txn in rows if needle in txn.merchant_name.upper()]

    return rows


def _get_mock_transaction(transaction_id: str) -> TransactionOut:
    for user_id, payload in LOCAL_MOCK_DATA.items():
        for index, txn in enumerate(payload.get("transactions", [])):
            if _mock_transaction_id(user_id, index) == transaction_id:
                return _mock_transaction_out(user_id, index, txn)
    raise HTTPException(status_code=404, detail=f"Transaction not found: {transaction_id}")


def _patch_mock_transaction(transaction_id: str, subcategory: str) -> PatchCategoryResponse:
    _get_mock_transaction(transaction_id)
    _mock_corrections[transaction_id] = subcategory
    log.contract("correct_category", transaction_id=transaction_id, new_subcategory=subcategory)
    return PatchCategoryResponse(
        id=transaction_id,
        subcategory=subcategory,
        user_corrected=True,
    )


def _mock_transaction_out(user_id: str, index: int, txn: dict) -> TransactionOut:
    txn_id = _mock_transaction_id(user_id, index)
    corrected = _mock_corrections.get(txn_id)
    if corrected:
        subcategory = corrected
        confidence = 1.0
        source = "user_correction"
        user_corrected = True
    else:
        result = categorize(txn["merchant"])
        subcategory = result["subcategory"]
        confidence = result["confidence"]
        source = result["source"]
        user_corrected = False

    return TransactionOut(
        id=txn_id,
        user_id=user_id,
        merchant_name=txn["merchant"],
        amount=float(txn["amount"]),
        date=txn["date"],
        subcategory=subcategory,
        category_confidence=confidence,
        category_source=source,
        user_corrected=user_corrected,
    )


def _mock_transaction_id(user_id: str, index: int) -> str:
    return f"mock-{user_id}-{index}"
