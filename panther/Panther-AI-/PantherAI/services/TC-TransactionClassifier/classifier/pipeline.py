import os
import logging
from typing import TypedDict, Optional

from .tier1_regex import RegexClassifier
from .tier0_cache import get_cached, set_cached
from .tier3_queue import enqueue_low_confidence_transaction

try:
    from .tier2_bert import BertClassifier
except ImportError as e:
    # Log warning but allow pipeline to load without Tier 2
    logging.getLogger("TransactionClassifierPipeline").warning(
        f"Could not import BertClassifier: {e}. Tier 2 disabled."
    )
    BertClassifier = None

# Setup basic logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("TransactionClassifierPipeline")


class PredictionResult(TypedDict):
    subcategory: str
    confidence: float
    source: str  # "Regex" | "Model" | "Low Confidence"


def is_confident(probabilities: list[float], margin_threshold: float = 0.3) -> bool:
    """
    Accept a model prediction only when top-1 clearly beats top-2.
    """
    if len(probabilities) < 2:
        return False
    sorted_probs = sorted((float(prob) for prob in probabilities), reverse=True)
    margin = sorted_probs[0] - sorted_probs[1]
    return margin > margin_threshold


class TransactionClassifierPipeline:
    """
    4-Tier Waterfall Pipeline for Transaction Classification.
    Tier 0: Cache (fast path)
    Tier 1: Regex (Precision focus)
    Tier 2: DistilBERT (Semantic focus)
    Tier 3: Claude async fallback for low-confidence model results
    """

    def __init__(
        self,
        model_path: Optional[str] = None,
        confidence_threshold: float = 0.6,
        margin_threshold: float = 0.3,
        tier1: Optional[RegexClassifier] = None,
        tier2: Optional[BertClassifier] = None,
    ):
        """
        Initializes the pipeline tiers.
        """
        logger.info("Initializing TransactionClassifierPipeline...")

        # Tier 1: Regex
        self.tier1 = tier1 or RegexClassifier()

        # Tier 2: DistilBERT
        if tier2:
            self.tier2 = tier2
        elif BertClassifier:
            # Hardening check: use environment variable or passed path
            final_model_path = model_path or os.getenv("PANTHER_MODEL_PATH")
            try:
                self.tier2 = BertClassifier(model_path=final_model_path)
            except Exception as e:
                self.tier2 = None
                logger.warning("Tier 2 (BERT) load failed: %s", e)
        else:
            self.tier2 = None
            logger.warning("Tier 2 (BERT) not available.")

        self.confidence_threshold = confidence_threshold
        self.margin_threshold = margin_threshold
        logger.info(
            "Pipeline initialized. Margin threshold: %.2f", self.margin_threshold
        )

    def predict(
        self,
        text: str,
        transaction_id: str | None = None,
        user_id: str | None = None,
        queue_tier3: bool = True,
    ) -> PredictionResult:
        """
        Executes the waterfall classification logic.
        """
        if not text or not text.strip():
            return {
                "subcategory": "sub_general_misc",
                "confidence": 0.0,
                "source": "Empty Input",
            }

        # --- Tier 0: Cache ---
        cached = get_cached(text)
        if cached:
            return cached

        # --- Tier 1: Regex ---
        regex_match = self.tier1.classify(text)
        if regex_match:
            sub_id, conf = regex_match
            logger.debug(f"Tier 1 match: {text} -> {sub_id}")
            result = {"subcategory": sub_id, "confidence": conf, "source": "Regex"}
            set_cached(text, result)
            return result

        # --- Tier 2: DistilBERT ---
        if not self.tier2:
            return {
                "subcategory": "sub_general_misc",
                "confidence": 0.0,
                "source": "Tier 2 Unavailable",
            }

        model_sub, model_conf, probabilities = self._tier2_predict(text)

        if is_confident(probabilities, self.margin_threshold):
            logger.debug(
                f"Tier 2 match: {text} -> {model_sub} (conf: {model_conf:.4f})"
            )
            result = {
                "subcategory": model_sub,
                "confidence": model_conf,
                "source": "Model",
            }
            set_cached(text, result)
            return result
        else:
            logger.info(
                f"Low confidence prediction for '{text}': {model_sub} ({model_conf:.4f})"
            )
            if queue_tier3 and transaction_id and user_id:
                enqueue_low_confidence_transaction(
                    transaction_id=transaction_id,
                    user_id=user_id,
                    description=text,
                )
            return {
                "subcategory": model_sub,
                "confidence": model_conf,
                "source": "Low Confidence",
            }

    def _tier2_predict(self, text: str) -> tuple[str, float, list[float]]:
        method = getattr(self.tier2, "classify_with_probabilities", None)
        if callable(method):
            prediction = method(text)
            if isinstance(prediction, tuple) and len(prediction) == 3:
                return prediction
        model_sub, model_conf = self.tier2.classify(text)
        return model_sub, model_conf, [model_conf, 1.0 - model_conf]


if __name__ == "__main__":
    # Diagnostic test if run directly
    pipeline = TransactionClassifierPipeline()
    test_cases = [
        "UBER EATS #1234",  # Match Regex (likely)
        "WALMART STORE",  # Match Regex (likely)
        "UNKNOWN CAFE BISTRO",  # BERT territory
        "12345 67890",  # Low confidence territory
    ]

    print("\n--- Pipeline Diagnostic Test ---\n")
    for tc in test_cases:
        res = pipeline.predict(tc)
        print(f"Input: {tc}")
        print(
            f"Result: {res['subcategory']} | Conf: {res['confidence']:.4f} | Source: {res['source']}\n"
        )
