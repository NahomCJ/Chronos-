-- =============================================================================
-- 20260508_liabilities_and_lane_rls.sql
-- Debt/Liabilities Lane persistence + RLS for sensitive financial lane tables.
--
-- The Python liabilities service writes minimized extracted fields to
-- public.user_liabilities. Raw Plaid responses are never stored.
-- =============================================================================

begin;

alter table public.plaid_tokens
  add column if not exists liabilities_authorized boolean not null default false,
  add column if not exists authorized_products jsonb;

create table if not exists public.user_liabilities (
  id                    uuid primary key default gen_random_uuid(),
  user_id               text not null references public.users(id) on delete cascade,
  credit_cards          jsonb not null default '[]'::jsonb,
  student_loans         jsonb not null default '[]'::jsonb,
  auto_loans            jsonb not null default '[]'::jsonb,
  personal_loans        jsonb not null default '[]'::jsonb,
  mortgages             jsonb not null default '[]'::jsonb,
  synced_at             timestamptz not null default now(),
  retention_expires_at  timestamptz not null default (now() + interval '90 days'),

  constraint user_liabilities_user_id_unique unique (user_id)
);

create index if not exists user_liabilities_user_id_synced_at_idx
  on public.user_liabilities (user_id, synced_at desc);

alter table public.user_liabilities enable row level security;
alter table public.income_snapshots enable row level security;
alter table public.income_sync_audit enable row level security;
alter table public.net_worth_history enable row level security;

drop policy if exists user_liabilities_owner_select on public.user_liabilities;
create policy user_liabilities_owner_select
  on public.user_liabilities
  for select
  to authenticated
  using (user_id = auth.jwt() ->> 'sub');

drop policy if exists user_liabilities_owner_write on public.user_liabilities;
create policy user_liabilities_owner_write
  on public.user_liabilities
  for all
  to authenticated
  using (user_id = auth.jwt() ->> 'sub')
  with check (user_id = auth.jwt() ->> 'sub');

drop policy if exists income_snapshots_owner_select on public.income_snapshots;
create policy income_snapshots_owner_select
  on public.income_snapshots
  for select
  to authenticated
  using (user_id = auth.jwt() ->> 'sub');

drop policy if exists income_sync_audit_owner_select on public.income_sync_audit;
create policy income_sync_audit_owner_select
  on public.income_sync_audit
  for select
  to authenticated
  using (user_id = auth.jwt() ->> 'sub');

drop policy if exists net_worth_history_owner_select on public.net_worth_history;
create policy net_worth_history_owner_select
  on public.net_worth_history
  for select
  to authenticated
  using (user_id = auth.jwt() ->> 'sub');

drop policy if exists net_worth_history_owner_write on public.net_worth_history;
create policy net_worth_history_owner_write
  on public.net_worth_history
  for all
  to authenticated
  using (user_id = auth.jwt() ->> 'sub')
  with check (user_id = auth.jwt() ->> 'sub');

commit;
