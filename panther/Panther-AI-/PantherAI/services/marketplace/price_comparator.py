"""
services/marketplace/price_comparator.py
=========================================
Searches a product name across all mock partners and returns a sorted comparison.

[LIVE] compare_prices — given a product name, returns all vendor offers sorted cheapest first.

Output schema per offer:
    {
        vendor: str,
        partner_id: str,
        price: float,
        bnpl_eligible: bool,
        delivery_days: int,
        stock: bool,
        url: str,
        currency: str,
    }

The response also includes:
    cheapest:       the single cheapest in-stock offer
    best_bnpl:      cheapest offer that is BNPL-eligible (may equal cheapest)
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

from core.logger import log
from services.marketplace.firecrawl_client import search_products, ProductResult

# ---------------------------------------------------------------------------
# Types
# ---------------------------------------------------------------------------

Offer = Dict[str, Any]

ComparisonResult = Dict[str, Any]
# Shape:
#   {
#       query: str,
#       offers: List[Offer],   sorted cheapest first
#       cheapest: Offer | None,
#       best_bnpl: Offer | None,
#   }

# ---------------------------------------------------------------------------
# Vendor metadata — mirrors product_search_agent for consistency
# ---------------------------------------------------------------------------

_VENDOR_META: Dict[str, Dict[str, Any]] = {
    "nike":     {"partner_id": "mock_nike",    "delivery_days": 5},
    "amazon":   {"partner_id": "mock_amazon",  "delivery_days": 2},
    "best buy": {"partner_id": "mock_bestbuy", "delivery_days": 3},
    "bestbuy":  {"partner_id": "mock_bestbuy", "delivery_days": 3},
    "apple":    {"partner_id": "firecrawl",    "delivery_days": 7},
}

_DEFAULT_META = {"partner_id": "firecrawl", "delivery_days": 7}


def _vendor_meta(vendor: str) -> Dict[str, Any]:
    return _VENDOR_META.get(vendor.lower(), _DEFAULT_META)


# ---------------------------------------------------------------------------
# Conversion
# ---------------------------------------------------------------------------

def _to_offer(product: ProductResult) -> Offer:
    meta = _vendor_meta(product.get("vendor", ""))
    return {
        "vendor": product["vendor"],
        "partner_id": meta["partner_id"],
        "price": product["price"],
        "bnpl_eligible": True,      # D4 applies per-user override at runtime
        "delivery_days": meta["delivery_days"],
        "stock": product.get("in_stock", True),
        "url": product["url"],
        "currency": product.get("currency", "USD"),
    }


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def compare_prices(product_name: str, max_results: int = 20) -> ComparisonResult:
    """
    Searches all mock partners for `product_name` and returns sorted price comparison.

    Ranking:
        1. In-stock offers before out-of-stock.
        2. Price ASC within each stock group.

    Args:
        product_name: Product to search, e.g. "Nike Air Max 270".
        max_results:  Max raw results to fetch from Firecrawl before deduplication.

    Returns:
        ComparisonResult with:
            query       — original search string
            offers      — all offers sorted cheapest-in-stock first
            cheapest    — lowest-price in-stock offer (None if all OOS)
            best_bnpl   — lowest-price BNPL-eligible in-stock offer

    >>> result = compare_prices("Nike Air Max")
    >>> "offers" in result
    True
    >>> result["cheapest"] is not None or len(result["offers"]) == 0
    True
    """
    log.contract("compare_prices", product_name=product_name)

    raw: List[ProductResult] = search_products(product_name, max_results=max_results)

    offers: List[Offer] = [_to_offer(p) for p in raw]

    # Sort: in-stock first, then cheapest
    offers.sort(key=lambda o: (not o["stock"], o["price"]))

    in_stock = [o for o in offers if o["stock"]]

    cheapest: Optional[Offer] = in_stock[0] if in_stock else None
    best_bnpl: Optional[Offer] = next(
        (o for o in in_stock if o["bnpl_eligible"]), None
    )

    log.result(
        "compare_prices",
        duration_ms=0,
        product_name=product_name,
        offer_count=len(offers),
        cheapest_price=cheapest["price"] if cheapest else None,
    )

    return {
        "query": product_name,
        "offers": offers,
        "cheapest": cheapest,
        "best_bnpl": best_bnpl,
    }
