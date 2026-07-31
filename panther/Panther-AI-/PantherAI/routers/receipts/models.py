"""
routers/receipts/models.py
=============================
Pydantic request/response models for the Receipts API (Veryfi OCR +
line-item itemization).
"""

from __future__ import annotations

from typing import Literal, Optional

from pydantic import BaseModel, Field


class LineItem(BaseModel):
    description: str
    quantity: float = 1
    unit_price: float
    total: float


class Receipt(BaseModel):
    id: str
    merchant: str
    date: str
    total: float
    category: str
    source: Literal["veryfi", "mock"]
    line_items: list[LineItem] = Field(default_factory=list)


class ReceiptsListResponse(BaseModel):
    user_id: str
    receipts: list[Receipt]


class ProcessReceiptRequest(BaseModel):
    user_id: str
    filename: str = Field(..., description="Original filename of the uploaded receipt image/PDF.")
    file_base64: Optional[str] = Field(
        None,
        description=(
            "Base64-encoded file bytes. Omit to dry-run the pipeline against "
            "mock OCR output without a real Veryfi call."
        ),
    )
