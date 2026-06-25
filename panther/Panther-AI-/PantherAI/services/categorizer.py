"""
services/categorizer.py
=======================
Thin wrapper around the TC-TransactionClassifier pipeline.

The directory name 'TC-TransactionClassifier' contains a hyphen, which makes
it an invalid Python identifier. This module uses importlib to load it safely,
exposing a single public function for the rest of the codebase.

Usage:
    from services.categorizer import categorize

    result = categorize("STARBUCKS #1234")
    # → {"subcategory": "sub_food_coffee", "confidence": 1.0, "source": "Regex"}
"""

import importlib
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Load TC-TransactionClassifier via importlib (hyphen-safe)
# ---------------------------------------------------------------------------
_CLASSIFIER_DIR = Path(__file__).parent / "TC-TransactionClassifier" / "classifier"

if str(_CLASSIFIER_DIR.parent) not in sys.path:
    sys.path.insert(0, str(_CLASSIFIER_DIR.parent))

_classifier_module = importlib.import_module("classifier.pipeline")
TransactionClassifierPipeline = _classifier_module.TransactionClassifierPipeline
_tier3_module = importlib.import_module("classifier.tier3_queue")

# Singleton — loaded once at module import time
_pipeline: TransactionClassifierPipeline | None = None


def _get_pipeline() -> TransactionClassifierPipeline:
    global _pipeline
    if _pipeline is None:
        _pipeline = TransactionClassifierPipeline()
    return _pipeline


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def categorize(
    merchant_name: str,
    transaction_id: str | None = None,
    user_id: str | None = None,
    queue_tier3: bool = True,
) -> dict:
    """
    Categorizes a transaction by merchant name using the 3-tier pipeline.

    Args:
        merchant_name: Raw merchant string (e.g. "UBER EATS #1234").

    Returns:
        {
            "subcategory": str,   # e.g. "sub_food_delivery"
            "confidence": float,  # 0.0 – 1.0
            "source": str,        # "Regex" | "Model" | "Low Confidence"
        }
    """
    pipeline = _get_pipeline()
    return pipeline.predict(
        merchant_name,
        transaction_id=transaction_id,
        user_id=user_id,
        queue_tier3=queue_tier3,
    )


def enqueue_low_confidence(
    transaction_id: str,
    user_id: str,
    merchant_name: str,
) -> None:
    """Queues a persisted low-confidence transaction for Tier 3 classification."""
    _tier3_module.enqueue_low_confidence_transaction(
        transaction_id=transaction_id,
        user_id=user_id,
        description=merchant_name,
    )
