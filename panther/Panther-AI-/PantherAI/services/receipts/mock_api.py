"""
services/receipts/mock_api.py
================================
Public API contract for receipt/line-item data — the Veryfi counterpart to
services/banking/mock_api.py's Plaid contract. Only these functions should
be imported by callers (currently services/financial_advisor/full_picture.py
and routers/receipts/router.py).

DATA SOURCE PRIORITY:
  get_receipts():
    1. Supabase `receipts` table — populated by process_receipt_document()
       once a real or mock OCR extraction has run for that user.
    2. Local mock — fallback for offline dev / no Supabase configured.

  process_receipt_document():
    1. Veryfi API — if VERYFI_* env vars are set (see veryfi_client.py).
    2. Mock OCR — deterministic sample extraction, so the upload -> extract
       -> itemize pipeline is fully testable before Veryfi credentials exist.

Line items are the whole point of this module: a Plaid transaction says
"$129.99 at AMAZON, category Electronics". A receipt says the same $129.99
was actually a phone case, a desk lamp, a book, and $49.99 of protein
powder — detail Plaid structurally cannot provide. See
services/financial_advisor/full_picture.py for how the two get merged.
"""

from __future__ import annotations

import os
import uuid
from datetime import date, timedelta
from typing import Any, Dict, List, Optional

from dotenv import load_dotenv

from core.logger import log

load_dotenv()

# ---------------------------------------------------------------------------
# LOCAL FALLBACK DATA
# Dates are computed relative to today, same convention as
# services/banking/mock_api.py, so receipts line up against the mock
# transactions those same demo users already have (see _d there).
# ---------------------------------------------------------------------------
_TODAY = date.today()


def _d(days_ago: int) -> str:
    return (_TODAY - timedelta(days=days_ago)).isoformat()


LOCAL_MOCK_RECEIPTS: Dict[str, List[Dict[str, Any]]] = {
    "user_marcus": [
        {
            "id": "rcpt_m001",
            "merchant": "WHOLE FOODS",
            "date": _d(1),
            "total": 87.40,
            "category": "Groceries",
            "source": "mock",
            "line_items": [
                {"description": "Organic Bananas", "quantity": 1, "unit_price": 4.50, "total": 4.50},
                {"description": "Sourdough Bread", "quantity": 1, "unit_price": 5.20, "total": 5.20},
                {"description": "Chicken Breast", "quantity": 1, "unit_price": 12.99, "total": 12.99},
                {"description": "Red Wine", "quantity": 1, "unit_price": 18.00, "total": 18.00},
                {"description": "Paper Towels", "quantity": 1, "unit_price": 9.80, "total": 9.80},
                {"description": "Almond Milk", "quantity": 1, "unit_price": 4.20, "total": 4.20},
                {"description": "Mixed Vegetables", "quantity": 1, "unit_price": 11.30, "total": 11.30},
                {"description": "Olive Oil", "quantity": 1, "unit_price": 12.41, "total": 12.41},
                {"description": "Sales Tax", "quantity": 1, "unit_price": 9.00, "total": 9.00},
            ],
        },
        {
            "id": "rcpt_m002",
            "merchant": "AMAZON",
            "date": _d(11),
            "total": 129.99,
            "category": "Shopping",
            "source": "mock",
            "line_items": [
                {"description": "Phone Case", "quantity": 1, "unit_price": 19.99, "total": 19.99},
                {"description": "Desk Lamp", "quantity": 1, "unit_price": 34.99, "total": 34.99},
                {"description": "Book: Atomic Habits", "quantity": 1, "unit_price": 14.99, "total": 14.99},
                {"description": "Protein Powder", "quantity": 1, "unit_price": 49.99, "total": 49.99},
                {"description": "Sales Tax", "quantity": 1, "unit_price": 10.03, "total": 10.03},
            ],
        },
        {
            "id": "rcpt_m003",
            "merchant": "BEST BUY",
            "date": _d(6),
            "total": 249.99,
            "category": "Electronics",
            "source": "mock",
            "line_items": [
                {"description": "USB-C Cable", "quantity": 1, "unit_price": 24.99, "total": 24.99},
                {"description": "Wireless Mouse", "quantity": 1, "unit_price": 39.99, "total": 39.99},
                {"description": "External SSD 1TB", "quantity": 1, "unit_price": 149.99, "total": 149.99},
                {"description": "Sales Tax", "quantity": 1, "unit_price": 35.02, "total": 35.02},
            ],
        },
    ],
    "user_sarah": [
        {
            "id": "rcpt_s001",
            "merchant": "TARGET",
            "date": _d(12),
            "total": 82.40,
            "category": "Shopping",
            "source": "mock",
            "line_items": [
                {"description": "Bath Towels", "quantity": 1, "unit_price": 24.99, "total": 24.99},
                {"description": "Yoga Mat", "quantity": 1, "unit_price": 19.99, "total": 19.99},
                {"description": "Snacks", "quantity": 1, "unit_price": 12.42, "total": 12.42},
                {"description": "Vitamin C Gummies", "quantity": 1, "unit_price": 20.00, "total": 20.00},
                {"description": "Sales Tax", "quantity": 1, "unit_price": 5.00, "total": 5.00},
            ],
        },
    ],
    "user_bob": [
        {
            "id": "rcpt_b001",
            "merchant": "WALMART",
            "date": _d(12),
            "total": 156.80,
            "category": "Shopping",
            "source": "mock",
            "line_items": [
                {"description": "Groceries Bundle", "quantity": 1, "unit_price": 98.40, "total": 98.40},
                {"description": "Motor Oil", "quantity": 1, "unit_price": 22.40, "total": 22.40},
                {"description": "DraftKings Gift Card", "quantity": 1, "unit_price": 28.00, "total": 28.00},
                {"description": "Sales Tax", "quantity": 1, "unit_price": 8.00, "total": 8.00},
            ],
        },
    ],
}

