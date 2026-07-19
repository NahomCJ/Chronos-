"""
services/banking/seed_healthmetrics.py
======================================
Generates 6 months of realistic transactions for a demo user so the
HealthMetrics pipeline (days 2-5 of the sprint) can validate against a
known oracle — the numeric example from Apéndice A of the HealthMetrics
spec (tasks/temp_HEALTHMETRICS.md, §Apéndice A).

TWO PHASES
----------
Phase 1 (output="json"): writes the transaction batch to a local JSON file
under datasets/mock/. Fast iteration, no DB dependency.

Phase 2 (output="supabase"): upserts the users row, resolves the user's
account_id, and batch-inserts the transactions into public.transactions.
Requires SUPABASE_URL + SUPABASE_KEY in .env and the baseline schema
(20260413_base_schema.sql) already applied.

TARGET NUMBERS (Perfil A, user_marcus — Apéndice A)
---------------------------------------------------
- Monthly income ~ 2.200 €  (12 paycheck payments via single payer)
- Rent 700 €/mes (day 1-3)
- Subscriptions ~85 €/mes (Netflix 13.99 + Spotify 10.99 + Gym 39.90 + Vodafone 20.13)
- Utility 120 €/mes (IBERDROLA — matches the "seguros amortizados 120€"
  slot in Apéndice A so total recurring ≈ 905 €/mes)
- Variable spend ~800 €/mes via 40-80 txns/mes (gamma amounts)
- Exactly 1 lumpy yearly charge (~500 € insurance) inside the 6-month window

Perfil B reuses the same rent/subs/utility/lumpy, but ingresos vienen de
pagadores variables con importes log-normal (4-8 ingresos/mes).
"""

from __future__ import annotations

import argparse
import json
import math
import random
import uuid
from dataclasses import dataclass, field
from datetime import date, timedelta
from pathlib import Path
from typing import Any, Dict, List, Literal, Optional

from core.logger import log

# ---------------------------------------------------------------------------
# Configuration (all values come from Apéndice A — do not tune without
# updating the spec).
# ---------------------------------------------------------------------------

PROFILE_A_PAYER = "ACME CORP NOMINA"
PROFILE_A_SALARY_BASE = 2200.00  # €
PROFILE_A_SALARY_JITTER = 0.02  # ±2 %
PROFILE_A_PAY_DAY = 27  # nómina day of month
PROFILE_A_PAY_DAY_JITTER = 2  # ± days

PROFILE_B_PAYERS = [
    "CLIENTE ACME SL",
    "FREELANCE BILBAO",
    "ESTUDIO LUNA",
    "CONSULTORA NORTE",
    "CLIENTE MARITIMO SA",
    "COOP GRANADA",
    "BRAND STUDIO",
    "AGENCIA AZUL",
]
PROFILE_B_MIN_MONTHLY_INCOMES = 4
PROFILE_B_MAX_MONTHLY_INCOMES = 8
# log-normal params chosen so mean monthly ≈ 2.200 € across 4-8 incomes
PROFILE_B_LOGNORM_MU = math.log(400)
PROFILE_B_LOGNORM_SIGMA = 0.5

RENT_AMOUNT = 700.00
RENT_MERCHANT = "INMOBILIARIA SOL"
RENT_DAY = 2

SUBSCRIPTIONS = [
    # (merchant, amount, day_of_month)
    ("NETFLIX", 13.99, 5),
    ("SPOTIFY", 10.99, 10),
    ("BASIC FIT", 39.90, 15),  # "Gym €39.90"
    ("VODAFONE", 20.13, 20),  # lifts subs total to ~85 €
]

UTILITY = ("IBERDROLA", 120.00, 8)  # 120 €/mes — matches the "120 €" slot
# in Apéndice A (seguros amortizados).

