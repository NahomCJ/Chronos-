"""
tests/test_insights.py
========================
114 tests for the Dashboard Insights API (3 endpoints).

Unit tests call pure computation functions directly (no I/O, no mocking).
Integration tests hit FastAPI endpoints via TestClient with real mock data.

Test classes:
  Helpers                        — _direction(), _pct() edge cases
  Constants                      — color/icon parity, taxonomy maps, hex validation
  SpendingSummary                — totals, sorting, percentages, daily series, deltas
  SpendingSummaryEdgeCases       — empty data, income-only, leap year, uncategorized
  TopCategories                  — ranking, sparklines, trends, other-categories aggregation
  TopCategoriesEdgeCases         — overflow to "other", recurring detection
  Insights                       — spike/concentration generation, even-spending suppression
  WarningsHistory                — risk summary, date labels, pagination, calendar heatmap
  WarningsHistoryEdgeCases       — empty list, all-same-level, yesterday label
  SpendingSummaryEndpoint        — GET /api/insights/spending-summary (all 3 demo users)
  TopCategoriesEndpoint          — GET /api/insights/top-categories (all 3 demo users)
  WarningsHistoryEndpoint        — GET /api/insights/warnings-history (all 3 demo users)
"""

from datetime import date, datetime, timezone

from fastapi.testclient import TestClient

from main import app
from services.insights.helpers import _direction, _pct
from services.insights.spending_summary import compute_spending_summary
from services.insights.top_categories import compute_top_categories
from services.insights.warnings import compile_warnings_history
from services.insights.constants import (
    CATEGORY_COLORS,
    CATEGORY_ID_TO_NAME,
    CATEGORY_ICONS,
    NAME_TO_CATEGORY_ID,
    RISK_COLORS,
    SUBCATEGORY_ID_TO_PARENT,
    get_category_id,
    get_subcategory_color,
)

client = TestClient(app)


# ---------------------------------------------------------------------------
# Test data
# ---------------------------------------------------------------------------

SAMPLE_TRANSACTIONS = [
    # February 2025
    {
        "merchant": "STARBUCKS",
        "amount": -4.50,
        "date": "2025-02-17",
        "category": "Restaurants & Bars",
    },
    {
        "merchant": "UBER",
        "amount": -12.30,
        "date": "2025-02-17",
        "category": "Taxi & Ride-sharing",
    },
    {
        "merchant": "WHOLE FOODS",
        "amount": -87.40,
        "date": "2025-02-16",
        "category": "Groceries",
    },
    {
        "merchant": "NETFLIX",
        "amount": -15.99,
        "date": "2025-02-15",
        "category": "Subscriptions",
    },
    {
        "merchant": "LANDLORD PMT",
        "amount": -1500.00,
        "date": "2025-02-01",
        "category": "Rent & Mortgage",
    },
    {
        "merchant": "EMPLOYER DIRECT",
        "amount": 5200.00,
        "date": "2025-02-01",
        "category": "Salary",
    },
    {
        "merchant": "CHIPOTLE",
        "amount": -11.25,
        "date": "2025-02-10",
        "category": "Restaurants & Bars",
    },
    {
        "merchant": "SAFEWAY",
        "amount": -54.30,
        "date": "2025-02-08",
        "category": "Groceries",
    },
    # January 2025
    {
        "merchant": "LANDLORD PMT",
        "amount": -1500.00,
        "date": "2025-01-01",
        "category": "Rent & Mortgage",
    },
    {
        "merchant": "EMPLOYER DIRECT",
        "amount": 5200.00,
        "date": "2025-01-01",
        "category": "Salary",
    },
    {
        "merchant": "STARBUCKS",
        "amount": -4.50,
        "date": "2025-01-22",
        "category": "Restaurants & Bars",
    },
    {
        "merchant": "WHOLE FOODS",
        "amount": -78.30,
        "date": "2025-01-28",
        "category": "Groceries",
    },
]

SAMPLE_PREV_MONTH = [t for t in SAMPLE_TRANSACTIONS if t["date"].startswith("2025-01")]

SAMPLE_WARNINGS = [
    {
        "id": "warn_001",
        "timestamp": "2025-02-17T14:30:00Z",
        "source": "cash_flow",
        "risk_level": "HIGH",
        "title": "High-risk payment",
        "message": "Balance will be negative after this purchase.",
        "context": {
            "payment_amount": 500,
            "merchant": "BEST BUY",
            "projected_balance": -100,
        },
        "outcome": {"user_action": "proceeded", "action_label": "User proceeded"},
    },
    {
        "id": "warn_002",
        "timestamp": "2025-02-11T09:15:00Z",
        "source": "bnpl",
        "risk_level": "MEDIUM",
        "title": "BNPL risk elevated",
        "message": "Too many active BNPL plans.",
        "context": {"bnpl_score": 52, "payment_amount": 129.99},
        "outcome": {"user_action": "cancelled", "action_label": "User cancelled"},
    },
    {
        "id": "warn_003",
        "timestamp": "2025-01-14T08:00:00Z",
        "source": "cash_flow",
        "risk_level": "LOW",
        "title": "Safe payment",
        "message": "Within budget.",
        "context": {"payment_amount": 15, "projected_balance": 2100},
        "outcome": {"user_action": "proceeded", "action_label": "User proceeded"},
    },
]


