# HealthMetrics Schema

**Responsibility:** Persistence layer for the 4 health metrics (Burn Rate, Commitment Ratio, Runway, Momentum) and the Chronos Score.
**Depends on:** `supabase/migrations/20260413_base_schema.sql` (base `users`, `accounts`, `transactions`)

## What this migration adds

| Object | Kind | Purpose |
|---|---|---|
| `public.users` | ALTER | Adds `monthly_income`, `income_profile` (`A`/`B`), `currency`, `onboarded_at`. Income profile feeds metric 2.1. |
| `public.recurring_charges` | NEW table | Detected recurring merchants. Written by day 2–3 Commitment Ratio pipeline. |
| `public.metrics_snapshot` | NEW table | Historical snapshot of the 4 metrics + Chronos Score. Written by day 4 metrics endpoint. Read by day 6 UI (sparkline) and week-2 "suficiencia" mode (4-week Chronos Score comparison). |

## Contracts

**`recurring_charges` row shape:**
```json
{
  "id": "uuid",
  "account_id": "uuid (FK accounts.id, ON DELETE CASCADE)",
  "merchant": "string",
  "amount": "numeric(12,2)",
  "frequency": "monthly | quarterly | yearly",
  "next_expected_date": "date | null",
  "detected_at": "timestamptz"
}
```

**`metrics_snapshot` row shape:**
```json
{
  "id": "uuid",
  "account_id": "uuid (FK accounts.id, ON DELETE CASCADE)",
  "captured_at": "timestamptz",
  "burn_rate_value":   "numeric | null",
  "burn_rate_score":   "int | null",
  "burn_rate_status":  "text | null",
  "commitment_value":  "numeric | null",
  "commitment_score":  "int | null",
  "commitment_status": "text | null",
  "runway_value":      "numeric | null",
  "runway_score":      "int | null",
  "runway_status":     "text | null",
  "momentum_value":    "numeric | null",
  "momentum_score":    "int | null",
  "momentum_status":   "text | null",
  "chronos_score":     "int (not null)",
  "chronos_status":    "text (not null)"
}
```

Status vocabulary lives in the app layer, not DB: `optimo | saludable | atencion | critico | insuficiente`. Kept off the DB so spec changes do not require a migration.

## Row Level Security

Both new tables have RLS enabled. Visibility rule: a row is visible to `authenticated` iff it belongs to an `account` whose `user_id` equals the JWT `sub` claim.

```sql
exists (
  select 1 from public.accounts a
  where a.id = <table>.account_id
    and a.user_id = auth.jwt() ->> 'sub'
)
```

The backend uses the service-role key (bypasses RLS), so server-side writes are unaffected. RLS matters the moment the frontend talks to Supabase directly.

## Deviation from the original spec

`users.id` is `text` (e.g. `"user_marcus"`), not `uuid references auth.users(id)`. The project does not use Supabase Auth for demo users. All user-scoped joins go through `accounts.id` (uuid), not a direct `users.id` reference.

## How to apply

Supabase CLI is not installed in this repo. Choose one:

```bash
# Option A — Dashboard → SQL Editor → paste file → Run

# Option B — psql
psql "$SUPABASE_DB_URL" -f supabase/migrations/20260414_healthmetrics_schema.sql

# Option C — CLI (once installed and linked)
supabase db push
```

Status: **applied** in `eu-west-1` Session Pooler via psycopg. `pg_tables.rowsecurity = true` verified on both new tables.

## Downstream consumers

| When | Who | Does what |
|---|---|---|
| Day 2–3 | Commitment Ratio pipeline | Writes `recurring_charges` |
| Day 4 | `routers/metrics/router.py` (`GET /api/metrics/{user_id}`) | Writes `metrics_snapshot` |
| Day 6 | Frontend `components/dashboard/*` | Reads latest + historical `metrics_snapshot` rows for Chronos Score card, metric cards, sparkline |
| Week 2 | "Suficiencia" mode | Reads 4 consecutive weekly `metrics_snapshot` rows to compare Chronos Score |

## Test Command

```bash
# Smoke-test: tables exist and are empty, RLS is on
psql "$SUPABASE_DB_URL" -c "
  select relname, relrowsecurity
  from pg_class
  where relname in ('recurring_charges','metrics_snapshot');
"
```
