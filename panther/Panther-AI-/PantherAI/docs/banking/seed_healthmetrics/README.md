# seed_healthmetrics

**Responsibility:** Generates 6 months of realistic mock transactions for one user so the HealthMetrics pipeline (sprint days 2-5) can validate its formulas against the Apéndice A oracle.

**Depends on:** `services/banking/mock_api.py` (Supabase client), `supabase/migrations/20260413_base_schema.sql` (`public.transactions` shape), `core/logger.py`

## Contracts

**Input (`seed_six_months`):**
```json
{
  "user_id": "user_marcus",
  "profile": "A",
  "output": "json",
  "months": 6,
  "seed": 42
}
```

**Output (`SeedReport`):**
```json
{
  "user_id": "user_marcus",
  "profile": "A",
  "months_generated": 6,
  "transactions_inserted": 406,
  "breakdown": {
    "income": 6,
    "rent": 6,
    "subscriptions": 24,
    "utility": 6,
    "variable": 363,
    "lumpy": 1
  },
  "output_path": "/…/datasets/mock/seed_healthmetrics_user_marcus_A.json",
  "account_id": null
}
```

**Per-transaction row (matches `public.transactions`):**
```json
{
  "id": "4c1a…",
  "account_id": "7c719840-5033-44f8-b49b-5632ab80e540",
  "merchant_name": "ACME CORP NOMINA",
  "amount": 2187.42,
  "date": "2025-12-27",
  "subcategory": "sub_salary",
  "category_confidence": 1.0,
  "category_source": "seed_healthmetrics",
  "user_corrected": false
}
```

## Apéndice A oracle (Perfil A, user_marcus)

| Slot | Target | Source |
|------|--------|--------|
| Ingreso | ~2.200 €/mes | `PROFILE_A_SALARY_BASE` ±2 % |
| Alquiler | 700 €/mes | `RENT_AMOUNT` |
| Suscripciones | ~85 €/mes | Netflix + Spotify + Basic-Fit + Vodafone |
| Utility | 120 €/mes | `UTILITY` (IBERDROLA) |
| Recurrente total | ~905 €/mes | 700 + 85 + 120 |
| Variable | ~800 €/mes | gamma(2, 7) × 40-80 txns/mes |
| Lumpy | 1 cargo anual 420-580 € | `LUMPY_MERCHANT` |

The oracle is enforced by `test_apendice_a_totals_for_marcus`.

## CLI

```bash
# Phase 1 — offline, dumps JSON to datasets/mock/
python -m services.banking.seed_healthmetrics --user user_marcus --profile A

# Phase 2 — inserts into public.transactions
python -m services.banking.seed_healthmetrics --user user_marcus --profile A --output supabase
```

## Test Command

```bash
pytest tests/test_seed_healthmetrics.py -v
```

## Known debt

Phase 2 is **not yet idempotent** — re-running `--output supabase` will duplicate rows. See `tasks/SPRINT_HEALTHMETRICS.md` §TASK 2.5 for the full hardening list (idempotency, determinism, error handling on `.execute()`).
