-- =============================================================================
-- 20260507_income_advisory_schema.sql
-- Income & Payroll Advisory Layer
--
-- Stores only minimized, bracketed income snapshots. Raw Plaid payroll payloads,
-- employer names, NI details, and exact salary figures are intentionally omitted.
-- =============================================================================

begin;

alter table public.plaid_tokens
  add column if not exists income_authorized boolean not null default false,
  add column if not exists income_user_token text,
  add column if not exists authorized_products jsonb;

create table if not exists public.income_snapshots (
  id                              uuid primary key default gen_random_uuid(),
  user_id                         text not null references public.users(id) on delete cascade,
  income_type                     text not null check (
    income_type in ('SALARIED', 'IRREGULAR', 'MIXED', 'UNKNOWN')
  ),
  has_payroll_connection          boolean not null default false,
  estimated_monthly_income_range  text not null,
  gross_monthly_income_range      text not null,
  income_sources                  jsonb not null default '[]'::jsonb,
  payroll_data                    jsonb,
  data_source                     text not null,
  synced_at                       timestamptz not null default now(),
  retention_expires_at            timestamptz not null,

  constraint income_snapshots_user_id_unique unique (user_id)
);

create index if not exists income_snapshots_user_id_synced_at_idx
  on public.income_snapshots (user_id, synced_at desc);

create table if not exists public.income_sync_audit (
  id           uuid primary key default gen_random_uuid(),
  user_id      text not null references public.users(id) on delete cascade,
  synced_at    timestamptz not null default now(),
  data_source  text not null,
  income_type  text not null,
  status       text not null
);

create index if not exists income_sync_audit_user_id_synced_at_idx
  on public.income_sync_audit (user_id, synced_at desc);

commit;
