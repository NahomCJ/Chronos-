# BlockHub — Crypto Trading Module

**Path:** `src/modules/crypto/`
**Integration:** Paxos (custody + order execution)

BlockHub is the crypto trading arm of Chronos. Users buy and sell crypto assets through Paxos's institutional-grade brokerage API. The module enforces a compliance gate before every trade.

---

## Architecture Note

BlockHub was originally a standalone NestJS application. The backend contract now runs in Chronos's Express API under `src/modules/crypto/`, using shared Prisma and the Chronos auth/KYC middleware.

**Current status:** The public backend routes are mounted under `/api/v1/crypto`. Flutter/mobile work is out of scope for this backend sprint.

---

## Trade Flow

```
POST /api/v1/crypto/buy  (or /sell)
      │
      ▼
1. Compliance gate (KYC approved + not suspended + under daily limit + no fraud flag)
      │
      ▼
2. Balance check (USD for BUY, crypto for SELL) via Paxos API
      │
      ▼
3. Fee + spread calculation  ← BEFORE order submission
      │
      ▼
4. Place order on Paxos (MARKET order)
      │
      ▼
5. Poll until FILLED
      │
      ▼
6. Atomic DB write
   ├── Trade record
   ├── Portfolio holding update (weighted avg price)
   └── Revenue records (fee + spread)
      │
      ▼
7. Audit log + WebSocket push to user
```

---

## Endpoints

### Trading

| Method | Route | Auth | KYC | Description |
|--------|-------|------|-----|-------------|
| POST | `/api/v1/crypto/buy` | Yes | Yes | Buy crypto with USD |
| POST | `/api/v1/crypto/sell` | Yes | Yes | Sell crypto for USD |

### Wallet

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET  | `/api/v1/crypto` | Yes | Wallet status, Paxos balances, supported assets, and portfolio summary |

### Portfolio

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET  | `/api/v1/crypto/history` | Yes | Trade history plus Paxos transfer references |
| GET  | `/api/v1/crypto/price/:asset` | No | Live Paxos price, or CoinGecko fallback |

### Webhooks

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| POST | `/blockhub/webhooks/paxos` | No (Paxos-signed) | Paxos order status updates |

---

## Compliance Gate

Runs on **every** trade. All checks must pass or the trade is rejected (no fee charged).

| Check | Failure code |
|-------|-------------|
| User exists and is KYC approved | `KYC_NOT_VERIFIED` |
| Account not suspended | `ACCOUNT_SUSPENDED` |
| Crypto wallet provisioned | `WALLET_NOT_FOUND` |
| Under daily trading limit | `DAILY_LIMIT_EXCEEDED` |
| No active fraud/AML flag | `ACCOUNT_FLAGGED` |

### Daily Trading Limits by Tier

| Tier | Default Limit |
|------|--------------|
| `standard` | $10,000 / day |
| `verified_plus` | $50,000 / day |

Override via env: `DAILY_TRADE_LIMIT_STANDARD`, `DAILY_TRADE_LIMIT_VERIFIED_PLUS`

---

## Fee Model

Fees are calculated **before** order placement.

| Fee type | Rate | Applied to |
|----------|------|-----------|
| Trading fee | 0.5% (`FEE_RATE_DEFAULT`) | USD amount |
| Spread | 0.2% (`SPREAD_RATE`) | Market price |

**BUY:** execution price = market_price + spread. Net USD after fee sent to Paxos.  
**SELL:** execution price = market_price - spread. Fee taken from gross USD proceeds.

Both fee types recorded as `Revenue` rows for accounting.

---

## Paxos Integration

| Operation | Paxos API call |
|-----------|---------------|
| Create identity | `POST /identity/identities` |
| Create profile | `POST /profiles` |
| List profile balances | `GET /profiles/{profile_id}/balances` |
| Get market ticker | `GET /markets/{market}/ticker` |
| Place order | `POST /profiles/{profile_id}/orders` |
| Poll order | `GET /profiles/{profile_id}/orders/{order_id}` |
| List transfers | `GET /transfer/transfers?profile_ids={profile_id}` |
| Internal transfer | `POST /transfer/internal` |

---

## Wallet Provisioning

Triggered automatically when KYC is approved (Plaid webhook → `kycVerified: true`):

1. Create Paxos Identity (linked to Chronos `userId`)
2. Create Paxos Profile (linked to identity)
3. Store `paxosCustomerId` + `paxosWalletId` in `CryptoWallet` table

---

## WebSocket

`BlockhubGateway` pushes real-time portfolio updates to users after every trade. Frontend subscribes to the user's room using their JWT.

---

## Environment Variables

```env
PAXOS_ENV=sandbox
PAXOS_CLIENT_ID=
PAXOS_CLIENT_SECRET=
PAXOS_PROFILE_ID=          # Your platform's Paxos profile ID
PAXOS_SETTLEMENT_PROFILE_ID=
PAXOS_SCOPES=              # Optional; defaults include profile, trading, identity, and transfer scopes
FEE_RATE_DEFAULT=0.005     # 0.5%
SPREAD_RATE=0.002          # 0.2%
DAILY_TRADE_LIMIT_STANDARD=10000
DAILY_TRADE_LIMIT_VERIFIED_PLUS=50000
```

## Sandbox Smoke Test

Run `npm run test:paxos:sandbox` after setting `PAXOS_CLIENT_ID`, `PAXOS_CLIENT_SECRET`, and `PAXOS_PROFILE_ID`. Without those variables the command exits successfully with a skip message.

By default the command validates OAuth, profile balances, prices for BTC/ETH/SOL/UNI/AAVE/LINK, and transfer listing. Set `PAXOS_SANDBOX_RUN_TRADES=true` to place a small buy/sell loop, and `PAXOS_SANDBOX_RUN_TRANSFERS=true` with `PAXOS_SETTLEMENT_PROFILE_ID` to submit settlement profile credit/debit checks.

See `docs/blockhub-testing.md` for the full deterministic test matrix, schema checks, and live sandbox test gates.

---

## Key Files

| File | Purpose |
|------|---------|
| `trading/trading.service.ts` | Full BUY/SELL orchestration |
| `compliance/compliance.service.ts` | Pre-trade compliance gate |
| `wallet/wallet.service.ts` | Paxos wallet provisioning |
| `portfolio/portfolio.service.ts` | Holdings tracking |
| `revenue/revenue.service.ts` | Fee + spread recording |
| `audit/audit.service.ts` | Immutable trade audit log |
| `providers/paxos/paxos.service.ts` | Paxos API client |
| `gateway/blockhub.gateway.ts` | WebSocket real-time push |
| `webhooks/webhooks.controller.ts` | Paxos webhook receiver |