# ADR: subcategory IDs below are hardcoded strings rather than imported from
# services/TC-TransactionClassifier/classifier/taxonomy.py. Rationale: the
# taxonomy module loads the 44-class catalog at import time; pulling it into
# a seed script couples data-generation startup to the classifier stack, which
# makes the CLI slow and makes test isolation brittle. The IDs are a stable
# public contract of the classifier (they live in DB rows and API responses),
# so copying them here is cheap. If the taxonomy renames an ID, both sides
# break at once — which is what we want.
VARIABLE_MERCHANTS: List[tuple[str, str]] = [
    ("MERCADONA", "sub_groceries"),
    ("CARREFOUR", "sub_groceries"),
    ("LIDL", "sub_groceries"),
    ("STARBUCKS", "sub_restaurants_bars"),
    ("BURGER KING", "sub_restaurants_bars"),
    ("VIPS", "sub_restaurants_bars"),
    ("GLOVO", "sub_delivery"),
    ("UBER EATS", "sub_delivery"),
    ("UBER", "sub_taxi_ride"),
    ("CABIFY", "sub_taxi_ride"),
    ("METRO MADRID", "sub_public_transport"),
    ("RENFE", "sub_public_transport"),
    ("REPSOL", "sub_fuel_tolls"),
    ("AMAZON", "sub_home_general"),
    ("ZARA", "sub_fashion"),
    ("DECATHLON", "sub_fitness_gym"),
    ("FARMACIA CENTRAL", "sub_medical_pharmacy"),
]
VARIABLE_TARGET_MONTHLY = 800.00
VARIABLE_MIN_TXNS_MONTH = 40
VARIABLE_MAX_TXNS_MONTH = 80
VARIABLE_GAMMA_SHAPE = 2.0
VARIABLE_GAMMA_SCALE = 7.0  # mean = shape*scale = 14 €/tx → ~840 €/mes @ 60 tx

LUMPY_MERCHANT = "MAPFRE SEGUROS"
LUMPY_AMOUNT_MIN = 420.00
LUMPY_AMOUNT_MAX = 580.00
LUMPY_SUBCATEGORY = "sub_insurance"

MOCK_DATA_DIR = Path(__file__).resolve().parents[2] / "datasets" / "mock"


# ---------------------------------------------------------------------------
# Types
# ---------------------------------------------------------------------------
@dataclass
class SeedReport:
    """Return value of `seed_six_months`. Also the JSON shape dumped to disk in Phase 1.

    Attributes:
        user_id (str): The user the seed was generated for, e.g. "user_marcus".
        profile (Literal["A","B"]): "A" for salaried, "B" for freelance.
        months_generated (int): Usually 6. Reflects the `months` argument.
        transactions_inserted (int): Total rows across every category (income,
            rent, subs, utility, variable, lumpy).
        breakdown (Dict[str, int]): Row count per category. Keys are the six
            strings in the previous sentence, in that order.
        output_path (Optional[str]): Absolute path to the JSON file written in
            Phase 1. `None` when output="supabase".
        account_id (Optional[str]): UUID of the account the rows were attached
            to in Phase 2. `None` when output="json".
    """

    user_id: str
    profile: Literal["A", "B"]
    months_generated: int
    transactions_inserted: int
    breakdown: Dict[str, int] = field(default_factory=dict)
    output_path: Optional[str] = None
    account_id: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "user_id": self.user_id,
            "profile": self.profile,
            "months_generated": self.months_generated,
            "transactions_inserted": self.transactions_inserted,
            "breakdown": self.breakdown,
            "output_path": self.output_path,
            "account_id": self.account_id,
        }


# ---------------------------------------------------------------------------
# Date helpers
# ---------------------------------------------------------------------------
def _month_starts(today: date, months: int) -> List[date]:
    """Returns the first day of the last `months` months, oldest first."""
    starts: List[date] = []
    m = today.replace(day=1)
    for _ in range(months):
        starts.append(m)
        m = (m - timedelta(days=1)).replace(day=1)
    starts.reverse()
    return starts


def _clamp_day(year: int, month: int, day: int) -> date:
    """Clamps `day` to a valid day for (year, month)."""
    import calendar as _cal

    last = _cal.monthrange(year, month)[1]
    return date(year, month, min(day, last))


# ---------------------------------------------------------------------------
# Transaction factory
# ---------------------------------------------------------------------------
def _txn(
    *,
    account_id: Optional[str],
    merchant: str,
    amount: float,
    on: date,
    subcategory: str,
) -> Dict[str, Any]:
    return {
        "id": str(uuid.uuid4()),
        "account_id": account_id,
        "merchant_name": merchant,
        "amount": round(amount, 2),
        "date": on.isoformat(),
        "subcategory": subcategory,
        "category_confidence": 1.0,  # mock data is by definition ground truth
        "category_source": "seed_healthmetrics",
        "user_corrected": False,
    }


