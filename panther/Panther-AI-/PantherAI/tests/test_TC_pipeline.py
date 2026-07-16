import unittest
from unittest.mock import MagicMock, patch

from classifier.pipeline import TransactionClassifierPipeline
from classifier.tier0_cache import clear_cache
from classifier.tier1_regex import RegexClassifier
from classifier.tier2_bert import BertClassifier
from tests.fixtures.mini_regex_dict import MERCHANT_DICTIONARY, KEYWORD_RULES


class TestPipeline(unittest.TestCase):
    def setUp(self):
        clear_cache()

        # 1. Initialize a lightweight RegexClassifier with mini dictionary
        self.mock_regex = RegexClassifier(
            merchant_dict=MERCHANT_DICTIONARY, keyword_rules=KEYWORD_RULES
        )

        # 2. Mock the BertClassifier to avoid loading the real model
        self.mock_bert = MagicMock(spec=BertClassifier)

        # 3. Initialize pipeline with injected components
        self.pipeline = TransactionClassifierPipeline(
            tier1=self.mock_regex, tier2=self.mock_bert, margin_threshold=0.3
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
        self.mock_bert.classify_with_probabilities.return_value = (
            "sub_subscriptions",
            0.85,
            [0.85, 0.10, 0.05],
        )

        # "NETFLIX" is NOT in mini_regex_dict
        result = self.pipeline.predict("NETFLIX.COM")

        self.assertEqual(result["subcategory"], "sub_subscriptions")
        self.assertEqual(result["source"], "Model")
        self.assertEqual(result["confidence"], 0.85)
        self.mock_bert.classify_with_probabilities.assert_called_once_with("NETFLIX.COM")

    def test_low_confidence_handling(self):
        """Test handling of predictions with a thin top-1/top-2 margin."""
        self.mock_bert.classify_with_probabilities.return_value = (
            "sub_general_misc",
            0.65,
            [0.65, 0.52, 0.10],
        )

        result = self.pipeline.predict("STUFF 12345")

        self.assertEqual(result["subcategory"], "sub_general_misc")
        self.assertEqual(result["source"], "Low Confidence")
        self.assertEqual(result["confidence"], 0.65)

    def test_cache_hit_skips_model(self):
        """Second call for the same normalized merchant returns from Tier 0."""
        self.mock_bert.classify_with_probabilities.return_value = (
            "sub_subscriptions",
            0.85,
            [0.85, 0.10, 0.05],
        )

        first = self.pipeline.predict("NETFLIX.COM #1234")
        second = self.pipeline.predict("NETFLIX.COM #1234")

        self.assertEqual(first["source"], "Model")
        self.assertEqual(second["source"], "Model")
        self.mock_bert.classify_with_probabilities.assert_called_once_with(
            "NETFLIX.COM #1234"
        )

    def test_low_confidence_queues_tier3_when_transaction_context_present(self):
        self.mock_bert.classify_with_probabilities.return_value = (
            "sub_general_misc",
            0.55,
            [0.55, 0.45],
        )

        with patch("classifier.pipeline.enqueue_low_confidence_transaction") as enqueue:
            result = self.pipeline.predict(
                "UNKNOWN MERCHANT",
                transaction_id="txn_123",
                user_id="user_marcus",
            )

        self.assertEqual(result["source"], "Low Confidence")
        enqueue.assert_called_once_with(
            transaction_id="txn_123",
            user_id="user_marcus",
            description="UNKNOWN MERCHANT",
        )

    def test_empty_input(self):
        """Test behavior with empty or whitespace input."""
        test_cases = ["", "   ", None]
        for tc in test_cases:
            result = self.pipeline.predict(tc)
            self.assertEqual(result["source"], "Empty Input")
            self.assertEqual(result["subcategory"], "sub_general_misc")


if __name__ == "__main__":
    unittest.main()
