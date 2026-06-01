"""
services/marketplace/mock_partners/_contract.py
=================================================
Shared Pydantic models for the AP2-compatible mock partner checkout contract.

All 3 mock partners (Nike, Amazon, BestBuy) share this exact contract.
Real AP2 partners will expose the same 3-step flow: Cart → BNPL → Confirm.
Swapping a mock for a real partner = change the base URL only.

Flow:
    1. POST /checkout/cart         → CartResponse      (cart_id issued)
    2. POST /checkout/apply-bnpl   → BNPLResponse      (plan attached to cart_id)
    3. POST /checkout/confirm      → OrderResponse     (order_id issued, purchase final)
"""

from __future__ import annotations

from typing import List, Optional
from pydantic import BaseModel, Field


# ---------------------------------------------------------------------------
# Step 1 — Cart
# ---------------------------------------------------------------------------


class CartItem(BaseModel):
    product_id: str
    name: str
    price: float
    quantity: int = 1


class CartRequest(BaseModel):
    user_id: str
    items: List[CartItem]
    tickpay_token: str = Field(..., description="TickPay user auth token")


class CartResponse(BaseModel):
    cart_id: str
    partner: str
    items: List[CartItem]
    subtotal: float
    currency: str = "USD"
    status: str = "open"


# ---------------------------------------------------------------------------
# Step 2 — Apply BNPL
# ---------------------------------------------------------------------------


class BNPLRequest(BaseModel):
    cart_id: str
    user_id: str
    num_payments: int = Field(..., ge=1, le=36)
    tickpay_token: str


class BNPLResponse(BaseModel):
    cart_id: str
    bnpl_plan_id: str
    num_payments: int
    payment_per_installment: float
    total_cost: float
    currency: str = "USD"
    status: str = "bnpl_applied"


# ---------------------------------------------------------------------------
# Step 3 — Confirm
# ---------------------------------------------------------------------------


class ConfirmRequest(BaseModel):
    cart_id: str
    user_id: str
    tickpay_token: str
    bnpl_plan_id: Optional[str] = None


class OrderSummary(BaseModel):
    items: List[CartItem]
    subtotal: float
    bnpl_plan_id: Optional[str] = None
    num_payments: Optional[int] = None
    payment_per_installment: Optional[float] = None
    total_cost: float
    currency: str = "USD"


class OrderResponse(BaseModel):
    order_id: str
    partner: str
    user_id: str
    status: str = "confirmed"
    summary: OrderSummary