# ---------------------------------------------------------------------------
# Helper function tests
# ---------------------------------------------------------------------------


class TestHelpers:
    def test_direction_positive(self):
        assert _direction(10.0) == "increased"

    def test_direction_negative(self):
        assert _direction(-5.0) == "decreased"

    def test_direction_zero(self):
        assert _direction(0.0) == "unchanged"

    def test_direction_tiny_positive(self):
        assert _direction(0.01) == "increased"

    def test_pct_normal(self):
        assert _pct(25, 100) == 25.0

    def test_pct_zero_whole(self):
        assert _pct(10, 0) == 0.0

    def test_pct_rounding(self):
        assert _pct(1, 3) == 33.3

    def test_pct_zero_part(self):
        assert _pct(0, 100) == 0.0

    def test_pct_full(self):
        assert _pct(100, 100) == 100.0


# ---------------------------------------------------------------------------
# Constants tests
# ---------------------------------------------------------------------------


class TestConstants:
    def test_all_14_categories_have_colors(self):
        assert len(CATEGORY_COLORS) == 14

    def test_all_14_categories_have_icons(self):
        assert len(CATEGORY_ICONS) == 14

    def test_color_and_icon_keys_match(self):
        assert set(CATEGORY_COLORS.keys()) == set(CATEGORY_ICONS.keys())

    def test_name_to_category_id_resolves_display_names(self):
        assert get_category_id("Food & Drink") == "cat_food_drink"
        assert get_category_id("Groceries") == "cat_food_drink"
        assert get_category_id("Taxi & Ride-sharing") == "cat_transport"
        assert get_category_id("Rent & Mortgage") == "cat_home_utilities"

    def test_unknown_name_returns_uncategorized(self):
        assert get_category_id("XYZZY_UNKNOWN") == "cat_uncategorized"

    def test_category_id_to_name_is_inverse_of_name_to_id(self):
        for cat_name, cat_id in NAME_TO_CATEGORY_ID.items():
            # Parent category names should round-trip
            if (
                cat_id in CATEGORY_ID_TO_NAME
                and CATEGORY_ID_TO_NAME[cat_id] == cat_name
            ):
                assert NAME_TO_CATEGORY_ID[cat_name] == cat_id

    def test_subcategory_ids_map_to_valid_parents(self):
        valid_cat_ids = set(CATEGORY_ID_TO_NAME.keys())
        for sub_id, parent_id in SUBCATEGORY_ID_TO_PARENT.items():
            assert (
                parent_id in valid_cat_ids
            ), f"{sub_id} maps to unknown parent {parent_id}"

    def test_subcategory_color_lighter_than_parent(self):
        parent = CATEGORY_COLORS["cat_food_drink"]
        child = get_subcategory_color("cat_food_drink", 1)
        # Child should be lighter (higher RGB values)
        p_r = int(parent[1:3], 16)
        c_r = int(child[1:3], 16)
        assert c_r >= p_r

    def test_subcategory_color_index_0_is_darkest(self):
        c0 = get_subcategory_color("cat_transport", 0)
        c1 = get_subcategory_color("cat_transport", 1)
        c2 = get_subcategory_color("cat_transport", 2)
        # Index 0 should have lowest (darkest) R value
        r0 = int(c0[1:3], 16)
        r1 = int(c1[1:3], 16)
        r2 = int(c2[1:3], 16)
        assert r0 <= r1 <= r2

    def test_subcategory_color_unknown_category_falls_back(self):
        color = get_subcategory_color("cat_nonexistent", 0)
        assert color.startswith("#")
        assert len(color) == 7

    def test_subcategory_color_high_index_clamps_opacity(self):
        # Index 10 should still produce a valid hex color (opacity floors at 0.3)
        color = get_subcategory_color("cat_food_drink", 10)
        assert color.startswith("#")
        assert len(color) == 7

    def test_risk_colors_cover_all_levels(self):
        assert set(RISK_COLORS.keys()) == {"HIGH", "MEDIUM", "LOW"}

    def test_all_colors_are_valid_hex(self):
        for color in CATEGORY_COLORS.values():
            assert len(color) == 7
            assert color.startswith("#")
            int(color[1:], 16)  # Should not raise
        for color in RISK_COLORS.values():
            assert len(color) == 7
            assert color.startswith("#")
            int(color[1:], 16)


# ---------------------------------------------------------------------------
# Spending Summary tests
# ---------------------------------------------------------------------------


