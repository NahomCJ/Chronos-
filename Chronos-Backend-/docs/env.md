# Environment Variables

All variables used across Chronos Backend. Copy `.env.example` to `.env` and fill in the values.

Variables marked **required** will cause a startup crash or immediate runtime errors if missing.  
Variables marked **optional** have safe defaults or are only needed for specific features.

---

## App

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `NODE_ENV` | Yes | `development` | `development` / `production` / `test` |
| `PORT` | No | `3000` | HTTP server port |
| `JWT_SECRET` | Yes | — | Long random string for signing JWTs. Never reuse across environments. |

---

## Database

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string: `postgresql://user:pass@host:5432/dbname` |

---

## Plaid (KYC + Bank Linking)

Keys not yet issued — server starts without them but Plaid routes will return 500.  
Get them from [Plaid Dashboard → Team Settings → Keys](https://dashboard.plaid.com/team/keys).

| Variable | Required for Plaid | Description |
|----------|-------------------|-------------|
| `PLAID_CLIENT_ID` | Yes | Plaid client ID |
| `PLAID_SECRET` | Yes | Sandbox secret key |
| `PLAID_ENV` | No | `sandbox` (default) / `development` / `production` |
| `PLAID_IDV_TEMPLATE_ID` | Yes (for KYC) | IDV template ID — create in Plaid Dashboard → Identity Verification |
| `PLAID_VERIFY_WEBHOOKS` | No | `false` (default). Set `true` in production. Requires `npm install jose`. |

---

## Paxos (Crypto Trading)

| Variable | Required for BlockHub | Description |
|----------|-----------------------|-------------|
| `PAXOS_ENV` | No | `sandbox` (default) / `production`. Controls OAuth and API base URLs. |
| `PAXOS_API_URL` | No | Optional override. Defaults to `https://api.sandbox.paxos.com/v2` in sandbox. |
| `PAXOS_CLIENT_ID` | Yes | Paxos OAuth client ID. If missing, server boots, prices fall back to CoinGecko, and trading returns 503. |
| `PAXOS_CLIENT_SECRET` | Yes | Paxos OAuth client secret |
| `PAXOS_PROFILE_ID` | Yes | Platform Paxos profile ID |
| `PAXOS_SETTLEMENT_PROFILE_ID` | Yes for transfers | Settlement profile used for internal credit/debit transfer tests |
| `PAXOS_SCOPES` | No | OAuth scopes. Defaults include profile, trading, identity, transfer read, and internal transfer write scopes. |
| `PAXOS_SANDBOX_RUN_TRADES` | No | Set `true` only when running `npm run test:paxos:sandbox` and you want the command to place a small sandbox buy/sell loop. |
| `PAXOS_SANDBOX_RUN_TRANSFERS` | No | Set `true` only when running `npm run test:paxos:sandbox` and you want internal settlement transfer checks. |
| `PAXOS_SANDBOX_TRADE_AMOUNT_USD` | No | Defaults to `5.00` for the gated sandbox trade loop. |

`npm run test:paxos:sandbox` exits with a skip message unless `PAXOS_CLIENT_ID`, `PAXOS_CLIENT_SECRET`, and `PAXOS_PROFILE_ID` are present. With credentials present, it validates OAuth, balances, prices for all supported assets, and transfer listing. Trade and transfer mutations require the explicit flags above.

---

## Trading Config

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `FEE_RATE_DEFAULT` | No | `0.005` | Trading fee (0.5%) |
| `SPREAD_RATE` | No | `0.002` | Spread (0.2%) |
| `DAILY_TRADE_LIMIT_STANDARD` | No | `10000` | Daily USD trading limit for standard tier |
| `DAILY_TRADE_LIMIT_VERIFIED_PLUS` | No | `50000` | Daily USD trading limit for verified_plus tier |
| `PAXOS_ORDER_POLL_INTERVAL_MS` | No | `2000` | Poll interval for sandbox order fill checks |
| `PAXOS_ORDER_POLL_ATTEMPTS` | No | `15` | Max order polling attempts before timeout |

---

## Deposit

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DEPOSIT_MIN_AMOUNT` | No | `1` | Minimum deposit amount in USD |

---

## Akoya (Open Banking)

| Variable | Required | Description |
|----------|----------|-------------|
| `AKOYA_CLIENT_ID` | For Akoya routes | — |
| `AKOYA_CLIENT_SECRET` | For Akoya routes | — |
| `AKOYA_BASE_URL` | For Akoya routes | — |

---

## Moralis (On-chain Data)

| Variable | Required | Description |
|----------|----------|-------------|
| `MORALIS_API_KEY` | For crypto/NFT routes | — |
| `MORALIS_API_URL` | No | `https://deep-index.moralis.io/api/v2` |

---

## Sentry

| Variable | Required | Description |
|----------|----------|-------------|
| `SENTRY_DSN` | No | Sentry error tracking DSN. Omit to disable. |

---

## Quick Reference — Minimum to Start

```env
NODE_ENV=development
PORT=3000
JWT_SECRET=replace_this_with_something_long_and_random
DATABASE_URL=postgresql://user:password@localhost:5432/chronos
```
