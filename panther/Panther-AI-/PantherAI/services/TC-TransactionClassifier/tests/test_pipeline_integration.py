import os
import sys
import logging

# Ensure the package root is in path
# Current file: .../PantherAI/TC-TransactionClassifier/tests/test_pipeline_integration.py
# Root: .../PantherAI/TC-TransactionClassifier/
package_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if package_root not in sys.path:
    sys.path.insert(0, package_root)

from classifier.pipeline import TransactionClassifierPipeline

# Configure logging for the script
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("VerifyPipeline")


def run_verification():
    logger.info("Starting Pipeline Verification...")

    # Initialize pipeline
    pipeline = TransactionClassifierPipeline()

    # Test Cases: (Input, Expected Source, Note)
    test_cases = [
        ("UBER EATS #1234", "Regex", "Known merchant in dictionary"),
        ("AMAZON.COM*ORDER", "Regex", "Known merchant in dictionary"),
        ("MCDONALD'S 1234 TXN", "Regex", "Known merchant"),
        ("COFFEE SHOP IN SF", "Model", "Semantic match (BERT territory)"),
        ("MONTHLY RENT PAYMENT", "Model", "Semantic match (BERT territory)"),
        ("asdfghjkl 123", "Low Confidence", "Garbage input / Low confidence"),
        ("ZZZZZZZZZZZZ", "Low Confidence", "Ultra garbage"),
        ("", "Empty Input", "Empty string handling"),
    ]

    print("\n" + "=" * 60)
    print(f"{'Input':<25} | {'Result':<20} | {'Source':<15} | {'Conf':<6}")
    print("-" * 60)

    for text, expected_source, note in test_cases:
        res = pipeline.predict(text)
        print(
            f"{text[:24]:<25} | {res['subcategory']:<20} | {res['source']:<15} | {res['confidence']:.2f}"
        )

    print("=" * 60 + "\n")


if __name__ == "__main__":
    run_verification()
