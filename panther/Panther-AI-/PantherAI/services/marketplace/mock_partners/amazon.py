"""
services/marketplace/mock_partners/amazon.py
=============================================
MockAmazon checkout API. AP2-compatible 3-step flow.

Endpoints:
    POST /partners/amazon/checkout/cart         — add items to cart
    POST /partners/amazon/checkout/apply-bnpl   — attach BNPL plan
    POST /partners/amazon/checkout/confirm      — place order, returns order_id
"""

from __future__ import annotations

import uuid
from typing import Dict, Any

from fastapi import APIRouter, HTTPException

from core.logger import log
from services.marketplace.mock_partners._contract import (
    CartRequest,
    CartResponse,
    BNPLRequest,
    BNPLResponse,
    ConfirmRequest,
    OrderResponse,
    OrderSummary,
    CartItem,
)

router = APIRouter(prefix="/partners/amazon", tags=["MockAmazon"])

PARTNER_NAME = "MockAmazon"

_carts: Dict[str, Dict[str, Any]] = {}

_CATALOG = {
    "AMZN-AIRMAX90": True,
    "AMZN-NIKEREACT": True,
    "AMZN-MBP-M3": True,
    "AMZN-THINKPAD": True,
    "AMZN-SONYXM5": True,
    "AMZN-LENOVO": True,
}


def _validate_token(token: str) -> None:
    if not token or len(token) < 8:
        raise HTTPException(status_code=401, detail="Invalid TickPay token")


def _check_stock(product_id: str) -> None:
    if product_id in _CATALOG and not _CATALOG[product_id]:
        raise HTTPException(status_code=409, detail=f"{product_id} is out of stock")


@router.post("/checkout/cart", response_model=CartResponse)
def create_cart(req: CartRequest) -> CartResponse:
    """Step 1: Add items to cart. Returns cart_id for subsequent steps."""
    _validate_token(req.tickpay_token)

    for item in req.items:
        _check_stock(item.product_id)

    subtotal = round(sum(i.price * i.quantity for i in req.items), 2)
    cart_id = f"amzn-cart-{uuid.uuid4().hex[:12]}"

    _carts[cart_id] = {
        "user_id": req.user_id,
        "items": [i.model_dump() for i in req.items],
        "subtotal": subtotal,
        "bnpl_plan_id": None,
        "num_payments": None,
        "per_installment": None,
    }

    log.result("amazon.create_cart", duration_ms=0, cart_id=cart_id, subtotal=subtotal)
    return CartResponse(
        cart_id=cart_id,
        partner=PARTNER_NAME,
        items=req.items,
        subtotal=subtotal,
    )


@router.post("/checkout/apply-bnpl", response_model=BNPLResponse)
def apply_bnpl(req: BNPLRequest) -> BNPLResponse:
    """Step 2: Apply BNPL installment plan to an open cart."""
    _validate_token(req.tickpay_token)

    cart = _carts.get(req.cart_id)
    if not cart:
        raise HTTPException(status_code=404, detail=f"Cart {req.cart_id} not found")
    if cart["user_id"] != req.user_id:
        raise HTTPException(status_code=403, detail="Cart does not belong to this user")

    subtotal = cart["subtotal"]
    per_installment = round(subtotal / req.num_payments, 2)
    total_cost = round(per_installment * req.num_payments, 2)

    bnpl_plan_id = f"amzn-bnpl-{uuid.uuid4().hex[:10]}"
    cart["bnpl_plan_id"] = bnpl_plan_id
    cart["num_payments"] = req.num_payments
    cart["per_installment"] = per_installment

    log.result(
        "amazon.apply_bnpl",
        duration_ms=0,
        cart_id=req.cart_id,
        bnpl_plan_id=bnpl_plan_id,
        num_payments=req.num_payments,
    )
    return BNPLResponse(
        cart_id=req.cart_id,
        bnpl_plan_id=bnpl_plan_id,
        num_payments=req.num_payments,
        payment_per_installment=per_installment,
        total_cost=total_cost,
    )


@router.post("/checkout/confirm", response_model=OrderResponse)
def confirm_order(req: ConfirmRequest) -> OrderResponse:
    """Step 3: Place the order. Returns order_id and full summary."""
    _validate_token(req.tickpay_token)

    cart = _carts.get(req.cart_id)
    if not cart:
        raise HTTPException(status_code=404, detail=f"Cart {req.cart_id} not found")
    if cart["user_id"] != req.user_id:
        raise HTTPException(status_code=403, detail="Cart does not belong to this user")

    items = [CartItem(**i) for i in cart["items"]]
    order_id = f"amzn-order-{uuid.uuid4().hex[:10]}"

    summary = OrderSummary(
        items=items,
        subtotal=cart["subtotal"],
        bnpl_plan_id=cart.get("bnpl_plan_id"),
        num_payments=cart.get("num_payments"),
        payment_per_installment=cart.get("per_installment"),
        total_cost=cart["subtotal"],
    )

    del _carts[req.cart_id]

    log.result("amazon.confirm_order", duration_ms=0, order_id=order_id, user_id=req.user_id)
    return OrderResponse(
        order_id=order_id,
        partner=PARTNER_NAME,
        user_id=req.user_id,
        summary=summary,
    )