# Generic samples returned by process_receipt_document() when Veryfi isn't
# configured, so the upload endpoint is testable without real OCR credentials.
_MOCK_OCR_SAMPLES: List[Dict[str, Any]] = [
    {
        "merchant": "TRADER JOE'S",
        "total": 42.18,
        "category": "Groceries",
        "line_items": [
            {"description": "Frozen Dumplings", "quantity": 2, "unit_price": 4.99, "total": 9.98},
            {"description": "Sparkling Water 12pk", "quantity": 1, "unit_price": 6.99, "total": 6.99},
            {"description": "Trail Mix", "quantity": 1, "unit_price": 7.49, "total": 7.49},
            {"description": "Rotisserie Chicken", "quantity": 1, "unit_price": 14.99, "total": 14.99},
            {"description": "Sales Tax", "quantity": 1, "unit_price": 2.73, "total": 2.73},
        ],
    },
    {
        "merchant": "CVS PHARMACY",
        "total": 36.47,
        "category": "Medical & Pharmacy",
        "line_items": [
            {"description": "Ibuprofen 200mg", "quantity": 1, "unit_price": 8.99, "total": 8.99},
            {"description": "Multivitamin", "quantity": 1, "unit_price": 15.99, "total": 15.99},
            {"description": "Bandages", "quantity": 1, "unit_price": 4.49, "total": 4.49},
            {"description": "Sales Tax", "quantity": 1, "unit_price": 2.00, "total": 2.00},
            {"description": "Loyalty Discount", "quantity": 1, "unit_price": -5.00, "total": -5.00},
        ],
    },
]


# ---------------------------------------------------------------------------
# Supabase client (lazy) — mirrors services/banking/mock_api.py
# ---------------------------------------------------------------------------
_supabase_client = None


def _get_supabase():
    global _supabase_client
    if _supabase_client is not None:
        return _supabase_client
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    if not url or not key:
        return None
    try:
        from supabase import create_client

        _supabase_client = create_client(url, key)
        return _supabase_client
    except ImportError:
        return None


# ===========================================================================
# PUBLIC API
# ===========================================================================