# ---------------------------------------------------------------------------
# Generators
# ---------------------------------------------------------------------------
def _gen_income_profile_a(
    rng: random.Random, month_starts: List[date], account_id: Optional[str]
) -> List[Dict[str, Any]]:
    """Perfil A: single payer, importe fijo ±2%, same day ±2."""
    out: List[Dict[str, Any]] = []
    for ms in month_starts:
        day = PROFILE_A_PAY_DAY + rng.randint(
            -PROFILE_A_PAY_DAY_JITTER, PROFILE_A_PAY_DAY_JITTER
        )
        amount = PROFILE_A_SALARY_BASE * (
            1 + rng.uniform(-PROFILE_A_SALARY_JITTER, PROFILE_A_SALARY_JITTER)
        )
        out.append(
            _txn(
                account_id=account_id,
                merchant=PROFILE_A_PAYER,
                amount=+amount,
                on=_clamp_day(ms.year, ms.month, day),
                subcategory="sub_salary",
            )
        )
    return out


def _gen_income_profile_b(
    rng: random.Random, month_starts: List[date], account_id: Optional[str]
) -> List[Dict[str, Any]]:
    """Perfil B: 4-8 ingresos/mes de pagadores variables, importes log-normal."""
    out: List[Dict[str, Any]] = []
    for ms in month_starts:
        n = rng.randint(PROFILE_B_MIN_MONTHLY_INCOMES, PROFILE_B_MAX_MONTHLY_INCOMES)
        for _ in range(n):
            amount = rng.lognormvariate(PROFILE_B_LOGNORM_MU, PROFILE_B_LOGNORM_SIGMA)
            day = rng.randint(1, 28)
            out.append(
                _txn(
                    account_id=account_id,
                    merchant=rng.choice(PROFILE_B_PAYERS),
                    amount=+amount,
                    on=_clamp_day(ms.year, ms.month, day),
                    subcategory="sub_side_hustle",
                )
            )
    return out


def _gen_rent(
    month_starts: List[date], account_id: Optional[str]
) -> List[Dict[str, Any]]:
    return [
        _txn(
            account_id=account_id,
            merchant=RENT_MERCHANT,
            amount=-RENT_AMOUNT,
            on=_clamp_day(ms.year, ms.month, RENT_DAY),
            subcategory="sub_rent_mortgage",
        )
        for ms in month_starts
    ]


def _gen_subscriptions(
    month_starts: List[date], account_id: Optional[str]
) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for ms in month_starts:
        for merchant, amount, day in SUBSCRIPTIONS:
            out.append(
                _txn(
                    account_id=account_id,
                    merchant=merchant,
                    amount=-amount,
                    on=_clamp_day(ms.year, ms.month, day),
                    subcategory="sub_subscriptions",
                )
            )
    return out


def _gen_utility(
    month_starts: List[date], account_id: Optional[str]
) -> List[Dict[str, Any]]:
    merchant, amount, day = UTILITY
    return [
        _txn(
            account_id=account_id,
            merchant=merchant,
            amount=-amount,
            on=_clamp_day(ms.year, ms.month, day),
            subcategory="sub_utility_bills",
        )
        for ms in month_starts
    ]


def _gen_variable(
    rng: random.Random, month_starts: List[date], account_id: Optional[str]
) -> List[Dict[str, Any]]:
    """Variable spend: 40-80 txns/mes, amounts gamma-distributed, merchants
    sampled from VARIABLE_MERCHANTS."""
    out: List[Dict[str, Any]] = []
    for ms in month_starts:
        n = rng.randint(VARIABLE_MIN_TXNS_MONTH, VARIABLE_MAX_TXNS_MONTH)
        for _ in range(n):
            amount = rng.gammavariate(VARIABLE_GAMMA_SHAPE, VARIABLE_GAMMA_SCALE)
            # Clip extreme tails — real checking accounts do not swallow
            # 500 € grocery runs in one shot.
            amount = max(2.0, min(amount, 120.0))
            merchant, sub = rng.choice(VARIABLE_MERCHANTS)
            day = rng.randint(1, 28)
            out.append(
                _txn(
                    account_id=account_id,
                    merchant=merchant,
                    amount=-amount,
                    on=_clamp_day(ms.year, ms.month, day),
                    subcategory=sub,
                )
            )
    return out


