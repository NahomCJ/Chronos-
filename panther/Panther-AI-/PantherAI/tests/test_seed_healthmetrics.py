"""
tests/test_seed_healthmetrics.py
================================
Validates the Phase-1 (JSON) output of the HealthMetrics seed generator.

Three required tests (see tasks/todo.md §TASK 1.2):
  1. Perfil A produces a stable paycheck (single payer, fixed amount ±2 %).
  2. Perfil B produces irregular incomes (multiple payers, varying amounts).
  3. The lumpy expense appears exactly once across the 6 months.

Plus a "numeric oracle" test: for user_marcus / Perfil A, the totals match
Apéndice A (ingreso ~2200 €/mes, recurrente ~905 €/mes).
"""

from __future__ import annotations

import statistics
from collections import Counter
from datetime import date

import pytest

from services.banking.seed_healthmetrics import (
    LUMPY_MERCHANT,
    PROFILE_A_PAYER,
    PROFILE_A_SALARY_BASE,
    generate_transactions,
    seed_six_months,
)


FIXED_TODAY = date(2026, 4, 15)


# ---------------------------------------------------------------------------
# Test 1 — Perfil A: stable paycheck
# ---------------------------------------------------------------------------
def test_profile_a_produces_stable_salary():
    batches = generate_transactions("user_marcus", "A", today=FIXED_TODAY, seed=42)
    incomes = batches["income"]

    # Exactly 6 paychecks across 6 months.
    assert len(incomes) == 6

    # Single payer.
    payers = {t["merchant_name"] for t in incomes}
    assert payers == {PROFILE_A_PAYER}

    # All amounts within ±2 % of base.
    amounts = [t["amount"] for t in incomes]
    for a in amounts:
        assert abs(a - PROFILE_A_SALARY_BASE) / PROFILE_A_SALARY_BASE <= 0.02

    # Coefficient of variation < 3 % — i.e. "stable".
    mean = statistics.fmean(amounts)
    stdev = statistics.pstdev(amounts)
    assert stdev / mean < 0.03


# ---------------------------------------------------------------------------
# Test 2 — Perfil B: irregular incomes
# ---------------------------------------------------------------------------
def test_profile_b_produces_irregular_income():
    batches = generate_transactions("user_freelance", "B", today=FIXED_TODAY, seed=42)
    incomes = batches["income"]

    # Perfil B has 4-8 incomes/month → [24, 48] total over 6 months.
    assert 4 * 6 <= len(incomes) <= 8 * 6

    # Multiple distinct payers.
    payers = {t["merchant_name"] for t in incomes}
    assert len(payers) >= 3

    # Coefficient of variation clearly higher than Perfil A (log-normal tails).
    amounts = [t["amount"] for t in incomes]
    mean = statistics.fmean(amounts)
    stdev = statistics.pstdev(amounts)
    assert stdev / mean > 0.2


# ---------------------------------------------------------------------------
# Test 3 — Lumpy expense appears exactly once
# ---------------------------------------------------------------------------
@pytest.mark.parametrize("profile", ["A", "B"])
def test_lumpy_expense_appears_exactly_once(profile):
    batches = generate_transactions("user_marcus", profile, today=FIXED_TODAY, seed=42)
    all_txns = [t for group in batches.values() for t in group]

    lumpy = [t for t in all_txns if t["merchant_name"] == LUMPY_MERCHANT]
    assert len(lumpy) == 1

    # And it lives in the recorded "lumpy" slot of the breakdown.
    assert len(batches["lumpy"]) == 1
    assert batches["lumpy"][0]["merchant_name"] == LUMPY_MERCHANT


# ---------------------------------------------------------------------------
# Test 4 — Apéndice A oracle: Marcus (Perfil A) totals
# ---------------------------------------------------------------------------
def test_apendice_a_totals_for_marcus():
    batches = generate_transactions("user_marcus", "A", today=FIXED_TODAY, seed=42)

    avg_income = sum(t["amount"] for t in batches["income"]) / 6
    assert 2100 <= avg_income <= 2300  # Apéndice A target: ~2200

    # Recurring monthly commitment = rent + subs + utility per month.
    rent_per_month = sum(-t["amount"] for t in batches["rent"]) / 6
    subs_per_month = sum(-t["amount"] for t in batches["subscriptions"]) / 6
    util_per_month = sum(-t["amount"] for t in batches["utility"]) / 6
    recurring = rent_per_month + subs_per_month + util_per_month

    # Apéndice A target: ~905 €. Allow 1 € for float rounding.
    assert 904 <= recurring <= 906

    # Variable spend sanity: 40-80 txns/mes target → [240, 480] over 6 months.
    variable = batches["variable"]
    assert 240 <= len(variable) <= 480


# ---------------------------------------------------------------------------
# Test 5 — JSON output round-trip (Phase 1 path)
# ---------------------------------------------------------------------------
def test_seed_six_months_writes_json(tmp_path, monkeypatch):
    import services.banking.seed_healthmetrics as mod

    monkeypatch.setattr(mod, "MOCK_DATA_DIR", tmp_path)
    report = seed_six_months("user_marcus", "A", output="json", today=FIXED_TODAY)

    assert report.output_path is not None
    out_file = tmp_path / "seed_healthmetrics_user_marcus_A.json"
    assert out_file.exists()

    import json

    data = json.loads(out_file.read_text())
    assert data["report"]["transactions_inserted"] == report.transactions_inserted
    assert len(data["transactions"]) == report.transactions_inserted

    # Every transaction carries a subcategory and a date.
    sub_counts = Counter(t["subcategory"] for t in data["transactions"])
    assert sub_counts["sub_salary"] == 6
    assert sub_counts["sub_rent_mortgage"] == 6
    assert sub_counts["sub_insurance"] == 1
