"""
Mini Regex Dictionary for Testing
=================================
A lightweight version of the production dictionary for unit testing logic.
"""

MERCHANT_DICTIONARY = {
    "UBER EATS": "sub_delivery",
    "UBER": "sub_taxi_ride",
    "STARBUCKS": "sub_restaurants_bars",
    r"\bCHASE\b": "sub_cash_transfers",
}

KEYWORD_RULES = {
    "Food & Dining": {
        "sub_delivery": [r"\bDELIVERY\b"],
        "sub_restaurants_bars": [r"\bRESTAURANT\b"],
    }
}
