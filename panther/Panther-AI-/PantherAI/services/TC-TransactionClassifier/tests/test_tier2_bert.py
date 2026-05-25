import os
import sys

# Add parent directory to path to import tier2_bert
# Add parent directory to path to import classifier package
# Current file: .../tests/test_tier2_bert.py
# Root: .../PantherAI/TC-TransactionClassifier/
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from classifier.tier2_bert import BertClassifier


def test_classifier():
    print("--- Tier 2 BERT Classifier Test ---")

    try:
        classifier = BertClassifier()
    except Exception as e:
        print(f"FAILED to initialize classifier: {e}")
        return

    test_cases = [
        # Standard cases
        ("UBER EATS #12345", "sub_delivery"),
        ("AMAZON.COM*TXN6789", "sub_home_general"),
        ("SHELL OIL 4421", "sub_fuel_tolls"),
        ("STARBUCKS COFFEE", "sub_restaurants_bars"),
        ("NETFLIX.COM", "sub_subscriptions"),
        ("MEDICAL CENTER PATIENT PMT", "sub_medical_pharmacy"),
        # Complex/Normalized cases
        ("ZELLE FROM MOM", "sub_cash_transfers"),
        ("CHECK #1001", "sub_cash_transfers"),  # Often cash/transfer
        ("ATM WITHDRAWAL", "sub_atm_withdrawals"),
        # Edge cases
        ("", "sub_general_misc"),
        ("   ", "sub_general_misc"),
        ("XYZKJASDHKAJS", None),  # Random string, just checking it doesn't crash
    ]

    print(f"\n{'Input Text':<30} | {'Expected':<20} | {'Predicted':<20} | {'Conf':<6}")
    print("-" * 85)

    for text, expected in test_cases:
        sub, conf = classifier.classify(text)
        status = "✅" if (expected is None or sub == expected) else "❌"
        print(f"{text:<30} | {str(expected):<20} | {sub:<20} | {conf:.4f} {status}")

    print("\nTest completed.")


if __name__ == "__main__":
    test_classifier()
