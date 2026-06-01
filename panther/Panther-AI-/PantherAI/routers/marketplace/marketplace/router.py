"""
routers/marketplace/router.py
==============================
TickPay Marketplace API — 3 endpoints for product search, price comparison, and checkout.

POST /api/marketplace/search          — search products + BNPL filter
GET  /api/marketplace/compare-prices  — cross-vendor price comparison
POST /api/marketplace/checkout        — end-to-end cart → BNPL → order

All endpoints are JWT-protected (user_id required). Thin routers: all logic
lives in services/marketplace/. This file only validates input and delegates.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field

from core.logger import contract
from services.marketplace.product_search_agent import parse_and_search
from services.marketplace.bnpl_filter import apply_bnpl_filter
from services.marketplace.price_comparator import compare_prices
from services.marketplace.checkout_agent import checkout

router = APIRouter(prefix="/marketplace", tags=["marketplace"])


# ---------------------------------------------------------------------------
# Request / Response models
# ---------------------------------------------------------------------------

class SearchRequest(BaseModel):
    user_id: str = Field(..., pattern=r"^[a-z0-9_]{3,50}$")
    query: str = Field(..., min_length=2, max_length=200)
    budget: Optional[float] = Field(None, gt=0)
    max_results: int = Field(10, ge=1, le=50)


class SearchResponse(BaseModel):
    query: str
    results: List[Dict[str, Any]]
    count: int


class CheckoutRequest(BaseModel):
    user_id: str = Field(..., pattern=r"^[a-z0-9_]{3,50}$")
    product_name: str = Field(..., min_length=1)
    product_id: str = Field(..., min_length=1)
    price: float = Field(..., gt=0)
    partner_id: str
    vendor: str
    tickpay_token: str = Field(..., min_length=8)
    num_payments: Optional[int] = Field(None, ge=1, le=36)


class CheckoutResponse(BaseModel):
    order_id: str
    product: str
    vendor: str
    partner_id: str
    bnpl_plan: Optional[Dict[str, Any]]
    total_cost: float
    currency: str
    status: str


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.post("/search", response_model=SearchResponse)
@contract
def search_products(req: SearchRequest) -> SearchResponse:
    """
    Searches for products matching the query, then applies per-user BNPL eligibility filter.

    Returns ranked results (price ASC → BNPL eligible first → delivery speed ASC).
    HIGH-risk BNPL products are filtered out for the given user.
    """
    query = req.query
    if req.budget:
        # Embed budget in query if not already present
        if f"${req.budget}" not in query and str(req.budget) not in query:
            query = f"{query} under ${req.budget}"

    try:
        raw = parse_and_search(query, max_results=req.max_results * 2)
        tagged = apply_bnpl_filter(raw, req.user_id)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Search failed: {e}")

    return SearchResponse(
        query=query,
        results=tagged[: req.max_results],
        count=len(tagged[: req.max_results]),
    )


@router.get("/compare-prices")
@contract
def compare_prices_endpoint(
    product_name: str = Query(..., min_length=2, max_length=200, description="Product to compare across vendors"),
    max_results: int = Query(20, ge=1, le=50),
) -> Dict[str, Any]:
    """
    Searches all mock partners for the product and returns a sorted cross-vendor comparison.

    Response:
        query       — original search string
        offers      — all offers sorted cheapest-in-stock first
        cheapest    — lowest-price in-stock offer
        best_bnpl   — lowest-price BNPL-eligible in-stock offer
    """
    try:
        result = compare_prices(product_name, max_results=max_results)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Price comparison failed: {e}")

    return result


@router.post("/checkout", response_model=CheckoutResponse)
@contract
def checkout_endpoint(req: CheckoutRequest) -> CheckoutResponse:
    """
    Runs the full AP2-compatible 3-step checkout: Cart → (optional BNPL) → Confirm.

    Returns order_id and full purchase summary.
    partner_id must be one of: mock_nike, mock_amazon, mock_bestbuy.
    """
    try:
        result = checkout(
            user_id=req.user_id,
            product_name=req.product_name,
            product_id=req.product_id,
            price=req.price,
            partner_id=req.partner_id,
            vendor=req.vendor,
            tickpay_token=req.tickpay_token,
            num_payments=req.num_payments,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Checkout failed: {e}")

    return CheckoutResponse(**result)
