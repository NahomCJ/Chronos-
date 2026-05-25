import os
import logging
from typing import TypedDict, Optional

# Relative imports
# Relative imports
from .tier1_regex import RegexClassifier

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


class TransactionClassifierPipeline:
    """
    3-Tier Waterfall Pipeline for Transaction Classification.
    Tier 1: Regex (Precision focus)
    Tier 2: DistilBERT (Semantic focus)
    Tier 3: LLM (Future Fallback)
    """

    def __init__(
        self,
        model_path: Optional[str] = None,
        confidence_threshold: float = 0.6,
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
            self.tier2 = BertClassifier(model_path=final_model_path)
        else:
            self.tier2 = None
            logger.warning("Tier 2 (BERT) not available.")

        self.confidence_threshold = confidence_threshold
        logger.info(f"Pipeline initialized. Threshold: {self.confidence_threshold}")

    def predict(self, text: str) -> PredictionResult:
        """
        Executes the waterfall classification logic.
        """
        if not text or not text.strip():
            return {
                "subcategory": "sub_general_misc",
                "confidence": 0.0,
                "source": "Empty Input",
            }

        # --- Tier 1: Regex ---
        regex_match = self.tier1.classify(text)
        if regex_match:
            sub_id, conf = regex_match
            logger.debug(f"Tier 1 match: {text} -> {sub_id}")
            return {"subcategory": sub_id, "confidence": conf, "source": "Regex"}

        # --- Tier 2: DistilBERT ---
        if not self.tier2:
            return {
                "subcategory": "sub_general_misc",
                "confidence": 0.0,
                "source": "Tier 2 Unavailable",
            }

        model_sub, model_conf = self.tier2.classify(text)

        if model_conf >= self.confidence_threshold:
            logger.debug(
                f"Tier 2 match: {text} -> {model_sub} (conf: {model_conf:.4f})"
            )
            return {
                "subcategory": model_sub,
                "confidence": model_conf,
                "source": "Model",
            }
        else:
            logger.info(
                f"Low confidence prediction for '{text}': {model_sub} ({model_conf:.4f})"
            )
            return {
                "subcategory": model_sub,
                "confidence": model_conf,
                "source": "Low Confidence",
            }


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
