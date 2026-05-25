"""
routers/marketplace/router.py
==============================
POST /api/marketplace/search — Product search for the Chronos marketplace.

Request:  { user_id, query, max_results?, budget? }
Response: { results: [ { id, name, price, merchant, category, image_url?, description? } ] }

[LIVE] Returns mock results. Replace `_mock_search` with a real product
catalogue or Firecrawl integration when ready.
"""

from __future__ import annotations

import uuid
from typing import Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, field_validator

from core.logger import log

router = APIRouter()


# ---------------------------------------------------------------------------
# Request / Response models
# ---------------------------------------------------------------------------

class MarketplaceSearchRequest(BaseModel):
    user_id: str
    query: str
    max_results: int = 10
    budget: Optional[float] = None

    @field_validator("query")
    @classmethod
    def query_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("query cannot be empty")
        return v

    @field_validator("max_results")
    @classmethod
    def clamp_results(cls, v: int) -> int:
        return max(1, min(v, 50))


class ProductResult(BaseModel):
    id: str
    name: str
    price: float
    merchant: str
    category: str
    image_url: Optional[str] = None
    description: Optional[str] = None


class MarketplaceSearchResponse(BaseModel):
    results: list[ProductResult]
    query: str
    total: int


# ---------------------------------------------------------------------------
# Mock search — replace with real catalogue / Firecrawl when ready [PLANNED]
# ---------------------------------------------------------------------------

_MOCK_CATALOGUE = [
    {"name": "Wireless Noise-Cancelling Headphones", "price": 79.99,  "merchant": "TechZone",    "category": "Electronics",  "description": "Over-ear Bluetooth headphones, 30hr battery."},
    {"name": "Running Shoes",                        "price": 59.95,  "merchant": "SportsDirect", "category": "Apparel",      "description": "Lightweight mesh upper, cushioned sole."},
    {"name": "Coffee Maker",                         "price": 49.99,  "merchant": "HomeGoods",    "category": "Kitchen",      "description": "12-cup programmable drip coffee maker."},
    {"name": "Yoga Mat",                             "price": 29.99,  "merchant": "FitWorld",     "category": "Sports",       "description": "Non-slip, 6mm thick, with carry strap."},
    {"name": "Portable Charger 20000mAh",            "price": 34.99,  "merchant": "TechZone",     "category": "Electronics",  "description": "Dual USB-A + USB-C, fast charge."},
    {"name": "Backpack",                             "price": 44.99,  "merchant": "UrbanGear",    "category": "Bags",         "description": "Water-resistant, 30L, laptop sleeve."},
    {"name": "Stainless Steel Water Bottle",         "price": 19.99,  "merchant": "EcoLiving",    "category": "Kitchen",      "description": "24oz, vacuum insulated, leak-proof lid."},
    {"name": "Desk Lamp",                            "price": 24.99,  "merchant": "HomeGoods",    "category": "Home",         "description": "LED, 3 colour temperatures, USB charging port."},
    {"name": "Mechanical Keyboard",                  "price": 89.99,  "merchant": "TechZone",     "category": "Electronics",  "description": "Compact TKL, Cherry MX switches, RGB."},
    {"name": "Resistance Bands Set",                 "price": 15.99,  "merchant": "FitWorld",     "category": "Sports",       "description": "5 levels, latex-free, includes carry bag."},
]


def _mock_search(
    query: str,
    max_results: int,
    budget: Optional[float],
) -> list[ProductResult]:
    q = query.lower()
    matches = [
        p for p in _MOCK_CATALOGUE
        if q in p["name"].lower()
        or q in p["category"].lower()
        or q in p["merchant"].lower()
        or q in (p.get("description") or "").lower()
    ]
    if not matches:
        matches = _MOCK_CATALOGUE[:]

    if budget is not None:
        matches = [p for p in matches if p["price"] <= budget]

    return [
        ProductResult(id=str(uuid.uuid4()), **p)
        for p in matches[:max_results]
    ]


# ---------------------------------------------------------------------------
# POST /api/marketplace/search
# ---------------------------------------------------------------------------

@router.post("/marketplace/search", response_model=MarketplaceSearchResponse)
def search_marketplace(request: MarketplaceSearchRequest):
    """
    Search the Chronos marketplace for products.

    Raises:
        HTTPException(422): If query is empty.
    """
    try:
        results = _mock_search(
            query=request.query,
            max_results=request.max_results,
            budget=request.budget,
        )
    except Exception as exc:
        log.error("marketplace_search_failed", user_id=request.user_id, error=str(exc))
        raise HTTPException(status_code=500, detail="Marketplace search failed") from exc

    log.info(
        "marketplace_search",
        user_id=request.user_id,
        query=request.query,
        results_count=len(results),
        budget=request.budget,
    )

    return MarketplaceSearchResponse(
        results=results,
        query=request.query,
        total=len(results),
    )
