import os
import re
import torch
import logging
from transformers import DistilBertTokenizerFast, DistilBertForSequenceClassification

# Setup logger
logger = logging.getLogger("BertClassifier")


class BertClassifier:
    """
    Tier 2 Transaction Classifier using a fine-tuned DistilBERT model.
    Provides semantic classification for transactions missed by Regex.
    """

    def __init__(self, model_path: str = None):
        """
        Initializes the classifier by loading the model and tokenizer.
        """
        if model_path is None:
            # Check environment variable first, then fallback to default
            model_path = os.getenv("PANTHER_MODEL_PATH")
            if model_path:
                logger.info(f"Using model path from environment: {model_path}")
            else:
                base_dir = os.path.dirname(os.path.abspath(__file__))
                # Go up one level to find 'models'
                model_path = os.path.join(
                    base_dir, "..", "models", "distilbert_v1_colab"
                )
                logger.info(f"Using default model path: {model_path}")

        logger.info(f"Loading DistilBERT model from {model_path}...")

        try:
            self.tokenizer = DistilBertTokenizerFast.from_pretrained(model_path)
            self.model = DistilBertForSequenceClassification.from_pretrained(model_path)

            # Device detection
            if torch.backends.mps.is_available():
                self.device = torch.device("mps")
            elif torch.cuda.is_available():
                self.device = torch.device("cuda")
            else:
                self.device = torch.device("cpu")

            self.model.to(self.device).eval()
            logger.info(f"Model loaded successfully on {self.device}")

            # Map IDs to labels from config
            self.id2label = self.model.config.id2label

        except Exception as e:
            logger.error(f"Error loading model: {e}", exc_info=True)
            raise

    def _normalize_text(self, text: str) -> str:
        """
        Normalizes transaction text to match training preprocessing.
        """
        text = str(text).upper()
        # Remove hashtags followed by non-whitespace (e.g., #1234, #Store5)
        text = re.sub(r"#\S+", "", text)
        # Remove TXN followed by non-whitespace
        text = re.sub(r"TXN\S+", "", text)
        # Replace sequences of digits with a single space
        text = re.sub(r"\d+", " ", text)
        # Replace multiple spaces with single space and strip
        text = re.sub(r"\s+", " ", text).strip()
        return text

    def classify(self, text: str) -> tuple[str, float]:
        """
        Classifies a single transaction description.
        Returns: (subcategory_id, confidence_score)
        """
        if not text or not str(text).strip():
            return "sub_general_misc", 0.0

        try:
            clean_text = self._normalize_text(text)

            # Tokenize
            inputs = self.tokenizer(
                clean_text,
                return_tensors="pt",
                padding=True,
                truncation=True,
                max_length=64,
            ).to(self.device)

            # Inference
            with torch.no_grad():
                outputs = self.model(**inputs)
                logits = outputs.logits

                # Apply Softmax for confidence
                probs = torch.nn.functional.softmax(logits, dim=-1)
                conf, pred_id = torch.max(probs, dim=1)

                # Result
                label_id = pred_id.item()
                subcategory = self.id2label.get(label_id, "sub_general_misc")
                confidence = conf.item()

                return subcategory, confidence

        except Exception as e:
            logger.error(f"Classification error for text '{text}': {e}", exc_info=True)
            return "sub_general_misc", 0.0


if __name__ == "__main__":
    # Quick test
    classifier = BertClassifier()
    test_texts = ["UBER EATS #12345", "AMAZON.COM*TXN6789", "SHELL OIL", "APPLE STORE"]

    for t in test_texts:
        sub, conf = classifier.classify(t)
        print(f"Text: {t} -> {sub} (Conf: {conf:.4f})")
