"""
services/conversational_ai/nlp_utils.py
========================================
Text extraction utilities for Chris.

Intent detection is handled by the LLM via tool calling (see chris.py).
This module only provides regex-based entity extraction as a fallback utility.
"""

from __future__ import annotations

import re

# ---------------------------------------------------------------------------
# Amount extraction regex
# Matches: $200, $1,234.56, 200 dollars, 200 bucks, $50.00
# ---------------------------------------------------------------------------
_AMOUNT_PATTERNS = [
    re.compile(r"\$\s?([\d,]+(?:\.\d{1,2})?)"),
    re.compile(r"([\d,]+(?:\.\d{1,2})?)\s*(?:dollars|bucks)", re.IGNORECASE),
]


def extract_amount(message: str) -> float | None:
    """
    Extracts the first dollar amount found in a message.

    >>> extract_amount("Can I spend $1,234.56?")
    1234.56
    >>> extract_amount("No amount here")
    """
    for pattern in _AMOUNT_PATTERNS:
        match = pattern.search(message)
        if match:
            raw = match.group(1).replace(",", "")
            return float(raw)
    return None
