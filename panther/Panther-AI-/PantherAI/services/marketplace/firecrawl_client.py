"""
services/marketplace/firecrawl_client.py
=========================================
Firecrawl API wrapper for product search and page scraping.

[LIVE] search_products  — queries Firecrawl for products matching a query string.
[LIVE] scrape_product_page — scrapes a product URL into a structured dict.
[LIVE] Mock mode         — activated automatically when FIRECRAWL_API_KEY is absent.

Env vars:
    FIRECRAWL_API_KEY — Firecrawl API key. If unset, mock mode is used.
    FIRECRAWL_BASE_URL — Override API base (default: https://api.firecrawl.dev/v1)
"""

from __future__ import annotations

import os
import re
from typing import Any, Dict, List, Optional

import httpx
from dotenv import load_dotenv

from core.logger import log

load_dotenv()

_API_KEY = os.getenv("FIRECRAWL_API_KEY", "")
_BASE_URL = os.getenv("FIRECRAWL_BASE_URL", "https://api.firecrawl.dev/v1")
_TIMEOUT = 15.0

# ---------------------------------------------------------------------------
# Types
# ---------------------------------------------------------------------------

ProductResult = Dict[str, Any]
# Shape: { name, price, url, vendor, currency, in_stock, image_url }


# ---------------------------------------------------------------------------
# Mock data — returned when FIRECRAWL_API_KEY is absent
# ---------------------------------------------------------------------------

_MOCK_PRODUCTS: List[ProductResult] = [
    {
        "name": "Nike Air Max 270",
        "price": 149.99,
        "url": "https://www.nike.com/t/air-max-270",
        "vendor": "Nike",
        "currency": "USD",
        "in_stock": True,
        "image_url": "https://static.nike.com/airmax270.jpg",
    },
    {
        "name": "Nike Air Max 90",
        "price": 119.99,
        "url": "https://www.amazon.com/dp/B09NIKE90X",
        "vendor": "Amazon",
        "currency": "USD",
        "in_stock": True,
        "image_url": "https://m.media-amazon.com/airmax90.jpg",
    },
    {
        "name": "Nike Air Max 95",
        "price": 174.99,
        "url": "https://www.bestbuy.com/site/nike-air-max-95",
        "vendor": "Best Buy",
        "currency": "USD",
        "in_stock": False,
        "image_url": "https://pisces.bbystatic.com/airmax95.jpg",
    },
    {
        "name": "Nike Air Force 1",
        "price": 109.99,
        "url": "https://www.nike.com/t/air-force-1",
        "vendor": "Nike",
        "currency": "USD",
        "in_stock": True,
        "image_url": "https://static.nike.com/af1.jpg",
    },
    {
        "name": "Nike React Infinity Run",
        "price": 159.99,
        "url": "https://www.amazon.com/dp/B09NIKEREACT",
        "vendor": "Amazon",
        "currency": "USD",
        "in_stock": True,
        "image_url": "https://m.media-amazon.com/nikereact.jpg",
    },
    {
        "name": "Apple MacBook Air M3",
        "price": 1099.00,
        "url": "https://www.apple.com/macbook-air-m3",
        "vendor": "Apple",
        "currency": "USD",
        "in_stock": True,
        "image_url": "https://www.apple.com/macbook-air-m3.jpg",
    },
    {
        "name": "Dell XPS 15 Laptop",
        "price": 899.99,
        "url": "https://www.bestbuy.com/site/dell-xps-15",
        "vendor": "Best Buy",
        "currency": "USD",
        "in_stock": True,
        "image_url": "https://pisces.bbystatic.com/dellxps15.jpg",
    },
    {
        "name": "Lenovo ThinkPad X1 Carbon",
        "price": 979.00,
        "url": "https://www.amazon.com/dp/B09LENOVO",
        "vendor": "Amazon",
        "currency": "USD",
        "in_stock": True,
        "image_url": "https://m.media-amazon.com/thinkpad.jpg",
    },
    {
        "name": "Samsung 65\" 4K QLED TV",
        "price": 799.99,
        "url": "https://www.bestbuy.com/site/samsung-65-qled",
        "vendor": "Best Buy",
        "currency": "USD",
        "in_stock": True,
        "image_url": "https://pisces.bbystatic.com/samsung65.jpg",
    },
    {
        "name": "Sony WH-1000XM5 Headphones",
        "price": 279.99,
        "url": "https://www.amazon.com/dp/B09SONYXM5",
        "vendor": "Amazon",
        "currency": "USD",
        "in_stock": True,
        "image_url": "https://m.media-amazon.com/sonyxm5.jpg",
    },
]


def _mock_search(query: str, max_results: int) -> List[ProductResult]:
    """Filter mock products by keywords in the query. Applies a budget ceiling if detected."""
    query_lower = query.lower()

    # Extract budget from query ("under $200", "below 150", etc.)
    budget_match = re.search(r"(?:under|below|less than|<)\s*\$?(\d+(?:\.\d+)?)", query_lower)
    budget = float(budget_match.group(1)) if budget_match else None

    # Keyword matching — split query into tokens, skip price/budget words
    skip_tokens = {"under", "below", "less", "than", "find", "me", "a", "an", "the", "for"}
    keywords = [t for t in re.split(r"[\s,]+", query_lower) if t and not t.startswith("$") and t not in skip_tokens]

    results = []
    for product in _MOCK_PRODUCTS:
        name_lower = product["name"].lower()
        vendor_lower = product["vendor"].lower()
        if any(kw in name_lower or kw in vendor_lower for kw in keywords):
            if budget is None or product["price"] <= budget:
                results.append(product)

    # If no keyword match, return first max_results (acts as broad search)
    if not results:
        results = _MOCK_PRODUCTS[:max_results]

    return results[:max_results]


