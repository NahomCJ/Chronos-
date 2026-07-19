"""
services/financial_advisor/categorizer.py
==========================================
Keyword-based expense categorization against the shared TC-TransactionClassifier
taxonomy (14 categories, 44 subcategories).

This is NOT the production classifier (see services/TC-TransactionClassifier for
the full regex/DistilBERT/Claude waterfall on raw bank feeds). This module
categorizes user-supplied one-off transaction data (pasted/CSV input, no
merchant-history caching or ML tiers needed for that volume) using a smaller
keyword table pointed at the same taxonomy IDs, so category labels stay
consistent across both pipelines.
"""

from __future__ import annotations

import importlib.util
import os
import re
from typing import Any

# ADR: TC-TransactionClassifier uses a hyphen (not a valid Python package name),
# so it's loaded via importlib.util rather than a normal import. Same approach
# as services/insights/constants.py — the taxonomy stays a single source of truth.
_taxonomy_path = os.path.join(
    os.path.dirname(__file__),
    "..",
    "TC-TransactionClassifier",
    "classifier",
    "taxonomy.py",
)
try:
    _spec = importlib.util.spec_from_file_location(
        "_taxonomy_fa", os.path.abspath(_taxonomy_path)
    )
    _mod = importlib.util.module_from_spec(_spec)
    _spec.loader.exec_module(_mod)
    TAXONOMY = _mod.TAXONOMY
except (FileNotFoundError, AttributeError, ModuleNotFoundError) as exc:
    raise ImportError(
        f"Failed to load taxonomy from {_taxonomy_path!r}. "
        "Ensure TC-TransactionClassifier/classifier/taxonomy.py exists."
    ) from exc


SUB_FITNESS_GYM = "sub_fitness_gym"
SUB_SUPPLEMENTATION = "sub_supplementation"
SUB_SUBSCRIPTIONS = "sub_subscriptions"
SUB_MEDICAL_PHARMACY = "sub_medical_pharmacy"
SUB_GENERAL_MISC = "sub_general_misc"

# Keyword -> subcategory id. Order matters: first match wins, so more specific
# categories (fitness, supplements) are checked before generic ones.
_KEYWORD_RULES: list[tuple[re.Pattern, str]] = [
    # Health & wellbeing
    (re.compile(r"\b(gym|fitness|crossfit|barre|corepower|orangetheory|orange theory|"
                r"planet fitness|la fitness|equinox|gold'?s gym|anytime fitness|"
                r"24 ?hour fitness|crunch fitness|peloton|f45|ymca|yoga)\b", re.I), SUB_FITNESS_GYM),
    (re.compile(r"\b(vitamin|supplement|gnc|vitamin ?shoppe|myprotein|huel|"
                r"athletic greens|ag1|thorne|ritual|soylent|garden of life|"
                r"iherb|vitacost|protein powder|creatine)\b", re.I), SUB_SUPPLEMENTATION),
    (re.compile(r"\b(pharmacy|cvs|walgreens|rite aid|doctor|clinic|hospital|dental|urgent care)\b", re.I),
     SUB_MEDICAL_PHARMACY),
    (re.compile(r"\b(spa|salon|barber|massage)\b", re.I), "sub_wellness_beauty"),
    # Food & drink
    (re.compile(r"\b(grocery|groceries|supermarket|trader joe|whole foods|kroger|safeway|aldi)\b", re.I),
     "sub_groceries"),
    (re.compile(r"\b(restaurant|bar\b|cafe|coffee|starbucks|fast food|mcdonald|chipotle|dining)\b", re.I),
     "sub_restaurants_bars"),
    (re.compile(r"\b(doordash|uber eats|grubhub|postmates|instacart)\b", re.I), "sub_delivery"),
    # Transport
    (re.compile(r"\b(uber|lyft|taxi|ride[- ]?shar)\b", re.I), "sub_taxi_ride"),
    (re.compile(r"\b(gas station|shell|chevron|exxon|fuel|toll)\b", re.I), "sub_fuel_tolls"),
    (re.compile(r"\b(metro|transit|bus fare|subway pass)\b", re.I), "sub_public_transport"),
    # Home & utilities
    (re.compile(r"\b(rent|mortgage)\b", re.I), "sub_rent_mortgage"),
    (re.compile(r"\b(electric|water bill|gas bill|utility|utilities|garbage)\b", re.I), "sub_utility_bills"),
    (re.compile(r"\b(internet|comcast|xfinity|verizon|at&t|t-mobile|phone bill|cell phone)\b", re.I),
     "sub_internet_phone"),
    # Entertainment & subscriptions
    (re.compile(r"\b(netflix|spotify|hulu|disney\+|hbo|youtube premium|apple music|"
                r"subscription|saas|adobe|icloud|google one|dropbox)\b", re.I), SUB_SUBSCRIPTIONS),
    (re.compile(r"\b(cinema|movie|concert|museum|theater|theatre)\b", re.I), "sub_events_culture"),
    # Shopping
    (re.compile(r"\b(amazon|target|walmart|clothing|fashion|shoes|electronics|best buy)\b", re.I),
     "sub_fashion"),
    # Financial services
    (re.compile(r"\b(insurance|premium)\b", re.I), "sub_insurance"),
    (re.compile(r"\b(loan payment|credit card payment|interest charge|late fee|overdraft fee|bank fee)\b", re.I),
     "sub_debt_loans"),
    (re.compile(r"\b(savings transfer|to savings|emergency fund)\b", re.I), "sub_savings"),
    (re.compile(r"\b(crypto|bitcoin|coinbase|ethereum)\b", re.I), "sub_crypto"),
    # Personal / family / pets
    (re.compile(r"\b(tuition|course|textbook|udemy|coursera)\b", re.I), "sub_education"),
    (re.compile(r"\b(daycare|childcare|babysitter)\b", re.I), "sub_family_kids"),
    (re.compile(r"\b(vet\b|veterinary|pet food|petco|petsmart)\b", re.I), "sub_pets"),
    # Cash
    (re.compile(r"\b(atm withdrawal|cash withdrawal)\b", re.I), "sub_atm_withdrawals"),
    # Travel
    (re.compile(r"\b(flight|airline|airfare|delta|united airlines|american airlines|jetblue)\b", re.I),
     "sub_flights"),
    (re.compile(r"\b(hotel|airbnb|hostel|motel|resort booking)\b", re.I), "sub_hotels_acc"),
    (re.compile(r"\b(vacation package|tour operator|travel agency|expedia|holiday package)\b", re.I),
     "sub_holidays_trips"),
    # Personal / home extras
    (re.compile(r"\b(home depot|lowe'?s|renovation|repair contractor|handyman)\b", re.I),
     "sub_home_maintenance"),
    (re.compile(r"\b(gift|donation|charity|gofundme)\b", re.I), "sub_gifts_donations"),
    (re.compile(r"\b(gaming|steam|playstation|xbox|hobby shop)\b", re.I), "sub_hobbies"),
]

