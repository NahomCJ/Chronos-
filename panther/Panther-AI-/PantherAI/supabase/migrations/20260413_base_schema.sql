-- =============================================================================
-- 20260413_base_schema.sql
-- Baseline schema — recreates the tables the backend already uses.
--
-- Why: the existing Supabase project was recreated from scratch; none of the
-- tables exist yet, but the backend code (routers/, services/, scripts/)
-- already assumes they do. This migration reverse-engineers the minimum
-- schema from every `supabase.table("...")` call site.
--
-- Column set derived from:
--   - scripts/seed_mock_data.py               (users, accounts, bills, bnpls)
--   - routers/transactions/router.py          (transactions)
--   - routers/webhooks/plaid.py               (transactions upsert shape)
--   - routers/plaid/router.py                 (plaid_tokens upsert shape)
--   - services/banking/mock_api.py            (warnings_history, bnpls reads)
--
-- Types:
--   - users.id is `text` (e.g. "user_marcus") — the project does not use
--     Supabase Auth for demo users.
--   - accounts.id is `uuid` (gen_random_uuid) — seed_mock_data reads it back
--     from an INSERT ... RETURNING, so the DB generates it.
--   - transactions.id is `text` — Plaid webhook reuses Plaid's
--     transaction_id string as the PK.
--   - bnpls has both `total_amount`, `amount`, `remaining_amount` because
--     seeding writes one set of columns and mock_api reads another. All are
--     nullable to tolerate the inconsistency until the backend converges.
-- =============================================================================

begin;

-- -----------------------------------------------------------------------------
-- users
-- -----------------------------------------------------------------------------
create table if not exists public.users (
  id            text primary key,
  email         text,
  monthly_rent  numeric(12, 2),
  created_at    timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- accounts
-- -----------------------------------------------------------------------------
create table if not exists public.accounts (
  id          uuid primary key default gen_random_uuid(),
  user_id     text not null references public.users(id) on delete cascade,
  balance     numeric(12, 2) not null default 0,
  created_at  timestamptz not null default now()
);

create index if not exists accounts_user_id_idx on public.accounts (user_id);

-- -----------------------------------------------------------------------------
-- transactions
-- -----------------------------------------------------------------------------
create table if not exists public.transactions (
  id                   text primary key default gen_random_uuid()::text,
  account_id           uuid not null references public.accounts(id) on delete cascade,
  merchant_name        text not null,
  amount               numeric(12, 2) not null,
  date                 date not null,
  subcategory          text,
  category_confidence  numeric,
  category_source      text,
  user_corrected       boolean not null default false,
  created_at           timestamptz not null default now()
);

create index if not exists transactions_account_id_date_idx
  on public.transactions (account_id, date desc);

-- -----------------------------------------------------------------------------
-- bills
-- -----------------------------------------------------------------------------
create table if not exists public.bills (
  id        uuid primary key default gen_random_uuid(),
  user_id   text not null references public.users(id) on delete cascade,
  name      text not null,
  amount    numeric(12, 2) not null,
  due_day   int  not null check (due_day between 1 and 31)
);

create index if not exists bills_user_id_idx on public.bills (user_id);

-- -----------------------------------------------------------------------------
-- bnpls
-- -----------------------------------------------------------------------------
create table if not exists public.bnpls (
  id                uuid primary key default gen_random_uuid(),
  user_id           text not null references public.users(id) on delete cascade,
  total_amount      numeric(12, 2),
  amount            numeric(12, 2),
  remaining_amount  numeric(12, 2),
  num_payments      int,
  status            text not null default 'active'
);

create index if not exists bnpls_user_id_status_idx on public.bnpls (user_id, status);

-- -----------------------------------------------------------------------------
-- plaid_tokens
-- -----------------------------------------------------------------------------
create table if not exists public.plaid_tokens (
  id            uuid primary key default gen_random_uuid(),
  user_id       text not null unique references public.users(id) on delete cascade,
  access_token  text not null,
  item_id       text not null,
  institution   text,
  updated_at    timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- warnings_history
-- -----------------------------------------------------------------------------
create table if not exists public.warnings_history (
  id           text primary key,
  user_id      text not null references public.users(id) on delete cascade,
  timestamp    timestamptz not null default now(),
  source       text,
  risk_level   text,
  title        text,
  message      text,
  context      jsonb,
  outcome      jsonb
);

create index if not exists warnings_history_user_id_ts_idx
  on public.warnings_history (user_id, timestamp desc);

commit;
