import os
import sys
import unittest

# Add PantherAI/TC-TransactionClassifier and project root to path
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
tc_path = os.path.join(project_root, "PantherAI", "TC-TransactionClassifier")
if tc_path not in sys.path:
    sys.path.append(tc_path)
if project_root not in sys.path:
    sys.path.append(project_root)

from tier1_regex import RegexClassifier
from tests.fixtures.mini_regex_dict import MERCHANT_DICTIONARY, KEYWORD_RULES


class TestTier1Regex(unittest.TestCase):
    def setUp(self):
        # Initialize with mini dictionary for fast, deterministic testing
        self.classifier = RegexClassifier(
            merchant_dict=MERCHANT_DICTIONARY, keyword_rules=KEYWORD_RULES
        )

    def test_exact_merchant_match(self):
        """Test simple exact merchant matching."""
        result, conf = self.classifier.classify("STARBUCKS")
        self.assertEqual(result, "sub_restaurants_bars")
        self.assertEqual(conf, 1.0)

    def test_priority_match(self):
        """Test that UBER EATS takes precedence over UBER."""
        result, conf = self.classifier.classify("UBER EATS #1234")
        self.assertEqual(result, "sub_delivery")

        result, conf = self.classifier.classify("UBER RIDE #5678")
        self.assertEqual(result, "sub_taxi_ride")

    def test_regex_word_boundary(self):
        """Test regex pattern with word boundaries (CHASE)."""
        # Should match CHASE
        result, conf = self.classifier.classify("CHASE BANK")
        self.assertEqual(result, "sub_cash_transfers")

        # Should NOT match PURCHASE
        result = self.classifier.classify("AMAZON PURCHASE")
        self.assertIsNone(result)
        # Actually I didn't put AMAZON in mini. Let's fix that or test it correctly.
        # In mini_regex_dict: UBER EATS, UBER, STARBUCKS, \bCHASE\b

    def test_keyword_fallback(self):
        """Test keyword rules when no merchant match is found."""
        result, conf = self.classifier.classify("MY LOCAL RESTAURANT")
        self.assertEqual(result, "sub_restaurants_bars")

    def test_normalization(self):
        """Test input normalization (case, spaces)."""
        result, conf = self.classifier.classify("  starbucks  ")
        self.assertEqual(result, "sub_restaurants_bars")

        result, conf = self.classifier.classify("Uber   Eats")
        self.assertEqual(result, "sub_delivery")

    def test_no_match(self):
        """Test when no match is found."""
        result = self.classifier.classify("UNKNOWN TRANSACTION 999")
        self.assertIsNone(result)


if __name__ == "__main__":
    unittest.main()
