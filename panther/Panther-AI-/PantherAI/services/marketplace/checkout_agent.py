"""
services/marketplace/checkout_agent.py
========================================
End-to-end checkout agent. Orchestrates the 3-step AP2-compatible flow
against mock partner APIs, then returns a unified result to Kevin.

[LIVE] checkout — full Cart → BNPL → Confirm flow against a mock partner.

Supported partner_ids:
    mock_nike     → MockNike  (POST /partners/nike/...)
    mock_amazon   → MockAmazon (POST /partners/amazon/...)
    mock_bestbuy  → MockBestBuy (POST /partners/bestbuy/...)

When real AP2 partners go live: swap BASE_URLS[partner_id] — zero agent code changes.

Output schema:
    {
        order_id: str,
        product: str,
        vendor: str,
        partner_id: str,
        bnpl_plan: { plan_id, num_payments, payment_per_installment, total_cost } | None,
        total_cost: float,
        currency: str,
        status: str,     # "confirmed"
    }
"""

from __future__ import annotations

import os
from typing import Any, Dict, Optional

import httpx
from dotenv import load_dotenv

from core.logger import log

load_dotenv()

# ---------------------------------------------------------------------------
# Partner base URLs — swap these when real partners go live
# ---------------------------------------------------------------------------

_DEFAULT_BASE = os.getenv("PANTHER_API_BASE", "http://localhost:8000")

BASE_URLS: Dict[str, str] = {
    "mock_nike":    _DEFAULT_BASE + "/partners/nike",
    "mock_amazon":  _DEFAULT_BASE + "/partners/amazon",
    "mock_bestbuy": _DEFAULT_BASE + "/partners/bestbuy",
}

_TIMEOUT = 10.0

# ---------------------------------------------------------------------------
# Types
# ---------------------------------------------------------------------------

CheckoutResult = Dict[str, Any]
BNPLPlan = Dict[str, Any]


# ---------------------------------------------------------------------------
# HTTP helpers
# ---------------------------------------------------------------------------

def _post(url: str, payload: Dict[str, Any]) -> Dict[str, Any]:
    with httpx.Client(timeout=_TIMEOUT) as client:
        resp = client.post(url, json=payload)
        resp.raise_for_status()
        return resp.json()


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def checkout(
    user_id: str,
    product_name: str,
    product_id: str,
    price: float,
    partner_id: str,
    vendor: str,
    tickpay_token: str,
    num_payments: Optional[int] = None,
) -> CheckoutResult:
    """
    Runs the full 3-step checkout flow against a mock partner.

    Steps:
        1. POST /checkout/cart         — opens cart, gets cart_id
        2. POST /checkout/apply-bnpl   — (if num_payments given) attaches plan
        3. POST /checkout/confirm      — places order, gets order_id

    Args:
        user_id:        TickPay user identifier.
        product_name:   Display name of the product.
        product_id:     Partner SKU / product identifier.
        price:          Unit price.
        partner_id:     One of "mock_nike", "mock_amazon", "mock_bestbuy".
        vendor:         Human-readable vendor name (for the return payload).
        tickpay_token:  User auth token (passed to partner for AP2 compliance).
        num_payments:   If set, BNPL is applied with this many installments.
                        If None, standard one-time payment (no BNPL step).

    Returns:
        CheckoutResult dict with order_id, product, vendor, bnpl_plan, total_cost, status.

    Raises:
        ValueError:  If partner_id is not supported.
        httpx.HTTPStatusError: If any partner API call fails.

    >>> result = checkout(
    ...     user_id="user_sarah",
    ...     product_name="Nike Air Max 270",
    ...     product_id="NIKE-AM270",
    ...     price=149.99,
    ...     partner_id="mock_nike",
    ...     vendor="Nike",
    ...     tickpay_token="demo-token-123456",
    ...     num_payments=3,
    ... )
    >>> result["status"] == "confirmed"
    True
    >>> "order_id" in result
    True
    """
    if partner_id not in BASE_URLS:
        raise ValueError(
            f"Unsupported partner_id '{partner_id}'. "
            f"Supported: {list(BASE_URLS.keys())}"
        )

    base = BASE_URLS[partner_id]
    log.contract(
        "checkout",
        user_id=user_id,
        product_name=product_name,
        partner_id=partner_id,
        price=price,
        num_payments=num_payments,
    )

    # ── Step 1: Cart ─────────────────────────────────────────────────────────
    cart_payload = {
        "user_id": user_id,
        "items": [
            {
                "product_id": product_id,
                "name": product_name,
                "price": price,
                "quantity": 1,
            }
        ],
        "tickpay_token": tickpay_token,
    }

    try:
        cart_resp = _post(f"{base}/checkout/cart", cart_payload)
    except httpx.HTTPStatusError as e:
        log.failure("checkout.cart", error_type="HTTPStatusError", message=str(e), partner_id=partner_id)
        raise

    cart_id: str = cart_resp["cart_id"]
    log.phase("cart_created", f"checkout({partner_id})")

    # ── Step 2: Apply BNPL (optional) ────────────────────────────────────────
    bnpl_plan: Optional[BNPLPlan] = None

    if num_payments is not None:
        bnpl_payload = {
            "cart_id": cart_id,
            "user_id": user_id,
            "num_payments": num_payments,
            "tickpay_token": tickpay_token,
        }

        try:
            bnpl_resp = _post(f"{base}/checkout/apply-bnpl", bnpl_payload)
        except httpx.HTTPStatusError as e:
            log.failure("checkout.bnpl", error_type="HTTPStatusError", message=str(e), cart_id=cart_id)
            raise

        bnpl_plan = {
            "plan_id": bnpl_resp["bnpl_plan_id"],
            "num_payments": bnpl_resp["num_payments"],
            "payment_per_installment": bnpl_resp["payment_per_installment"],
            "total_cost": bnpl_resp["total_cost"],
        }
        log.phase("bnpl_applied", f"checkout({partner_id})")

    # ── Step 3: Confirm ───────────────────────────────────────────────────────
    confirm_payload = {
        "cart_id": cart_id,
        "user_id": user_id,
        "tickpay_token": tickpay_token,
        "bnpl_plan_id": bnpl_plan["plan_id"] if bnpl_plan else None,
    }

    try:
        confirm_resp = _post(f"{base}/checkout/confirm", confirm_payload)
    except httpx.HTTPStatusError as e:
        log.failure("checkout.confirm", error_type="HTTPStatusError", message=str(e), cart_id=cart_id)
        raise

    order_id: str = confirm_resp["order_id"]
    total_cost: float = bnpl_plan["total_cost"] if bnpl_plan else price

    result: CheckoutResult = {
        "order_id": order_id,
        "product": product_name,
        "vendor": vendor,
        "partner_id": partner_id,
        "bnpl_plan": bnpl_plan,
        "total_cost": total_cost,
        "currency": "USD",
        "status": "confirmed",
    }

    log.result(
        "checkout",
        duration_ms=0,
        order_id=order_id,
        user_id=user_id,
        partner_id=partner_id,
        total_cost=total_cost,
    )
    return result
