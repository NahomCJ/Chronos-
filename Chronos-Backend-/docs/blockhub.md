# BlockHub — Crypto Trading Module

**Path:** `src/modules/blockhub/`  
**Integration:** Paxos (custody + order execution)

BlockHub is the crypto trading arm of Chronos. Users buy and sell crypto assets through Paxos's institutional-grade brokerage API. The module enforces a compliance gate before every trade.

---

## Architecture Note

BlockHub was originally a standalone NestJS application. It has been merged into Chronos as a module under `src/modules/blockhub/`. The NestJS decorators (`@Injectable`, `PrismaService`, `ConfigService`) are being progressively replaced with Chronos's Express + direct Prisma pattern.

**Current status:** Services are being adapted file-by-file. `revenue.service.ts` is already converted. Auth and compliance modules from BlockHub have been removed — Chronos's unified `requireAuth` and KYC gate are used instead.

---

## Trade Flow

```
POST /blockhub/trade/buy  (or /sell)
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
| POST | `/blockhub/trade/buy` | Yes | Yes | Buy crypto with USD |
| POST | `/blockhub/trade/sell` | Yes | Yes | Sell crypto for USD |

### Wallet

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET  | `/blockhub/wallet` | Yes | Get crypto wallet info |
| GET  | `/blockhub/wallet/balance/usd` | Yes | USD balance on Paxos |
| GET  | `/blockhub/wallet/balance/:asset` | Yes | Crypto balance |

### Portfolio

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET  | `/blockhub/portfolio` | Yes | All holdings with live prices |
| GET  | `/blockhub/portfolio/:asset` | Yes | Single asset holding |

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
| Create identity | `POST /identity/identity` |
| Create profile | `POST /identity/profile` |
| Get USD balance | `GET /transfer/profile/{id}/balance` |
| Get crypto balance | `GET /transfer/profile/{id}/balance` |
| Get market price | `GET /markets/market-data` |
| Place order | `POST /brokerage/order` |
| Poll order | `GET /brokerage/order/{id}` |

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
PAXOS_API_URL=https://api.sandbox.paxos.com/v2
PAXOS_CLIENT_ID=
PAXOS_CLIENT_SECRET=
PAXOS_PROFILE_ID=          # Your platform's Paxos profile ID
FEE_RATE_DEFAULT=0.005     # 0.5%
SPREAD_RATE=0.002          # 0.2%
DAILY_TRADE_LIMIT_STANDARD=10000
DAILY_TRADE_LIMIT_VERIFIED_PLUS=50000
```

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
