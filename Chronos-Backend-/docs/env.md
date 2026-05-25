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
| `PAXOS_API_URL` | Yes | `https://api.sandbox.paxos.com/v2` for sandbox |
| `PAXOS_CLIENT_ID` | Yes | Paxos OAuth client ID |
| `PAXOS_CLIENT_SECRET` | Yes | Paxos OAuth client secret |
| `PAXOS_PROFILE_ID` | Yes | Your platform's Paxos profile ID |

---

## Trading Config

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `FEE_RATE_DEFAULT` | No | `0.005` | Trading fee (0.5%) |
| `SPREAD_RATE` | No | `0.002` | Spread (0.2%) |
| `DAILY_TRADE_LIMIT_STANDARD` | No | `10000` | Daily USD trading limit for standard tier |
| `DAILY_TRADE_LIMIT_VERIFIED_PLUS` | No | `50000` | Daily USD trading limit for verified_plus tier |

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
