"""
services/marketplace/bnpl_filter.py
=====================================
Tags each product from D3 with per-user BNPL eligibility using the existing
calculate_bnpl_risk_score() service. Filters out HIGH-risk results.

[LIVE] apply_bnpl_filter — takes D3 results + user_id, returns tagged + filtered list.

Adds to each product:
    bnpl_eligible:         bool   — False if risk is HIGH
    max_safe_installments: int    — largest num_payments that scores < HIGH risk
    risk_score:            int    — raw score from calculate_bnpl_risk_score()
"""

from __future__ import annotations

from typing import Any, Dict, List

from core.logger import log
from services.marketplace.product_search_agent import SearchResult
from services.bnpl_risk_scoring.bnpl_risk_scoring import calculate_bnpl_risk_score

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

_DEFAULT_INSTALLMENTS = 3       # Baseline installment count for eligibility check
_MAX_INSTALLMENT_OPTIONS = [2, 3, 4, 6, 12]   # Plans we probe to find max safe


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _find_max_safe_installments(user_id: str, amount: float) -> int:
    """
    Returns the largest num_payments option from _MAX_INSTALLMENT_OPTIONS
    that does NOT produce a HIGH risk score. Returns 0 if none are safe.
    """
    safe = 0
    for n in _MAX_INSTALLMENT_OPTIONS:
        try:
            result = calculate_bnpl_risk_score(user_id, amount, n)
            if result["risk_level"] != "HIGH":
                safe = n
        except Exception:
            # If BNPL scoring fails for a plan count, skip it conservatively
            continue
    return safe


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def apply_bnpl_filter(
    products: List[SearchResult],
    user_id: str,
    num_payments: int = _DEFAULT_INSTALLMENTS,
) -> List[SearchResult]:
    """
    Tags each product with per-user BNPL eligibility and filters HIGH-risk results.

    For each product:
        1. Calls calculate_bnpl_risk_score(user_id, price, num_payments).
        2. Tags: bnpl_eligible, max_safe_installments, risk_score.
        3. Removes products where risk_level == "HIGH".

    Args:
        products:     List of SearchResult from parse_and_search().
        user_id:      User to score against (e.g. "user_marcus").
        num_payments: Default installment count used for the eligibility check.

    Returns:
        Filtered list with BNPL tags added. HIGH-risk products are excluded.

    >>> from services.marketplace.product_search_agent import parse_and_search
    >>> results = parse_and_search("Nike Air Max under $200")
    >>> tagged = apply_bnpl_filter(results, "user_sarah")
    >>> all("risk_score" in p for p in tagged)
    True
    """
    log.contract("apply_bnpl_filter", user_id=user_id, product_count=len(products), num_payments=num_payments)

    tagged: List[SearchResult] = []

    for product in products:
        price = product["price"]

        try:
            score_result = calculate_bnpl_risk_score(user_id, price, num_payments)
            risk_level = score_result["risk_level"]
            risk_score = score_result["score"]
        except Exception as e:
            log.failure(
                "apply_bnpl_filter",
                error_type=type(e).__name__,
                message=str(e),
                user_id=user_id,
                product=product["name"],
            )
            # Conservative: treat scoring failure as HIGH risk
            tagged_product = {**product, "bnpl_eligible": False, "max_safe_installments": 0, "risk_score": 100}
            continue

        is_eligible = risk_level != "HIGH"
        max_safe = _find_max_safe_installments(user_id, price) if is_eligible else 0

        if not is_eligible:
            continue

        tagged_product: SearchResult = {
            **product,
            "bnpl_eligible": True,
            "max_safe_installments": max_safe,
            "risk_score": risk_score,
        }
        tagged.append(tagged_product)

    log.result(
        "apply_bnpl_filter",
        duration_ms=0,
        user_id=user_id,
        input_count=len(products),
        eligible_count=len(tagged),
        filtered_count=len(products) - len(tagged),
    )
    return tagged