def get_receipts(user_id: str, days_back: int = 90) -> List[Dict[str, Any]]:
    """
    Returns processed receipts (with line items) for the user, newest first.

    Source priority: Supabase `receipts` table -> local mock.

    Return format:
        [{"id": str, "merchant": str, "date": "YYYY-MM-DD", "total": float,
          "category": str, "source": "veryfi"|"mock",
          "line_items": [{"description": str, "quantity": float,
                           "unit_price": float, "total": float}, ...]}, ...]

    Raises:
        ValueError: Unknown user_id (no Supabase rows and no local mock entry).
    """
    cutoff = str(date.today() - timedelta(days=days_back))

    sb = _get_supabase()
    if sb:
        try:
            res = (
                sb.table("receipts")
                .select("*")
                .eq("user_id", user_id)
                .gte("date", cutoff)
                .order("date", desc=True)
                .execute()
            )
            if res.data:
                return res.data
        except Exception as e:
            log.failure(
                "get_receipts",
                error_type=type(e).__name__,
                message=str(e),
                user_id=user_id,
                detail="Supabase query failed, falling back to local mock",
            )

    if user_id not in LOCAL_MOCK_RECEIPTS:
        raise ValueError(f"Unknown user: {user_id}")

    receipts = LOCAL_MOCK_RECEIPTS[user_id]
    filtered = [r for r in receipts if r["date"] >= cutoff]
    return sorted(filtered, key=lambda r: r["date"], reverse=True)


def process_receipt_document(
    user_id: str,
    filename: str,
    file_bytes: Optional[bytes] = None,
) -> Dict[str, Any]:
    """
    Extracts merchant, total, category, and line items from a receipt image
    or PDF.

    Source priority: Veryfi API (if configured and file_bytes provided) ->
    deterministic mock OCR sample. Either way the result is normalized to
    the same shape as get_receipts() entries and — when Supabase is
    configured — persisted so it shows up on the next get_receipts() call.

    Args:
        user_id: Owner of the receipt.
        filename: Original filename, used for the mock-OCR selection and
            for Veryfi's document upload call.
        file_bytes: Raw file content. Required for a real Veryfi call;
            optional in mock mode (omit it to dry-run the pipeline).

    Returns:
        dict: Same shape as one get_receipts() entry.
    """
    from services.receipts.veryfi_client import get_veryfi_client, is_veryfi_configured

    if is_veryfi_configured() and file_bytes is not None:
        try:
            client = get_veryfi_client()
            # NOTE: verify this call against the installed veryfi SDK version
            # once real credentials are available — falls back to mock OCR
            # on any exception, so a signature mismatch degrades rather than
            # breaking the endpoint, but it should be exercised for real.
            doc = client.process_document_from_file(filename, file_bytes)
            receipt = _normalize_veryfi_document(doc)
        except Exception as e:
            log.failure(
                "process_receipt_document",
                error_type=type(e).__name__,
                message=str(e),
                user_id=user_id,
                detail="Veryfi API failed, falling back to mock OCR",
            )
            receipt = _mock_ocr_extract(filename)
    else:
        receipt = _mock_ocr_extract(filename)

    receipt["id"] = f"rcpt_{uuid.uuid4().hex[:10]}"
    receipt.setdefault("date", date.today().isoformat())

    sb = _get_supabase()
    if sb:
        try:
            sb.table("receipts").upsert({**receipt, "user_id": user_id}).execute()
        except Exception as e:
            log.failure(
                "process_receipt_document",
                error_type=type(e).__name__,
                message=str(e),
                user_id=user_id,
                detail="Supabase upsert failed — receipt returned but not persisted",
            )

    return receipt


def _mock_ocr_extract(filename: str) -> Dict[str, Any]:
    """Deterministic (filename-hash-based) pick from _MOCK_OCR_SAMPLES."""
    sample = _MOCK_OCR_SAMPLES[hash(filename) % len(_MOCK_OCR_SAMPLES)]
    return {**sample, "line_items": [dict(li) for li in sample["line_items"]], "source": "mock"}


def _normalize_veryfi_document(doc: Dict[str, Any]) -> Dict[str, Any]:
    """Maps a raw Veryfi API response onto our receipt/line-item schema."""
    line_items = [
        {
            "description": li.get("description", "Item"),
            "quantity": float(li.get("quantity") or 1),
            "unit_price": float(li.get("price") or li.get("total") or 0.0),
            "total": float(li.get("total") or 0.0),
        }
        for li in doc.get("line_items", [])
    ]
    return {
        "merchant": doc.get("vendor", {}).get("name") or "Unknown",
        "date": (doc.get("date") or date.today().isoformat())[:10],
        "total": float(doc.get("total") or 0.0),
        "category": doc.get("category") or "Uncategorized",
        "source": "veryfi",
        "line_items": line_items,
    }
