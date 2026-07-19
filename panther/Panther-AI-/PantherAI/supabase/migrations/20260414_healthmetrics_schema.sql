-- =============================================================================
-- 20260414_healthmetrics_schema.sql
-- Sprint HealthMetrics — Día 1, TASK 1.1
--
-- Adds the persistence layer required by the 4 health metrics (Burn Rate,
-- Commitment Ratio, Runway, Momentum) and the Chronos Score.
--
-- What this migration does:
--   1. users               — ALTER to add financial-profile columns.
--                            (The table already exists with id/email/monthly_rent
--                             seeded in scripts/seed_mock_data.py, so we extend
--                             rather than create from scratch.)
--   2. recurring_charges   — NEW. Stores recurring merchants detected by the
--                            Commitment Ratio pipeline (day 2-3).
--   3. metrics_snapshot    — NEW. Historical snapshots of the 4 metrics + the
--                            Chronos Score. Powers week-2 "suficiencia mode"
--                            which compares 4 weeks of Chronos Score values.
--
-- Deviations from the original spec in tasks/todo.md:
--   - `users.id` is kept as text (e.g. "user_marcus") to match the existing
--     schema and backend code (routers/transactions/router.py queries by
--     text user_id). The spec assumed `uuid references auth.users(id)`, but
--     the project does not use Supabase Auth for these demo users.
--   - `accounts.user_id` is text, so all user-scoped joins go through
--     accounts.id (uuid) rather than a direct users.id reference.
--   - Status columns stay `text` (not enums) so the app layer owns the
--     vocabulary (optimo|saludable|atencion|critico|insuficiente) and spec
--     changes do not require a DB migration.
--
-- How to apply (no Supabase CLI installed locally at time of writing):
--   Option A — Supabase Dashboard → SQL Editor → paste this file → Run.
--   Option B — psql "$SUPABASE_DB_URL" -f supabase/migrations/20260414_healthmetrics_schema.sql
--   Option C — supabase db push   (once the CLI is installed and linked).
-- =============================================================================

begin;

-- -----------------------------------------------------------------------------
-- 1. users — extend financial profile
-- -----------------------------------------------------------------------------
-- Why: 2.1 (income-profile detection) fills monthly_income and income_profile
-- on first run; the UI lets the user edit it. currency is per-user so the
-- frontend can format values without a separate lookup. onboarded_at records
-- when the user completed the health-metrics onboarding flow.

alter table public.users
  add column if not exists monthly_income numeric(12, 2),
  add column if not exists income_profile text,
  add column if not exists currency       text not null default 'EUR',
  add column if not exists onboarded_at   timestamptz;

-- Validate income_profile values at the app layer is not enough: guard at DB.
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'users_income_profile_check'
  ) then
    alter table public.users
      add constraint users_income_profile_check
      check (income_profile is null or income_profile in ('A', 'B'));
  end if;
end $$;


-- -----------------------------------------------------------------------------
-- 2. recurring_charges
-- -----------------------------------------------------------------------------
-- Why: Commitment Ratio (day 3) needs a persistent list of recurring charges.
-- Detection runs periodically; storing the output lets the UI show the user
-- *why* their commitment ratio is what it is, and lets them dismiss false
-- positives without re-running detection.

create table if not exists public.recurring_charges (
  id                  uuid primary key default gen_random_uuid(),
  account_id          uuid not null references public.accounts(id) on delete cascade,
  merchant            text not null,
  amount              numeric(12, 2) not null,
  frequency           text not null check (frequency in ('monthly', 'quarterly', 'yearly')),
  next_expected_date  date,
  detected_at         timestamptz not null default now()
);

create index if not exists recurring_charges_account_id_idx
  on public.recurring_charges (account_id);


-- -----------------------------------------------------------------------------
-- 3. metrics_snapshot
-- -----------------------------------------------------------------------------
-- Why: every time the metrics pipeline runs we persist the full result set.
-- This gives the UI a history for the sparkline (day 6) and powers the
-- week-2 "suficiencia" mode which compares 4 consecutive weekly scores.

create table if not exists public.metrics_snapshot (
  id                 uuid primary key default gen_random_uuid(),
  account_id         uuid not null references public.accounts(id) on delete cascade,
  captured_at        timestamptz not null default now(),

  burn_rate_value    numeric,
  burn_rate_score    int,
  burn_rate_status   text,

  commitment_value   numeric,
  commitment_score   int,
  commitment_status  text,

  runway_value       numeric,
  runway_score       int,
  runway_status      text,

  momentum_value     numeric,
  momentum_score     int,
  momentum_status    text,

  chronos_score      int  not null,
  chronos_status     text not null
);

create index if not exists metrics_snapshot_account_id_captured_at_idx
  on public.metrics_snapshot (account_id, captured_at desc);


-- -----------------------------------------------------------------------------
-- 4. Row Level Security
-- -----------------------------------------------------------------------------
-- Pattern: a row is visible to `authenticated` iff it belongs to an account
-- whose user_id matches the JWT `sub` claim. The backend uses the service
-- role key (which bypasses RLS) so server-side access is unaffected. This
-- matters the moment the frontend starts talking to Supabase directly.

alter table public.recurring_charges enable row level security;
alter table public.metrics_snapshot  enable row level security;

drop policy if exists recurring_charges_owner_select on public.recurring_charges;
create policy recurring_charges_owner_select
  on public.recurring_charges
  for select
  to authenticated
  using (
    exists (
      select 1 from public.accounts a
      where a.id = recurring_charges.account_id
        and a.user_id = auth.jwt() ->> 'sub'
    )
  );

drop policy if exists recurring_charges_owner_write on public.recurring_charges;
create policy recurring_charges_owner_write
  on public.recurring_charges
  for all
  to authenticated
  using (
    exists (
      select 1 from public.accounts a
      where a.id = recurring_charges.account_id
        and a.user_id = auth.jwt() ->> 'sub'
    )
  )
  with check (
    exists (
      select 1 from public.accounts a
      where a.id = recurring_charges.account_id
        and a.user_id = auth.jwt() ->> 'sub'
    )
  );

drop policy if exists metrics_snapshot_owner_select on public.metrics_snapshot;
create policy metrics_snapshot_owner_select
  on public.metrics_snapshot
  for select
  to authenticated
  using (
    exists (
      select 1 from public.accounts a
      where a.id = metrics_snapshot.account_id
        and a.user_id = auth.jwt() ->> 'sub'
    )
  );

drop policy if exists metrics_snapshot_owner_write on public.metrics_snapshot;
create policy metrics_snapshot_owner_write
  on public.metrics_snapshot
  for all
  to authenticated
  using (
    exists (
      select 1 from public.accounts a
      where a.id = metrics_snapshot.account_id
        and a.user_id = auth.jwt() ->> 'sub'
    )
  )
  with check (
    exists (
      select 1 from public.accounts a
      where a.id = metrics_snapshot.account_id
        and a.user_id = auth.jwt() ->> 'sub'
    )
  );

commit;