def _gen_lumpy(
    rng: random.Random, month_starts: List[date], account_id: Optional[str]
) -> List[Dict[str, Any]]:
    """Exactly 1 lumpy expense (yearly insurance) inside the 6-month window."""
    chosen = rng.choice(month_starts)
    day = rng.randint(5, 25)
    amount = rng.uniform(LUMPY_AMOUNT_MIN, LUMPY_AMOUNT_MAX)
    return [
        _txn(
            account_id=account_id,
            merchant=LUMPY_MERCHANT,
            amount=-amount,
            on=_clamp_day(chosen.year, chosen.month, day),
            subcategory=LUMPY_SUBCATEGORY,
        )
    ]


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------
def generate_transactions(
    user_id: str,
    profile: Literal["A", "B"],
    *,
    months: int = 6,
    today: Optional[date] = None,
    seed: int = 42,
    account_id: Optional[str] = None,
) -> Dict[str, List[Dict[str, Any]]]:
    """Generates 6 months of realistic transactions for one user, in memory only.

    Pure and deterministic — does not touch the filesystem or Supabase.
    Reused by `seed_six_months` and by the test suite.

    Args:
        user_id (str): User identifier, e.g. "user_marcus". Used only for
            logging — the returned rows do not contain it (they're keyed by
            `account_id` like the rest of `public.transactions`).
        profile (Literal["A","B"]): "A" generates a single-payer monthly
            paycheck (~2200 € ±2 %). "B" generates 4-8 irregular incomes/mes
            from varied payers with log-normal amounts.
        months (int): Number of months to generate, oldest first. Defaults to 6.
        today (Optional[date]): Anchor date for the 6-month window. Defaults
            to `date.today()`. Pass a fixed date in tests to stay deterministic.
        seed (int): PRNG seed. Same seed → same batches (modulo the `uuid.uuid4`
            non-determinism called out in TASK 2.5). Defaults to 42.
        account_id (Optional[str]): Pre-resolved account UUID to attach to
            every row. `None` when the caller does not yet have one (Phase 1).

    Returns:
        Dict[str, List[Dict]]: Six keys, each a list of transaction rows:
            "income", "rent", "subscriptions", "utility", "variable", "lumpy".
            Each row has the full `public.transactions` shape (id, account_id,
            merchant_name, amount, date, subcategory, category_confidence,
            category_source, user_corrected).

    Raises:
        ValueError: If `profile` is not "A" or "B".
    """
    if profile not in ("A", "B"):
        raise ValueError(f"profile must be 'A' or 'B', got {profile!r}")

    rng = random.Random(seed)
    today = today or date.today()
    starts = _month_starts(today, months)

    income_fn = _gen_income_profile_a if profile == "A" else _gen_income_profile_b
    return {
        "income": income_fn(rng, starts, account_id),
        "rent": _gen_rent(starts, account_id),
        "subscriptions": _gen_subscriptions(starts, account_id),
        "utility": _gen_utility(starts, account_id),
        "variable": _gen_variable(rng, starts, account_id),
        "lumpy": _gen_lumpy(rng, starts, account_id),
    }


