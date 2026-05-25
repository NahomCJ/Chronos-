"""
routers/plaid/router.py
========================
FastAPI endpoints for Plaid Link flow.

FLOW:
  1. Mobile app calls POST /api/plaid/create-link-token
       → Gets a short-lived link_token
  2. User goes through Plaid Link UI (connects their bank)
  3. Mobile app calls POST /api/plaid/exchange-token with the public_token
       → We exchange it for a permanent access_token and store it in Supabase
  4. Now get_balance() and get_transactions() can use the real Plaid API
"""

import os
from datetime import datetime, timedelta

from dotenv import load_dotenv
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from supabase import create_client

import plaid
from plaid.model.link_token_create_request import LinkTokenCreateRequest
from plaid.model.link_token_create_request_user import LinkTokenCreateRequestUser
from plaid.model.item_public_token_exchange_request import ItemPublicTokenExchangeRequest

from services.banking.plaid_client import get_plaid_client, PLAID_PRODUCTS, PLAID_COUNTRY_CODES

load_dotenv()

router = APIRouter(prefix="/api/plaid", tags=["plaid"])

# Supabase client
supabase = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_KEY"])


# ---------------------------------------------------------------------------
# Request / Response models
# ---------------------------------------------------------------------------
class CreateLinkTokenRequest(BaseModel):
    user_id: str                    # e.g. "user_marcus"

class CreateLinkTokenResponse(BaseModel):
    link_token: str
    expiration: str

class ExchangeTokenRequest(BaseModel):
    user_id:      str
    public_token: str               # Short-lived token from Plaid Link UI
    institution:  str | None = None # Optional: bank name (e.g. "Chase")

class ExchangeTokenResponse(BaseModel):
    success:     bool
    message:     str
    item_id:     str


# ---------------------------------------------------------------------------
# POST /api/plaid/create-link-token
# ---------------------------------------------------------------------------
@router.post("/create-link-token", response_model=CreateLinkTokenResponse)
def create_link_token(request: CreateLinkTokenRequest):
    """
    Step 1 of Plaid Link flow.
    Creates a short-lived link_token the mobile app uses to open Plaid Link UI.

    The mobile app calls this first, then passes the link_token to the Plaid SDK.
    """
    client = get_plaid_client()

    try:
        plaid_request = LinkTokenCreateRequest(
            products=PLAID_PRODUCTS,
            client_name="Chronos",
            country_codes=PLAID_COUNTRY_CODES,
            language="en",
            user=LinkTokenCreateRequestUser(client_user_id=request.user_id),
        )
        response = client.link_token_create(plaid_request)

        return CreateLinkTokenResponse(
            link_token=response["link_token"],
            expiration=str(response["expiration"]),
        )

    except plaid.ApiException as e:
        raise HTTPException(status_code=400, detail=f"Plaid error: {e.body}")


# ---------------------------------------------------------------------------
# POST /api/plaid/exchange-token
# ---------------------------------------------------------------------------
@router.post("/exchange-token", response_model=ExchangeTokenResponse)
def exchange_token(request: ExchangeTokenRequest):
    """
    Step 2 of Plaid Link flow.
    Exchanges the short-lived public_token for a permanent access_token,
    then stores it in Supabase plaid_tokens table.

    After this succeeds, get_balance() and get_transactions() will use
    the real Plaid API instead of mocks for this user.
    """
    client = get_plaid_client()

    try:
        # Exchange public_token → access_token
        exchange_request = ItemPublicTokenExchangeRequest(public_token=request.public_token)
        exchange_response = client.item_public_token_exchange(exchange_request)

        access_token = exchange_response["access_token"]
        item_id      = exchange_response["item_id"]

        # Upsert into Supabase (replace if user already has a token)
        supabase.table("plaid_tokens").upsert({
            "user_id":      request.user_id,
            "access_token": access_token,
            "item_id":      item_id,
            "institution":  request.institution,
            "updated_at":   datetime.utcnow().isoformat(),
        }, on_conflict="user_id").execute()

        return ExchangeTokenResponse(
            success=True,
            message=f"Bank account connected for {request.user_id}",
            item_id=item_id,
        )

    except plaid.ApiException as e:
        raise HTTPException(status_code=400, detail=f"Plaid error: {e.body}")
