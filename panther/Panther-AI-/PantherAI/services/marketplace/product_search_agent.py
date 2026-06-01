"""
services/marketplace/product_search_agent.py
=============================================
Parses user intent → queries Firecrawl → returns ranked product list.

[LIVE] parse_and_search  — main entry point. Natural language → ranked products.
[LIVE] rank_products     — sorts by price ASC, then BNPL eligibility, then delivery speed.

Output schema per product:
    {
        name: str,
        vendor: str,
        price: float,
        url: str,
        stock: bool,
        bnpl_eligible: bool,      # always True here; D4 applies per-user scoring
        partner_id: str,          # "mock_nike" | "mock_amazon" | "mock_bestbuy" | "firecrawl"
        delivery_days: int,
        currency: str,
        image_url: str,
    }
"""

from __future__ import annotations

import re
from typing import Any, Dict, List, Optional

from core.logger import log
from services.marketplace.firecrawl_client import search_products, ProductResult

# ---------------------------------------------------------------------------
# Types
# ---------------------------------------------------------------------------

SearchResult = Dict[str, Any]
# Full shape documented in module docstring above.

# ---------------------------------------------------------------------------
# Vendor → partner_id + delivery_days map
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
# Intent parser
# ---------------------------------------------------------------------------

_BUDGET_PATTERN = re.compile(
    r"(?:under|below|less\s+than|max|<)\s*\$?(\d+(?:\.\d+)?)", re.IGNORECASE
)


def _extract_budget(query: str) -> Optional[float]:
    m = _BUDGET_PATTERN.search(query)
    return float(m.group(1)) if m else None


# ---------------------------------------------------------------------------
# Ranking
# ---------------------------------------------------------------------------

def rank_products(products: List[SearchResult]) -> List[SearchResult]:
    """
    Ranks products by:
        1. price ASC          (cheapest first)
        2. bnpl_eligible DESC (BNPL-eligible before non-eligible)
        3. delivery_days ASC  (faster delivery preferred)
    """
    return sorted(
        products,
        key=lambda p: (p["price"], not p["bnpl_eligible"], p["delivery_days"]),
    )


# ---------------------------------------------------------------------------
# Conversion helpers
# ---------------------------------------------------------------------------

def _to_search_result(product: ProductResult) -> SearchResult:
    meta = _vendor_meta(product.get("vendor", ""))
    return {
        "name": product["name"],
        "vendor": product["vendor"],
        "price": product["price"],
        "url": product["url"],
        "stock": product.get("in_stock", True),
        "bnpl_eligible": True,   # D4 will override with per-user scoring
        "partner_id": meta["partner_id"],
        "delivery_days": meta["delivery_days"],
        "currency": product.get("currency", "USD"),
        "image_url": product.get("image_url", ""),
    }


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def parse_and_search(query: str, max_results: int = 10) -> List[SearchResult]:
    """
    Parses a natural-language product query and returns ranked results.

    Steps:
        1. Extract budget ceiling from query (if present).
        2. Call Firecrawl (or mock) for raw product list.
        3. Filter out-of-stock and over-budget products.
        4. Rank: price ASC → BNPL eligible first → delivery speed ASC.

    Args:
        query:       Natural language search, e.g. "Nike Air Max under $200".
        max_results: Maximum products to return after ranking.

    Returns:
        List of SearchResult dicts, ranked best-first.

    >>> results = parse_and_search("Nike Air Max under $200")
    >>> len(results) > 0
    True
    >>> results[0]["price"] <= results[-1]["price"]
    True
    """
    log.contract("parse_and_search", query=query, max_results=max_results)

    budget = _extract_budget(query)

    raw: List[ProductResult] = search_products(query, max_results=max_results * 2)

    filtered: List[SearchResult] = []
    for product in raw:
        # Skip out-of-stock
        if not product.get("in_stock", True):
            continue
        # Skip over-budget (if budget specified)
        if budget is not None and product["price"] > budget:
            continue
        filtered.append(_to_search_result(product))

    ranked = rank_products(filtered)[:max_results]

    log.result(
        "parse_and_search",
        duration_ms=0,
        query=query,
        budget=budget,
        raw_count=len(raw),
        returned=len(ranked),
    )
    return ranked