class TestSpendingSummary:
    def test_total_spent_excludes_income(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        summary = result["summary"]
        assert summary["total_spent"] > 0
        assert summary["total_income"] == 5200.00

    def test_total_spent_is_exact(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        expected = round(4.50 + 12.30 + 87.40 + 15.99 + 1500.00 + 11.25 + 54.30, 2)
        assert result["summary"]["total_spent"] == expected

    def test_net_cash_flow_computed_correctly(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        summary = result["summary"]
        assert summary["net_cash_flow"] == round(
            summary["total_income"] - summary["total_spent"], 2
        )

    def test_transaction_count_excludes_other_months(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        # 7 spending + 1 income in Feb = 8 total
        assert result["summary"]["transaction_count"] == 8

    def test_categories_sorted_by_amount_descending(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        amounts = [c["amount"] for c in result["by_category"]]
        assert amounts == sorted(amounts, reverse=True)

    def test_percentages_sum_to_approximately_100(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        total_pct = sum(c["percentage"] for c in result["by_category"])
        assert 99.0 <= total_pct <= 101.0  # Allow rounding variance

    def test_every_category_has_color_and_icon(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        for cat in result["by_category"]:
            assert cat["color"].startswith("#")
            assert len(cat["icon"]) > 0

    def test_daily_series_covers_full_month(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        assert len(result["daily_series"]) == 28  # Feb 2025

    def test_daily_series_partial_month(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 10)
        )
        assert len(result["daily_series"]) == 10

    def test_cumulative_is_monotonically_non_decreasing(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        cumulatives = [d["cumulative"] for d in result["daily_series"]]
        for i in range(1, len(cumulatives)):
            assert cumulatives[i] >= cumulatives[i - 1]

    def test_cumulative_final_equals_total_spent(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        final_cumulative = result["daily_series"][-1]["cumulative"]
        assert final_cumulative == result["summary"]["total_spent"]

    def test_day_of_week_has_7_entries(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        assert len(result["day_of_week_pattern"]) == 7

    def test_day_of_week_names_correct(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        days = [d["day"] for d in result["day_of_week_pattern"]]
        assert days == [
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
            "Sunday",
        ]

    def test_day_of_week_indices_sequential(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        indices = [d["day_index"] for d in result["day_of_week_pattern"]]
        assert indices == list(range(7))

    def test_vs_previous_month_has_direction(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        direction = result["summary"]["vs_previous_month"]["direction"]
        assert direction in ("increased", "decreased", "unchanged")

    def test_vs_previous_month_delta_sign_matches_direction(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        vs = result["summary"]["vs_previous_month"]
        if vs["direction"] == "increased":
            assert vs["total_spent_delta"] > 0
        elif vs["direction"] == "decreased":
            assert vs["total_spent_delta"] < 0

    def test_category_vs_previous_month_present(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        for cat in result["by_category"]:
            vs = cat["vs_previous_month"]
            assert "amount_delta" in vs
            assert "direction" in vs
            assert vs["direction"] in ("increased", "decreased", "unchanged")

    def test_subcategories_present(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        food_cat = next(
            (c for c in result["by_category"] if c["category_id"] == "cat_food_drink"),
            None,
        )
        assert food_cat is not None
        assert len(food_cat["subcategories"]) > 0

    def test_subcategory_percentages_within_category(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        for cat in result["by_category"]:
            if cat["subcategories"]:
                sub_pct_sum = sum(
                    s["percentage_of_category"] for s in cat["subcategories"]
                )
                assert 99.0 <= sub_pct_sum <= 101.0

    def test_top_merchants_max_3(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        for cat in result["by_category"]:
            assert len(cat["top_merchants"]) <= 3

    def test_meta_period_fields(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        meta = result["meta"]
        assert meta["period"]["month"] == 2
        assert meta["period"]["year"] == 2025
        assert meta["period"]["label"] == "February 2025"
        assert meta["period"]["start_date"] == "2025-02-01"
        assert meta["period"]["end_date"] == "2025-02-28"
        assert meta["period"]["days_in_period"] == 28
        assert meta["currency"] == "USD"

    def test_daily_series_weekend_flag(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        for entry in result["daily_series"]:
            d = date.fromisoformat(entry["date"])
            assert entry["is_weekend"] == (d.weekday() >= 5)

    def test_ranks_are_sequential(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, SAMPLE_PREV_MONTH, 2, 2025, today=date(2025, 2, 28)
        )
        ranks = [c["rank"] for c in result["by_category"]]
        assert ranks == list(range(1, len(ranks) + 1))


# ---------------------------------------------------------------------------
# Spending Summary — edge cases
# ---------------------------------------------------------------------------


class TestSpendingSummaryEdgeCases:
    def test_empty_transactions(self):
        result = compute_spending_summary([], [], 2, 2025, today=date(2025, 2, 28))
        assert result["summary"]["total_spent"] == 0.0
        assert result["summary"]["total_income"] == 0.0
        assert result["summary"]["net_cash_flow"] == 0.0
        assert result["summary"]["transaction_count"] == 0
        assert result["by_category"] == []

    def test_income_only_no_spending(self):
        txns = [
            {
                "merchant": "EMPLOYER",
                "amount": 5000.00,
                "date": "2025-02-01",
                "category": "Salary",
            }
        ]
        result = compute_spending_summary(txns, [], 2, 2025, today=date(2025, 2, 28))
        assert result["summary"]["total_spent"] == 0.0
        assert result["summary"]["total_income"] == 5000.00
        assert result["by_category"] == []

    def test_single_transaction(self):
        txns = [
            {
                "merchant": "COFFEE",
                "amount": -5.00,
                "date": "2025-02-15",
                "category": "Restaurants & Bars",
            }
        ]
        result = compute_spending_summary(txns, [], 2, 2025, today=date(2025, 2, 28))
        assert result["summary"]["total_spent"] == 5.00
        assert len(result["by_category"]) == 1
        assert result["by_category"][0]["percentage"] == 100.0

    def test_no_previous_month_data(self):
        result = compute_spending_summary(
            SAMPLE_TRANSACTIONS, [], 2, 2025, today=date(2025, 2, 28)
        )
        vs = result["summary"]["vs_previous_month"]
        # With no prev month data, delta equals total_spent (all increase)
        assert vs["total_spent_delta"] == result["summary"]["total_spent"]

    def test_leap_year_february(self):
        txns = [
            {
                "merchant": "TEST",
                "amount": -10.00,
                "date": "2024-02-29",
                "category": "Groceries",
            }
        ]
        result = compute_spending_summary(txns, [], 2, 2024, today=date(2024, 2, 29))
        assert len(result["daily_series"]) == 29
        assert result["meta"]["period"]["days_in_period"] == 29

    def test_uncategorized_transactions(self):
        txns = [
            {
                "merchant": "MYSTERY",
                "amount": -50.00,
                "date": "2025-02-10",
                "category": "UNKNOWN_CATEGORY",
            }
        ]
        result = compute_spending_summary(txns, [], 2, 2025, today=date(2025, 2, 28))
        assert len(result["by_category"]) == 1
        assert result["by_category"][0]["category_id"] == "cat_uncategorized"

    def test_transactions_outside_target_month_ignored(self):
        txns = [
            {
                "merchant": "IN_MONTH",
                "amount": -10.00,
                "date": "2025-02-15",
                "category": "Groceries",
            },
            {
                "merchant": "WRONG_MONTH",
                "amount": -999.00,
                "date": "2025-03-01",
                "category": "Groceries",
            },
            {
                "merchant": "ALSO_WRONG",
                "amount": -999.00,
                "date": "2025-01-31",
                "category": "Groceries",
            },
        ]
        result = compute_spending_summary(txns, [], 2, 2025, today=date(2025, 2, 28))
        assert result["summary"]["total_spent"] == 10.00


# ---------------------------------------------------------------------------
# Top Categories tests
# ---------------------------------------------------------------------------


class TestTopCategories:
    def test_returns_max_5_categories(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        assert len(result["top_categories"]) <= 5

    def test_ranked_in_order(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        ranks = [c["rank"] for c in result["top_categories"]]
        assert ranks == list(range(1, len(ranks) + 1))

    def test_amounts_descending(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        amounts = [c["amount"] for c in result["top_categories"]]
        assert amounts == sorted(amounts, reverse=True)

    def test_trend_has_3_month_spark(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        for cat in result["top_categories"]:
            assert len(cat["trend"]["spark"]) == 3
            assert len(cat["trend"]["periods"]) == 3

    def test_trend_direction_valid(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        for cat in result["top_categories"]:
            assert cat["trend"]["direction"] in ("increasing", "decreasing", "stable")

    def test_other_categories_aggregated(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        assert "count" in result["other_categories"]
        assert "amount" in result["other_categories"]

    def test_percentages_sum_correctly(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        top_pct = sum(c["percentage"] for c in result["top_categories"])
        other_pct = result["other_categories"]["percentage"]
        assert 99.0 <= top_pct + other_pct <= 101.0

    def test_total_spent_matches_sum(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        top_sum = sum(c["amount"] for c in result["top_categories"])
        other_sum = result["other_categories"]["amount"]
        assert round(top_sum + other_sum, 2) == result["total_spent"]

    def test_every_category_has_color_and_icon(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        for cat in result["top_categories"]:
            assert cat["color"].startswith("#")
            assert len(cat["icon"]) > 0

    def test_avg_transaction_computed(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        for cat in result["top_categories"]:
            expected_avg = round(cat["amount"] / max(cat["transaction_count"], 1), 2)
            assert cat["avg_transaction"] == expected_avg

    def test_budget_status_is_null(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        for cat in result["top_categories"]:
            assert cat["budget_status"] is None

    def test_meta_period_fields(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=30, today=date(2025, 2, 28)
        )
        meta = result["meta"]
        assert meta["period"]["days"] == 30
        assert meta["period"]["label"] == "Last 30 days"
        assert meta["currency"] == "USD"

    def test_category_count_total(self):
        result = compute_top_categories(
            SAMPLE_TRANSACTIONS, days=90, today=date(2025, 2, 28)
        )
        expected = len(result["top_categories"]) + result["other_categories"]["count"]
        assert result["category_count_total"] == expected


# ---------------------------------------------------------------------------
# Top Categories — edge cases
# ---------------------------------------------------------------------------


class TestTopCategoriesEdgeCases:
    def test_empty_transactions(self):
        result = compute_top_categories([], days=30, today=date(2025, 2, 28))
        assert result["total_spent"] == 0.0
        assert result["top_categories"] == []
        assert result["other_categories"]["count"] == 0

    def test_single_category(self):
        txns = [
            {
                "merchant": "STORE",
                "amount": -100.00,
                "date": "2025-02-15",
                "category": "Groceries",
            }
        ]
        result = compute_top_categories(txns, days=30, today=date(2025, 2, 28))
        assert len(result["top_categories"]) == 1
        assert result["top_categories"][0]["percentage"] == 100.0
        assert result["other_categories"]["count"] == 0

    def test_more_than_5_categories_overflow_to_other(self):
        # Use parent category names to guarantee 7 distinct category IDs
        txns = [
            {
                "merchant": "A",
                "amount": -100.00,
                "date": "2025-02-15",
                "category": "Food & Drink",
            },
            {
                "merchant": "B",
                "amount": -90.00,
                "date": "2025-02-15",
                "category": "Transport",
            },
            {
                "merchant": "C",
                "amount": -80.00,
                "date": "2025-02-15",
                "category": "Travel",
            },
            {
                "merchant": "D",
                "amount": -70.00,
                "date": "2025-02-15",
                "category": "Home & Utilities",
            },
            {
                "merchant": "E",
                "amount": -60.00,
                "date": "2025-02-15",
                "category": "Shopping",
            },
            {
                "merchant": "F",
                "amount": -50.00,
                "date": "2025-02-15",
                "category": "Personal",
            },
            {
                "merchant": "G",
                "amount": -40.00,
                "date": "2025-02-15",
                "category": "Financial Services",
            },
        ]
        result = compute_top_categories(txns, days=30, today=date(2025, 2, 28))
        assert len(result["top_categories"]) == 5
        assert result["other_categories"]["count"] == 2

    def test_recurring_dominant_detection(self):
        # Single merchant, single transaction — should be recurring
        txns = [
            {
                "merchant": "LANDLORD",
                "amount": -1500.00,
                "date": "2025-02-01",
                "category": "Rent & Mortgage",
            }
        ]
        result = compute_top_categories(txns, days=30, today=date(2025, 2, 28))
        rent_cat = result["top_categories"][0]
        assert rent_cat["is_recurring_dominant"] is True

    def test_non_recurring_many_merchants(self):
        txns = [
            {
                "merchant": "STORE_A",
                "amount": -20.00,
                "date": "2025-02-10",
                "category": "Groceries",
            },
            {
                "merchant": "STORE_B",
                "amount": -30.00,
                "date": "2025-02-12",
                "category": "Groceries",
            },
            {
                "merchant": "STORE_C",
                "amount": -25.00,
                "date": "2025-02-14",
                "category": "Groceries",
            },
            {
                "merchant": "STORE_D",
                "amount": -15.00,
                "date": "2025-02-16",
                "category": "Groceries",
            },
        ]
        result = compute_top_categories(txns, days=30, today=date(2025, 2, 28))
        groceries = result["top_categories"][0]
        assert groceries["is_recurring_dominant"] is False


# ---------------------------------------------------------------------------
# Top Categories — insight generation
# ---------------------------------------------------------------------------


class TestInsights:
    def test_spike_insight_generated(self):
        # Create data where a category spikes in the most recent month
        txns = [
            # Feb 2025 — high spending
            {
                "merchant": "STORE",
                "amount": -500.00,
                "date": "2025-02-15",
                "category": "Groceries",
            },
            # Jan 2025 — low
            {
                "merchant": "STORE",
                "amount": -50.00,
                "date": "2025-01-15",
                "category": "Groceries",
            },
            # Dec 2024 — low
            {
                "merchant": "STORE",
                "amount": -50.00,
                "date": "2024-12-15",
                "category": "Groceries",
            },
        ]
        result = compute_top_categories(txns, days=90, today=date(2025, 2, 28))
        spike_insights = [i for i in result["insights"] if i["type"] == "spike"]
        assert len(spike_insights) >= 1
        assert "up" in spike_insights[0]["message"]

    def test_concentration_insight_generated(self):
        # One category dominates > 35%
        txns = [
            {
                "merchant": "LANDLORD",
                "amount": -2000.00,
                "date": "2025-02-01",
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "COFFEE",
                "amount": -5.00,
                "date": "2025-02-15",
                "category": "Restaurants & Bars",
            },
        ]
        result = compute_top_categories(txns, days=30, today=date(2025, 2, 28))
        conc = [i for i in result["insights"] if i["type"] == "concentration"]
        assert len(conc) >= 1
        assert "%" in conc[0]["message"]

    def test_no_insights_when_spending_is_even(self):
        # Roughly even spending, no spikes, no concentration
        txns = [
            {
                "merchant": "A",
                "amount": -30.00,
                "date": "2025-02-10",
                "category": "Groceries",
            },
            {
                "merchant": "B",
                "amount": -30.00,
                "date": "2025-02-10",
                "category": "Taxi & Ride-sharing",
            },
            {
                "merchant": "C",
                "amount": -30.00,
                "date": "2025-02-10",
                "category": "Subscriptions",
            },
            # Stable across months
            {
                "merchant": "A",
                "amount": -30.00,
                "date": "2025-01-10",
                "category": "Groceries",
            },
            {
                "merchant": "B",
                "amount": -30.00,
                "date": "2025-01-10",
                "category": "Taxi & Ride-sharing",
            },
            {
                "merchant": "C",
                "amount": -30.00,
                "date": "2025-01-10",
                "category": "Subscriptions",
            },
            {
                "merchant": "A",
                "amount": -30.00,
                "date": "2024-12-10",
                "category": "Groceries",
            },
            {
                "merchant": "B",
                "amount": -30.00,
                "date": "2024-12-10",
                "category": "Taxi & Ride-sharing",
            },
            {
                "merchant": "C",
                "amount": -30.00,
                "date": "2024-12-10",
                "category": "Subscriptions",
            },
        ]
        result = compute_top_categories(txns, days=90, today=date(2025, 2, 28))
        assert len(result["insights"]) == 0

    def test_insight_fields_complete(self):
        txns = [
            {
                "merchant": "LANDLORD",
                "amount": -2000.00,
                "date": "2025-02-01",
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "COFFEE",
                "amount": -5.00,
                "date": "2025-02-15",
                "category": "Restaurants & Bars",
            },
        ]
        result = compute_top_categories(txns, days=30, today=date(2025, 2, 28))
        for insight in result["insights"]:
            assert "type" in insight
            assert "severity" in insight
            assert insight["severity"] in ("info", "warning")
            assert "message" in insight
            assert "category_id" in insight
            assert "icon" in insight


# ---------------------------------------------------------------------------
# Warnings History tests
# ---------------------------------------------------------------------------


class TestWarningsHistory:
    def test_risk_summary_counts_correct(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        summary = result["risk_summary"]
        assert summary["total_warnings"] == 3
        assert summary["by_level"]["HIGH"]["count"] == 1
        assert summary["by_level"]["MEDIUM"]["count"] == 1
        assert summary["by_level"]["LOW"]["count"] == 1

    def test_risk_summary_percentages(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        for level_data in result["risk_summary"]["by_level"].values():
            assert 0.0 <= level_data["percentage"] <= 100.0
            assert level_data["color"].startswith("#")

    def test_warnings_have_colors(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        for w in result["warnings"]:
            assert w["risk_color"].startswith("#")
            assert w["risk_icon"] in ("shield-alert", "alert-triangle", "info")

    def test_date_labels_present(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        for w in result["warnings"]:
            assert len(w["date_label"]) > 0

    def test_date_label_today(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        first = result["warnings"][0]
        assert first["date_label"] == "Today"

    def test_date_label_days_ago(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        second = result["warnings"][1]  # 6 days ago
        assert second["date_label"] == "6 days ago"

    def test_date_label_older_than_7_days(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        third = result["warnings"][2]  # Jan 14 — more than 7 days ago
        assert third["date_label"] == "Jan 14"

    def test_pagination_metadata(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=2,
            offset=0,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        assert result["meta"]["pagination"]["total"] == 3
        assert result["meta"]["pagination"]["has_more"] is True
        assert len(result["warnings"]) == 2

    def test_pagination_offset(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=2,
            offset=2,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        assert result["meta"]["pagination"]["has_more"] is False
        assert len(result["warnings"]) == 1

    def test_pagination_beyond_end(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            offset=100,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        assert len(result["warnings"]) == 0
        assert result["meta"]["pagination"]["has_more"] is False

    def test_calendar_heatmap_present(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        assert len(result["calendar_heatmap"]) > 0
        for entry in result["calendar_heatmap"]:
            assert "date" in entry
            assert "warning_count" in entry

    def test_calendar_heatmap_stops_at_today(self):
        now = datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc)
        result = compile_warnings_history(SAMPLE_WARNINGS, limit=10, now=now)
        dates = [e["date"] for e in result["calendar_heatmap"]]
        assert all(d <= "2025-02-17" for d in dates)
        assert len(dates) == 17  # Feb 1–17

    def test_calendar_heatmap_max_severity(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        feb17 = next(e for e in result["calendar_heatmap"] if e["date"] == "2025-02-17")
        assert feb17["warning_count"] == 1
        assert feb17["max_severity"] == "HIGH"

    def test_by_source_counts(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        by_source = result["risk_summary"]["by_source"]
        assert by_source["cash_flow"] == 2
        assert by_source["bnpl"] == 1

    def test_trend_last_30d(self):
        result = compile_warnings_history(
            SAMPLE_WARNINGS,
            limit=10,
            now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc),
        )
        trend = result["risk_summary"]["trend_last_30d"]
        assert "warnings_count" in trend
        assert "vs_previous_30d" in trend
        assert trend["vs_previous_30d"]["direction"] in (
            "increased",
            "decreased",
            "unchanged",
        )


# ---------------------------------------------------------------------------
# Warnings History — edge cases
# ---------------------------------------------------------------------------


class TestWarningsHistoryEdgeCases:
    def test_empty_warnings(self):
        result = compile_warnings_history(
            [], limit=10, now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc)
        )
        assert result["risk_summary"]["total_warnings"] == 0
        assert result["warnings"] == []
        assert result["risk_summary"]["by_level"]["HIGH"]["count"] == 0
        assert result["risk_summary"]["by_level"]["MEDIUM"]["count"] == 0
        assert result["risk_summary"]["by_level"]["LOW"]["count"] == 0

    def test_all_same_risk_level(self):
        warnings = [
            {**SAMPLE_WARNINGS[0], "id": f"w{i}", "risk_level": "HIGH"}
            for i in range(5)
        ]
        result = compile_warnings_history(
            warnings, limit=10, now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc)
        )
        assert result["risk_summary"]["by_level"]["HIGH"]["count"] == 5
        assert result["risk_summary"]["by_level"]["HIGH"]["percentage"] == 100.0
        assert result["risk_summary"]["by_level"]["MEDIUM"]["count"] == 0
        assert result["risk_summary"]["by_level"]["LOW"]["count"] == 0

    def test_yesterday_label(self):
        warnings = [
            {
                "id": "w_yesterday",
                "timestamp": "2025-02-16T10:00:00Z",
                "source": "cash_flow",
                "risk_level": "LOW",
                "title": "Test",
                "message": "Test",
                "context": {},
                "outcome": {},
            }
        ]
        result = compile_warnings_history(
            warnings, limit=10, now=datetime(2025, 2, 17, 18, 0, 0, tzinfo=timezone.utc)
        )
        assert result["warnings"][0]["date_label"] == "Yesterday"


# ---------------------------------------------------------------------------
# Integration tests — TestClient against real endpoints + mock data
# ---------------------------------------------------------------------------


class TestSpendingSummaryEndpoint:
    def test_200_valid_request(self):
        resp = client.get(
            "/api/insights/spending-summary",
            params={
                "user_id": "user_marcus",
                "month": 3,
                "year": 2026,
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["meta"]["user_id"] == "user_marcus"
        assert data["meta"]["period"]["month"] == 3
        assert data["summary"]["total_spent"] > 0
        assert data["summary"]["total_income"] > 0

    def test_user_id_in_response_meta(self):
        resp = client.get(
            "/api/insights/spending-summary",
            params={
                "user_id": "user_sarah",
                "month": 3,
                "year": 2026,
            },
        )
        assert resp.status_code == 200
        assert resp.json()["meta"]["user_id"] == "user_sarah"

    def test_404_unknown_user(self):
        resp = client.get(
            "/api/insights/spending-summary",
            params={
                "user_id": "user_nonexistent",
                "month": 3,
                "year": 2026,
            },
        )
        assert resp.status_code == 404

    def test_422_missing_required_params(self):
        resp = client.get("/api/insights/spending-summary")
        assert resp.status_code == 422

    def test_422_month_out_of_range(self):
        resp = client.get(
            "/api/insights/spending-summary",
            params={
                "user_id": "user_marcus",
                "month": 13,
                "year": 2026,
            },
        )
        assert resp.status_code == 422

    def test_response_has_all_top_level_keys(self):
        resp = client.get(
            "/api/insights/spending-summary",
            params={
                "user_id": "user_marcus",
                "month": 3,
                "year": 2026,
            },
        )
        data = resp.json()
        assert "meta" in data
        assert "summary" in data
        assert "by_category" in data
        assert "daily_series" in data
        assert "day_of_week_pattern" in data

    def test_categories_have_subcategories_and_merchants(self):
        resp = client.get(
            "/api/insights/spending-summary",
            params={
                "user_id": "user_marcus",
                "month": 3,
                "year": 2026,
            },
        )
        data = resp.json()
        for cat in data["by_category"]:
            assert "subcategories" in cat
            assert "top_merchants" in cat
            assert "vs_previous_month" in cat

    def test_all_three_demo_users(self):
        for user in ["user_marcus", "user_sarah", "user_bob"]:
            resp = client.get(
                "/api/insights/spending-summary",
                params={
                    "user_id": user,
                    "month": 3,
                    "year": 2026,
                },
            )
            assert resp.status_code == 200, f"Failed for {user}"
            assert resp.json()["summary"]["total_spent"] > 0, f"No spending for {user}"


class TestTopCategoriesEndpoint:
    def test_200_valid_request(self):
        resp = client.get(
            "/api/insights/top-categories",
            params={
                "user_id": "user_marcus",
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["meta"]["user_id"] == "user_marcus"
        assert data["total_spent"] > 0
        assert len(data["top_categories"]) > 0

    def test_custom_days_param(self):
        resp = client.get(
            "/api/insights/top-categories",
            params={
                "user_id": "user_marcus",
                "days": 90,
            },
        )
        assert resp.status_code == 200
        assert resp.json()["meta"]["period"]["days"] == 90

    def test_default_days_is_30(self):
        resp = client.get(
            "/api/insights/top-categories",
            params={
                "user_id": "user_marcus",
            },
        )
        assert resp.status_code == 200
        assert resp.json()["meta"]["period"]["days"] == 30

    def test_404_unknown_user(self):
        resp = client.get(
            "/api/insights/top-categories",
            params={
                "user_id": "user_nonexistent",
            },
        )
        assert resp.status_code == 404

    def test_sparklines_present(self):
        resp = client.get(
            "/api/insights/top-categories",
            params={
                "user_id": "user_marcus",
                "days": 90,
            },
        )
        data = resp.json()
        for cat in data["top_categories"]:
            assert len(cat["trend"]["spark"]) == 3
            assert all(isinstance(v, (int, float)) for v in cat["trend"]["spark"])

    def test_insights_are_list(self):
        resp = client.get(
            "/api/insights/top-categories",
            params={
                "user_id": "user_marcus",
            },
        )
        assert isinstance(resp.json()["insights"], list)

    def test_all_three_demo_users(self):
        for user in ["user_marcus", "user_sarah", "user_bob"]:
            resp = client.get(
                "/api/insights/top-categories",
                params={
                    "user_id": user,
                },
            )
            assert resp.status_code == 200, f"Failed for {user}"


class TestWarningsHistoryEndpoint:
    def test_200_valid_request(self):
        resp = client.get(
            "/api/insights/warnings-history",
            params={
                "user_id": "user_marcus",
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["meta"]["user_id"] == "user_marcus"
        assert data["risk_summary"]["total_warnings"] > 0

    def test_pagination_params(self):
        resp = client.get(
            "/api/insights/warnings-history",
            params={
                "user_id": "user_marcus",
                "limit": 2,
                "offset": 0,
            },
        )
        data = resp.json()
        assert len(data["warnings"]) <= 2
        assert data["meta"]["pagination"]["limit"] == 2

    def test_404_unknown_user(self):
        resp = client.get(
            "/api/insights/warnings-history",
            params={
                "user_id": "user_nonexistent",
            },
        )
        assert resp.status_code == 404

    def test_warning_fields_complete(self):
        resp = client.get(
            "/api/insights/warnings-history",
            params={
                "user_id": "user_marcus",
            },
        )
        data = resp.json()
        for w in data["warnings"]:
            assert "id" in w
            assert "timestamp" in w
            assert "date_label" in w
            assert "risk_level" in w
            assert w["risk_level"] in ("HIGH", "MEDIUM", "LOW")
            assert "risk_color" in w
            assert "risk_icon" in w
            assert "title" in w
            assert "message" in w

    def test_calendar_heatmap_in_response(self):
        resp = client.get(
            "/api/insights/warnings-history",
            params={
                "user_id": "user_marcus",
            },
        )
        data = resp.json()
        assert "calendar_heatmap" in data
        assert len(data["calendar_heatmap"]) > 0

    def test_risk_summary_structure(self):
        resp = client.get(
            "/api/insights/warnings-history",
            params={
                "user_id": "user_marcus",
            },
        )
        summary = resp.json()["risk_summary"]
        assert "by_level" in summary
        assert "HIGH" in summary["by_level"]
        assert "MEDIUM" in summary["by_level"]
        assert "LOW" in summary["by_level"]
        assert "by_source" in summary
        assert "trend_last_30d" in summary

    def test_all_three_demo_users(self):
        for user in ["user_marcus", "user_sarah", "user_bob"]:
            resp = client.get(
                "/api/insights/warnings-history",
                params={
                    "user_id": user,
                },
            )
            assert resp.status_code == 200, f"Failed for {user}"