def seed_six_months(
    user_id: str,
    profile: Literal["A", "B"],
    *,
    output: Literal["json", "supabase"] = "json",
    months: int = 6,
    seed: int = 42,
    today: Optional[date] = None,
) -> SeedReport:
    """Main entry point — generates 6 months of transactions and writes them to disk or Supabase.

    This is the contract that downstream sprint tasks (2.1 detección de perfil,
    2.2 Burn Rate, 3.1 Runway, etc.) depend on. The `SeedReport` shape is
    stable; the underlying row shape matches `public.transactions`.

    Args:
        user_id (str): User identifier, e.g. "user_marcus". When
            `output="supabase"`, the user (and one account) is upserted if
            missing before rows are inserted.
        profile (Literal["A","B"]): See `generate_transactions`.
        output (Literal["json","supabase"]): "json" writes to
            `datasets/mock/seed_healthmetrics_<user>_<profile>.json` and is
            safe offline. "supabase" inserts into `public.transactions` and
            requires SUPABASE_URL + SUPABASE_KEY in `.env`. Defaults to "json".
        months (int): Number of months to generate. Defaults to 6.
        seed (int): PRNG seed. Defaults to 42.
        today (Optional[date]): Anchor date for the 6-month window. Defaults
            to `date.today()`.

    Returns:
        SeedReport: A fully populated report — see the `SeedReport` dataclass
            for field semantics. In Phase 1 `output_path` is set and
            `account_id` is None; in Phase 2 it is the opposite.

    Raises:
        ValueError: If `profile` is not "A"/"B" or `output` is not "json"/"supabase".
        RuntimeError: If `output="supabase"` but the Supabase client cannot be
            built (missing env vars or the `supabase` package is not installed).
            Also raised by the insert path on any Supabase-side error once
            TASK 2.5 lands; until then, insert failures can still surface as
            silent partial writes — see `tasks/SPRINT_HEALTHMETRICS.md` §2.5.
    """
    # ADR: account_id is resolved up-front (before generating rows) so every
    # row carries the right FK at construction time. This means the same batch
    # can be dumped to JSON *or* inserted into Supabase without a second pass
    # to rewrite foreign keys. It costs one extra DB round-trip on the
    # supabase path but keeps `generate_transactions` pure.
    account_id: Optional[str] = None
    if output == "supabase":
        account_id = _ensure_user_and_account(user_id)

    batches = generate_transactions(
        user_id=user_id,
        profile=profile,
        months=months,
        today=today,
        seed=seed,
        account_id=account_id,
    )

    all_txns: List[Dict[str, Any]] = []
    for group in batches.values():
        all_txns.extend(group)

    report = SeedReport(
        user_id=user_id,
        profile=profile,
        months_generated=months,
        transactions_inserted=len(all_txns),
        breakdown={k: len(v) for k, v in batches.items()},
        account_id=account_id,
    )

    if output == "json":
        MOCK_DATA_DIR.mkdir(parents=True, exist_ok=True)
        out_path = MOCK_DATA_DIR / f"seed_healthmetrics_{user_id}_{profile}.json"
        payload = {
            "report": report.to_dict(),
            "transactions": all_txns,
        }
        out_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False))
        report.output_path = str(out_path)
        log.result(
            "seed_healthmetrics.seed_six_months",
            duration_ms=0.0,
            sink="json",
            user_id=user_id,
            profile=profile,
            path=str(out_path),
            count=len(all_txns),
        )

    elif output == "supabase":
        _insert_transactions_supabase(all_txns)
        log.result(
            "seed_healthmetrics.seed_six_months",
            duration_ms=0.0,
            sink="supabase",
            user_id=user_id,
            profile=profile,
            account_id=account_id,
            count=len(all_txns),
        )

    else:
        raise ValueError(f"output must be 'json' or 'supabase', got {output!r}")

    return report


# ---------------------------------------------------------------------------
# Supabase side-effects (only imported when output="supabase")
# ---------------------------------------------------------------------------
def _ensure_user_and_account(user_id: str) -> str:
    """Idempotently ensures the user and at least one account exist.
    Returns the account_id to use for inserts."""
    from services.banking.mock_api import _get_supabase  # lazy: avoid import cycle

    sb = _get_supabase()
    if sb is None:
        raise RuntimeError(
            "Supabase client unavailable — set SUPABASE_URL and SUPABASE_KEY "
            "in .env before running with output='supabase'."
        )

    existing_user = sb.table("users").select("id").eq("id", user_id).execute()
    if not existing_user.data:
        sb.table("users").insert(
            {"id": user_id, "email": f"{user_id}@demo.com"}
        ).execute()

    existing_acct = (
        sb.table("accounts").select("id").eq("user_id", user_id).limit(1).execute()
    )
    if existing_acct.data:
        return existing_acct.data[0]["id"]

    created = sb.table("accounts").insert({"user_id": user_id, "balance": 0}).execute()
    return created.data[0]["id"]


def _insert_transactions_supabase(txns: List[Dict[str, Any]]) -> None:
    from services.banking.mock_api import _get_supabase

    sb = _get_supabase()
    if sb is None:
        raise RuntimeError("Supabase client unavailable.")

    # Batch in chunks of 500 — Supabase REST rejects very large payloads.
    chunk = 500
    for i in range(0, len(txns), chunk):
        sb.table("transactions").insert(txns[i : i + chunk]).execute()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def _main() -> None:
    parser = argparse.ArgumentParser(
        description="Seed 6 months of HealthMetrics test data."
    )
    parser.add_argument("--user", required=True, help="User id, e.g. user_marcus")
    parser.add_argument("--profile", choices=["A", "B"], required=True)
    parser.add_argument("--output", choices=["json", "supabase"], default="json")
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--months", type=int, default=6)
    args = parser.parse_args()

    report = seed_six_months(
        user_id=args.user,
        profile=args.profile,
        output=args.output,
        seed=args.seed,
        months=args.months,
    )
    print(json.dumps(report.to_dict(), indent=2, ensure_ascii=False))


if __name__ == "__main__":
    _main()
