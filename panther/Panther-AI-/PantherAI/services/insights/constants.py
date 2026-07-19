"""
services/insights/constants.py
==============================
Colors, icons, and taxonomy mapping for the Dashboard Insights API.

Server-side color assignment ensures consistency across all platforms
(mobile, web, internal tools) without duplicating color logic.

Colors are WCAG AA compliant against white backgrounds.
Subcategory colors are computed as lighter variants of the parent.
"""

from __future__ import annotations

import importlib.util
import os

# ADR: TC-TransactionClassifier uses a hyphen (not a valid Python package name).
# We load taxonomy.py via importlib.util to avoid sys.path pollution. This means
# the taxonomy is the single source of truth for category/subcategory definitions
# — no duplicate mappings to maintain.
_taxonomy_path = os.path.join(
    os.path.dirname(__file__),
    "..",
    "TC-TransactionClassifier",
    "classifier",
    "taxonomy.py",
)
try:
    _spec = importlib.util.spec_from_file_location(
        "_taxonomy", os.path.abspath(_taxonomy_path)
    )
    _mod = importlib.util.module_from_spec(_spec)
    _spec.loader.exec_module(_mod)
    TAXONOMY = _mod.TAXONOMY
except (FileNotFoundError, AttributeError, ModuleNotFoundError) as exc:
    raise ImportError(
        f"Failed to load taxonomy from {_taxonomy_path!r}. "
        "Ensure TC-TransactionClassifier/classifier/taxonomy.py exists."
    ) from exc


# ---------------------------------------------------------------------------
# Category colors — deterministic, accessibility-compliant palette
# ADR: Colors are assigned server-side (not frontend) so mobile, web, and
# internal tools render identically without syncing a color config. Single
# source of truth. Update one place to fix accessibility issues everywhere.
# ---------------------------------------------------------------------------
CATEGORY_COLORS: dict[str, str] = {
    "cat_food_drink": "#E07C5A",  # Warm Terracotta
    "cat_transport": "#5B9BD5",  # Steel Blue
    "cat_travel": "#3AAFA9",  # Teal
    "cat_health_wellbeing": "#5AAD7A",  # Fresh Green
    "cat_shopping": "#D4A843",  # Rich Gold
    "cat_home_utilities": "#4A90D9",  # Deep Sky
    "cat_entertainment_leisure": "#9B6BB0",  # Soft Purple
    "cat_personal": "#C97B84",  # Dusty Rose
    "cat_family": "#E8A87C",  # Peach
    "cat_pets": "#6B8EC2",  # Slate Blue
    "cat_financial_services": "#4A7C59",  # Forest Green
    "cat_cash": "#8B7355",  # Bronze
    "cat_income": "#38A169",  # Green (positive)
    "cat_uncategorized": "#95A5A6",  # Neutral Gray
}

RISK_COLORS: dict[str, str] = {
    "HIGH": "#E53E3E",
    "MEDIUM": "#ECC94B",
    "LOW": "#38A169",
}

# ---------------------------------------------------------------------------
# Category icons — maps to common icon libraries (Lucide, Feather, SF Symbols)
# ---------------------------------------------------------------------------
CATEGORY_ICONS: dict[str, str] = {
    "cat_food_drink": "utensils",
    "cat_transport": "car",
    "cat_travel": "plane",
    "cat_health_wellbeing": "heart-pulse",
    "cat_shopping": "shopping-bag",
    "cat_home_utilities": "home",
    "cat_entertainment_leisure": "tv",
    "cat_personal": "user",
    "cat_family": "users",
    "cat_pets": "paw-print",
    "cat_financial_services": "landmark",
    "cat_cash": "banknote",
    "cat_income": "wallet",
    "cat_uncategorized": "help-circle",
}

# ---------------------------------------------------------------------------
# Reverse lookup: display name → category_id
# ADR: Built at import time from the taxonomy module so it never drifts.
# Transactions return display names ("Groceries"), but the API contract uses
# IDs ("cat_food_drink"). This map bridges the two without hardcoding names.
# ---------------------------------------------------------------------------
NAME_TO_CATEGORY_ID: dict[str, str] = {}
CATEGORY_ID_TO_NAME: dict[str, str] = {}
SUBCATEGORY_ID_TO_PARENT: dict[str, str] = {}
SUBCATEGORY_ID_TO_NAME: dict[str, str] = {}

for cat in TAXONOMY["taxonomy"]:
    cat_id = cat["id"]
    cat_name = cat["name"]
    NAME_TO_CATEGORY_ID[cat_name] = cat_id
    CATEGORY_ID_TO_NAME[cat_id] = cat_name
    for sub in cat.get("subcategories", []):
        sub_id = sub["id"]
        sub_name = sub["name"]
        # Also map subcategory display names to the parent category
        NAME_TO_CATEGORY_ID[sub_name] = cat_id
        SUBCATEGORY_ID_TO_PARENT[sub_id] = cat_id
        SUBCATEGORY_ID_TO_NAME[sub_id] = sub_name


def get_category_id(display_name: str) -> str:
    """
    Resolves a human-readable category or subcategory name to its canonical category_id.

    Args:
        display_name (str): Display name from transaction data (e.g. "Groceries",
            "Food & Drink", "Taxi & Ride-sharing"). Case-sensitive, must match taxonomy exactly.

    Returns:
        str: Category ID (e.g. "cat_food_drink"). Returns "cat_uncategorized" if no match found.
    """
    return NAME_TO_CATEGORY_ID.get(display_name, "cat_uncategorized")


def get_subcategory_color(category_id: str, index: int) -> str:
    """
    Generates a lighter variant of the parent category color for subcategory charts.

    Args:
        category_id (str): Parent category ID (e.g. "cat_food_drink").
        index (int): Subcategory position (0 = full color, 1 = 80%, 2 = 60%, 3+ = 30%).

    Returns:
        str: Hex color string (e.g. "#FF8C5E") blended toward white. Falls back to
            gray (#A0AEC0) if category_id is unknown.
    """
    base_hex = CATEGORY_COLORS.get(category_id, "#A0AEC0")
    r = int(base_hex[1:3], 16)
    g = int(base_hex[3:5], 16)
    b = int(base_hex[5:7], 16)

    opacity = max(0.3, 1.0 - (index * 0.2))
    r = int(r + (255 - r) * (1 - opacity))
    g = int(g + (255 - g) * (1 - opacity))
    b = int(b + (255 - b) * (1 - opacity))

    return f"#{r:02X}{g:02X}{b:02X}"
