import re

try:
    from . import regex_dictionary as TC_RegexDictionary
except ImportError:
    # If not found, we will fall back to passing the dictionary in __init__ for testing
    TC_RegexDictionary = None


class RegexClassifier:
    """
    Tier 1 Transaction Classifier using regex patterns for high-precision matching.
    """

    def __init__(self, merchant_dict=None, keyword_rules=None):
        """
        Initializes the classifier with optimized mega-regexes.
        """
        # Load from production if not provided
        if merchant_dict is None and TC_RegexDictionary:
            merchant_dict = TC_RegexDictionary.MERCHANT_DICTIONARY
        if keyword_rules is None and TC_RegexDictionary:
            keyword_rules = TC_RegexDictionary.KEYWORD_RULES

        # 1. MERCHANT Mega-Regex (Preserving Order)
        self.merchant_mega_re, self.merchant_group_map = self._compile_mega_regex(
            self._flatten_merchant_dict(merchant_dict)
        )

        # 2. KEYWORD Mega-Regex
        self.keyword_mega_re, self.keyword_group_map = self._compile_mega_regex(
            self._flatten_keyword_rules(keyword_rules)
        )

    def _flatten_merchant_dict(self, merchant_dict):
        """Flattens merchant dict into a list of (pattern, sub_id) tuples."""
        if not merchant_dict:
            return []
        return [(p, s) for p, s in merchant_dict.items()]

    def _flatten_keyword_rules(self, keyword_rules):
        """Flattens keyword rules into a list of (pattern, sub_id) tuples."""
        if not keyword_rules:
            return []
        flattened = []
        for category, sub_rules in keyword_rules.items():
            for sub_id, patterns in sub_rules.items():
                for pattern_str in patterns:
                    flattened.append((pattern_str, sub_id))
        return flattened

    def _compile_mega_regex(self, patterns_ids: list[tuple[str, str]]):
        """
        Combines multiple regexes into a single 'mega-regex' for O(1) matching.
        Groups contiguous patterns with the same ID into a single capture group.
        """
        if not patterns_ids:
            return None, {}

        grouped_patterns = []
        group_to_sub_id = {}
        current_group_idx = 1

        # Optimization: group contiguous identical sub_ids
        # e.g. [(r"A", "id1"), (r"B", "id1"), (r"C", "id2")] -> [(r"(?:A|B)", "id1"), (r"C", "id2")]
        optimized_list = []
        if patterns_ids:
            last_pattern, last_id = patterns_ids[0]
            current_batch = [last_pattern]
            for p, s in patterns_ids[1:]:
                if s == last_id:
                    current_batch.append(p)
                else:
                    optimized_list.append(
                        ("|".join(f"(?:{b})" for b in current_batch), last_id)
                    )
                    current_batch = [p]
                    last_id = s
            optimized_list.append(
                ("|".join(f"(?:{b})" for b in current_batch), last_id)
            )

        # Build the mega-regex string
        mega_pattern_parts = []
        for i, (pattern_str, sub_id) in enumerate(optimized_list):
            try:
                # Wrap each (possibly grouped) pattern in a capture group
                re.compile(pattern_str)  # Validate individual pattern first
                mega_pattern_parts.append(f"({pattern_str})")
                group_to_sub_id[current_group_idx] = sub_id
                current_group_idx += 1
            except re.error:
                continue

        if not mega_pattern_parts:
            return None, {}

        mega_re_str = "|".join(mega_pattern_parts)
        try:
            mega_re = re.compile(mega_re_str, re.IGNORECASE)
            return mega_re, group_to_sub_id
        except re.error:
            # Fallback if the combined regex is too complex
            return None, {}

    def _normalize_text(self, text: str) -> str:
        """
        Normalizes input text for matching.
        - Uppercase
        - Cleaning whitespace
        """
        if not text or not isinstance(text, str):
            return ""

        # Collapse multiple spaces and strip
        normalized = " ".join(text.split())
        return normalized.upper()

    def classify(self, text: str) -> tuple[str, float] | None:
        """
        Classifies a transaction text using optimized mega-regexes.
        """
        if not text:
            return None

        normalized_text = self._normalize_text(text)
        if not normalized_text:
            return None

        # 1. MERCHANT_DICTIONARY (High Priority)
        if self.merchant_mega_re:
            match = self.merchant_mega_re.search(normalized_text)
            if match:
                # Find which group matched
                for i, sub_id in self.merchant_group_map.items():
                    if match.group(i) is not None:
                        return sub_id, 1.0

        # 2. KEYWORD_RULES (Fallback)
        if self.keyword_mega_re:
            match = self.keyword_mega_re.search(normalized_text)
            if match:
                # Find which group matched
                for i, sub_id in self.keyword_group_map.items():
                    if match.group(i) is not None:
                        return sub_id, 1.0

        return None
