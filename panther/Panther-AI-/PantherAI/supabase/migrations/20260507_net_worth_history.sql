-- =============================================================================
-- 20260507_net_worth_history.sql
-- Net Worth & Financial Health Layer
--
-- Stores one minimized daily net worth snapshot per user. Net worth is a full
-- financial fingerprint, so rows carry a 90-day retention expiry and cascade
-- on user deletion. Raw account payloads are intentionally not stored here.
-- =============================================================================

begin;

create table if not exists public.net_worth_history (
  id                    uuid primary key default gen_random_uuid(),
  user_id               text not null references public.users(id) on delete cascade,
  snapshot_date         date not null,
  net_worth             numeric(14, 2) not null,
  total_assets          numeric(14, 2) not null,
  total_liabilities     numeric(14, 2) not null,
  data_completeness     numeric(4, 2) not null check (
    data_completeness >= 0 and data_completeness <= 1
  ),
  missing_sources       jsonb not null default '[]'::jsonb,
  created_at            timestamptz not null default now(),
  retention_expires_at  timestamptz not null default (now() + interval '90 days'),

  constraint net_worth_history_user_day_unique unique (user_id, snapshot_date)
);

create index if not exists net_worth_history_user_date_idx
  on public.net_worth_history (user_id, snapshot_date desc);

commit;
