import os
import sys
import unittest
from unittest.mock import MagicMock

# Add PantherAI/TC-TransactionClassifier and project root to path
current_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.abspath(os.path.join(current_dir, ".."))
tc_path = os.path.join(project_root, "PantherAI", "TC-TransactionClassifier")

if tc_path not in sys.path:
    sys.path.append(tc_path)
if project_root not in sys.path:
    sys.path.append(project_root)

from pipeline import TransactionClassifierPipeline
from tier1_regex import RegexClassifier
from tier2_bert import BertClassifier
from tests.fixtures.mini_regex_dict import MERCHANT_DICTIONARY, KEYWORD_RULES


class TestPipeline(unittest.TestCase):
    def setUp(self):
        # 1. Initialize a lightweight RegexClassifier with mini dictionary
        self.mock_regex = RegexClassifier(
            merchant_dict=MERCHANT_DICTIONARY, keyword_rules=KEYWORD_RULES
        )

        # 2. Mock the BertClassifier to avoid loading the real model
        self.mock_bert = MagicMock(spec=BertClassifier)

        # 3. Initialize pipeline with injected components
        self.pipeline = TransactionClassifierPipeline(
            tier1=self.mock_regex, tier2=self.mock_bert, confidence_threshold=0.6
        )

    def test_regex_precedence(self):
        """Test that Regex matches take precedence even if BERT has a high-confidence prediction."""
        # Setup BERT to return a different valid prediction
        self.mock_bert.classify.return_value = ("sub_wrong_category", 0.99)

        # "UBER EATS" is in mini_regex_dict as "sub_delivery"
        result = self.pipeline.predict("UBER EATS #1234")

        self.assertEqual(result["subcategory"], "sub_delivery")
        self.assertEqual(result["source"], "Regex")
        self.assertEqual(result["confidence"], 1.0)
        # Verify BERT was NOT called (Efficiency optimization)
        self.mock_bert.classify.assert_not_called()

    def test_model_fallback(self):
        """Test that Model is used when Regex fails."""
        # Setup BERT response
        self.mock_bert.classify.return_value = ("sub_subscriptions", 0.85)

        # "NETFLIX" is NOT in mini_regex_dict
        result = self.pipeline.predict("NETFLIX.COM")

        self.assertEqual(result["subcategory"], "sub_subscriptions")
        self.assertEqual(result["source"], "Model")
        self.assertEqual(result["confidence"], 0.85)
        # Verify BERT WAS called
        self.mock_bert.classify.assert_called_once_with("NETFLIX.COM")

    def test_low_confidence_handling(self):
        """Test handling of predictions below the confidence threshold."""
        # Setup BERT with low confidence
        self.mock_bert.classify.return_value = ("sub_general_misc", 0.45)

        result = self.pipeline.predict("STUFF 12345")

        self.assertEqual(result["subcategory"], "sub_general_misc")
        self.assertEqual(result["source"], "Low Confidence")
        self.assertEqual(result["confidence"], 0.45)

    def test_empty_input(self):
        """Test behavior with empty or whitespace input."""
        test_cases = ["", "   ", None]
        for tc in test_cases:
            result = self.pipeline.predict(tc)
            self.assertEqual(result["source"], "Empty Input")
            self.assertEqual(result["subcategory"], "sub_general_misc")


if __name__ == "__main__":
    unittest.main()
