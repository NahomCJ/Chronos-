-- =============================================================================
-- 20260714_investments_lane.sql
-- Investments Holdings Lane persistence + RLS, mirroring
-- 20260508_liabilities_and_lane_rls.sql's user_liabilities table.
--
-- The Python investments service writes minimized extracted holdings to
-- public.user_investments. Raw Plaid responses are never stored.
-- =============================================================================

begin;

create table if not exists public.user_investments (
  id                    uuid primary key default gen_random_uuid(),
  user_id               text not null references public.users(id) on delete cascade,
  holdings              jsonb not null default '[]'::jsonb,
  total_value           numeric not null default 0,
  holding_count         integer not null default 0,
  asset_classes         jsonb not null default '[]'::jsonb,
  diversified           boolean not null default false,
  synced_at             timestamptz not null default now(),
  retention_expires_at  timestamptz not null default (now() + interval '90 days'),

  constraint user_investments_user_id_unique unique (user_id)
);

create index if not exists user_investments_user_id_synced_at_idx
  on public.user_investments (user_id, synced_at desc);

alter table public.user_investments enable row level security;

drop policy if exists user_investments_owner_select on public.user_investments;
create policy user_investments_owner_select
  on public.user_investments
  for select
  to authenticated
  using (user_id = auth.jwt() ->> 'sub');

drop policy if exists user_investments_owner_write on public.user_investments;
create policy user_investments_owner_write
  on public.user_investments
  for all
  to authenticated
  using (user_id = auth.jwt() ->> 'sub')
  with check (user_id = auth.jwt() ->> 'sub');

commit;
