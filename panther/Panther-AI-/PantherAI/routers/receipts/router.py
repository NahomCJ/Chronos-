"""
routers/receipts/router.py
=============================
Receipt OCR + line-item itemization API (Veryfi). This is the piece Plaid
can't provide on its own: Plaid gives a merchant-level charge, Veryfi gives
the priced line items behind it.

GET  /api/receipts          — list a user's processed receipts
POST /api/receipts/process  — upload a receipt image/PDF, get back extracted
                               line items (falls back to mock OCR if Veryfi
                               isn't configured — see services/receipts/mock_api.py)

Both endpoints work fully today against mock data. Once VERYFI_* env vars
are set (see .env.example), /process starts calling the real API — no route
or response-shape changes needed on the frontend.
"""

from __future__ import annotations

import base64

from fastapi import APIRouter, HTTPException, Query

from routers.receipts.models import ProcessReceiptRequest, Receipt, ReceiptsListResponse
from services.receipts.mock_api import get_receipts, process_receipt_document

router = APIRouter(prefix="/receipts", tags=["receipts"])


@router.get("", response_model=ReceiptsListResponse)
def list_receipts(
    user_id: str = Query(..., pattern=r"^[a-z0-9_]{3,50}$", description="User identifier (e.g. 'user_marcus')"),
    days_back: int = Query(90, ge=1, le=365, description="Lookback window in days"),
):
    """Returns a user's processed receipts, newest first, with full line-item detail."""
    try:
        return {"user_id": user_id, "receipts": get_receipts(user_id, days_back=days_back)}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/process", response_model=Receipt)
def process_receipt(payload: ProcessReceiptRequest):
    """
    Extracts merchant, total, category, and line items from an uploaded
    receipt. Uses the real Veryfi API when configured and file_base64 is
    supplied; otherwise returns a deterministic mock extraction so the
    upload -> itemize -> analyze flow is testable end-to-end today.
    """
    file_bytes = base64.b64decode(payload.file_base64) if payload.file_base64 else None
    return process_receipt_document(payload.user_id, payload.filename, file_bytes=file_bytes)