def _parse_firecrawl_results(data: Dict[str, Any]) -> List[ProductResult]:
    """Converts Firecrawl search response into our ProductResult shape."""
    results = []
    for item in data.get("data", []):
        metadata = item.get("metadata", {})
        content = item.get("markdown", "") or ""

        # Best-effort price extraction from page content
        price_match = re.search(r"\$(\d+(?:\.\d{2})?)", content)
        price = float(price_match.group(1)) if price_match else 0.0

        results.append(
            {
                "name": metadata.get("title") or metadata.get("ogTitle") or "Unknown Product",
                "price": price,
                "url": metadata.get("sourceURL") or metadata.get("url") or "",
                "vendor": metadata.get("siteName") or _extract_vendor(metadata.get("sourceURL", "")),
                "currency": "USD",
                "in_stock": True,  # Firecrawl doesn't reliably surface stock status
                "image_url": metadata.get("ogImage") or "",
            }
        )
    return results


def _extract_vendor(url: str) -> str:
    """Extracts a display name from a URL hostname."""
    match = re.search(r"(?:www\.)?([^.]+)\.", url)
    return match.group(1).capitalize() if match else "Unknown"


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


def search_products(query: str, max_results: int = 10) -> List[ProductResult]:
    """
    Searches for products matching `query`.

    Returns a list of up to `max_results` products, each with:
        name, price, url, vendor, currency, in_stock, image_url

    Uses mock data when FIRECRAWL_API_KEY is not set.

    >>> results = search_products("Nike Air Max under $200")
    >>> len(results) > 0
    True
    >>> all("price" in p for p in results)
    True
    """
    if not _API_KEY:
        log.phase("mock_mode", "firecrawl_client.search_products")
        return _mock_search(query, max_results)

    try:
        with httpx.Client(timeout=_TIMEOUT) as client:
            response = client.post(
                f"{_BASE_URL}/search",
                headers={"Authorization": f"Bearer {_API_KEY}"},
                json={
                    "query": query,
                    "limit": max_results,
                    "scrapeOptions": {"formats": ["markdown"]},
                },
            )
            response.raise_for_status()
            data = response.json()
            results = _parse_firecrawl_results(data)
            log.result("search_products", duration_ms=0, query=query, count=len(results))
            return results
    except httpx.HTTPStatusError as e:
        log.failure(
            "search_products",
            error_type="HTTPStatusError",
            message=str(e),
            query=query,
        )
        raise
    except Exception as e:
        log.failure("search_products", error_type=type(e).__name__, message=str(e), query=query)
        raise


def scrape_product_page(url: str) -> ProductResult:
    """
    Scrapes a product page URL and returns structured product data.

    Returns a ProductResult dict with name, price, url, vendor, currency, in_stock, image_url.

    Uses a minimal mock response when FIRECRAWL_API_KEY is not set.

    >>> result = scrape_product_page("https://www.nike.com/t/air-max-270")
    >>> "price" in result
    True
    """
    if not _API_KEY:
        log.phase("mock_mode", "firecrawl_client.scrape_product_page")
        # Return a matching mock if URL matches, else a generic stub
        for product in _MOCK_PRODUCTS:
            if product["url"] == url:
                return product
        return {
            "name": "Mock Product",
            "price": 99.99,
            "url": url,
            "vendor": _extract_vendor(url),
            "currency": "USD",
            "in_stock": True,
            "image_url": "",
        }

    try:
        with httpx.Client(timeout=_TIMEOUT) as client:
            response = client.post(
                f"{_BASE_URL}/scrape",
                headers={"Authorization": f"Bearer {_API_KEY}"},
                json={"url": url, "formats": ["markdown"]},
            )
            response.raise_for_status()
            data = response.json()

            metadata = data.get("metadata", {})
            content = data.get("markdown", "") or ""
            price_match = re.search(r"\$(\d+(?:\.\d{2})?)", content)
            price = float(price_match.group(1)) if price_match else 0.0

            result: ProductResult = {
                "name": metadata.get("title") or metadata.get("ogTitle") or "Unknown Product",
                "price": price,
                "url": url,
                "vendor": metadata.get("siteName") or _extract_vendor(url),
                "currency": "USD",
                "in_stock": True,
                "image_url": metadata.get("ogImage") or "",
            }
            log.result("scrape_product_page", duration_ms=0, url=url, name=result["name"])
            return result
    except httpx.HTTPStatusError as e:
        log.failure("scrape_product_page", error_type="HTTPStatusError", message=str(e), url=url)
        raise
    except Exception as e:
        log.failure("scrape_product_page", error_type=type(e).__name__, message=str(e), url=url)
        raise