_ID_TO_NAME: dict[str, str] = {
    sub["id"]: sub["name"]
    for cat in TAXONOMY["taxonomy"]
    for sub in cat["subcategories"]
}
_ID_TO_CATEGORY_NAME: dict[str, str] = {
    sub["id"]: cat["name"]
    for cat in TAXONOMY["taxonomy"]
    for sub in cat["subcategories"]
}


def subcategory_name(subcategory_id: str) -> str:
    return _ID_TO_NAME.get(subcategory_id, "Uncategorized")


def category_name(subcategory_id: str) -> str:
    return _ID_TO_CATEGORY_NAME.get(subcategory_id, "Uncategorized")


def categorize_transaction(merchant: str, explicit_category: str | None = None) -> str:
    """Returns a taxonomy subcategory id for one transaction.

    If the caller already supplied a category hint that matches a known
    subcategory id or name, that hint wins over keyword inference.
    """
    if explicit_category:
        hint = explicit_category.strip().lower()
        for sub_id, name in _ID_TO_NAME.items():
            if hint == sub_id.lower() or hint == name.lower():
                return sub_id

    text = merchant or ""
    for pattern, sub_id in _KEYWORD_RULES:
        if pattern.search(text):
            return sub_id
    return SUB_GENERAL_MISC


def monthly_equivalent(amount: float, frequency: str) -> float:
    frequency = (frequency or "monthly").lower()
    if frequency == "weekly":
        return amount * 52 / 12
    if frequency == "annual" or frequency == "yearly":
        return amount / 12
    if frequency == "quarterly":
        return amount / 3
    if frequency == "one_time" or frequency == "one-time":
        return 0.0
    return amount


def categorize_expenses(transactions: list[dict[str, Any]]) -> dict[str, Any]:
    """Categorizes a list of transactions and rolls them up by subcategory.

    Each transaction dict expects: merchant, amount, frequency (optional,
    default "monthly"), category (optional hint), location (optional).
    Returns per-subcategory monthly totals plus the enriched transaction list.
    """
    enriched: list[dict[str, Any]] = []
    totals: dict[str, float] = {}

    for txn in transactions:
        merchant = str(txn.get("merchant", "")).strip()
        amount = float(txn.get("amount") or 0.0)
        frequency = txn.get("frequency", "monthly")
        sub_id = categorize_transaction(merchant, txn.get("category"))
        monthly_amount = round(monthly_equivalent(amount, frequency), 2)

        enriched.append(
            {
                "merchant": merchant,
                "amount": round(amount, 2),
                "frequency": frequency,
                "monthly_amount": monthly_amount,
                "subcategory_id": sub_id,
                "subcategory_name": subcategory_name(sub_id),
                "category_name": category_name(sub_id),
                "location": txn.get("location"),
            }
        )
        totals[sub_id] = round(totals.get(sub_id, 0.0) + monthly_amount, 2)

    by_category = sorted(
        (
            {
                "subcategory_id": sub_id,
                "subcategory_name": subcategory_name(sub_id),
                "category_name": category_name(sub_id),
                "monthly_total": total,
            }
            for sub_id, total in totals.items()
        ),
        key=lambda row: row["monthly_total"],
        reverse=True,
    )

    return {
        "transactions": enriched,
        "by_subcategory": by_category,
        "total_monthly_expenses": round(sum(totals.values()), 2),
    }
