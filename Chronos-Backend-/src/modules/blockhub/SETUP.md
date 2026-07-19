# BlockHub Backend — Sandbox Setup Guide

Chronos BlockHub Crypto Trading Backend · Paxos Sandbox Integration

---

## Prerequisites

| Tool | Version |
|------|---------|
| Node.js | 20+ |
| npm | 9+ |
| Docker + Docker Compose | latest |
| PostgreSQL (or use Docker) | 15+ |
| Paxos Sandbox Account | Required |

---

## Step 1 — Get Paxos Sandbox Credentials

1. Go to **https://dashboard.sandbox.paxos.com** and sign up
2. Navigate to **Settings → API Credentials → Create New**
3. Enable these scopes:
   - `funding:read_profile`
   - `funding:write_profile`
   - `trading:read_order`
   - `trading:write_order`
   - `identity:read_identity`
   - `identity:write_identity`
   - `transfer:read_transfer`
4. Copy your **Client ID** and **Client Secret**

> The sandbox token URL is: `https://oauth.sandbox.paxos.com/oauth2/token`  
> The sandbox API base is: `https://api.sandbox.paxos.com/v2`

---

## Step 2 — Configure Environment

```bash
cp .env.example .env
```

Fill in `.env` with your sandbox credentials:

```bash
PAXOS_CLIENT_ID=your-sandbox-client-id
PAXOS_CLIENT_SECRET=your-sandbox-client-secret

# Generate RS256 keys for JWT:
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -out public.pem

# Paste the contents (with \n line breaks) into:
JWT_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----"
JWT_PUBLIC_KEY="-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----"
```

---

## Step 3 — Start Local Services

```bash
# Start PostgreSQL + Redis via Docker
docker-compose up postgres redis -d

# Install dependencies
npm install

# Generate Prisma client
npm run prisma:generate

# Run initial migration
npm run prisma:migrate:dev

# Apply audit log immutability trigger
psql $DATABASE_URL -f prisma/migrations/audit_immutability_trigger.sql
```

---

## Step 4 — Verify Paxos Sandbox Connection

Run the integration test against the live sandbox before starting the server:

```bash
npx ts-node test/paxos-sandbox.integration.ts
```

Expected output:
```
🧪  BlockHub × Paxos Sandbox Integration Tests
    Environment: SANDBOX

── 1. OAuth2 Token (client_credentials) ──────────────────
  ✅  Token obtained — expires in 3600s
  ✅  Token type: Bearer
  ✅  Scopes granted: ...

── 2. Market Data ─────────────────────────────────────────
  ✅  BTCUSD: bid=61900.00 ask=62100.00 mid=$62000.00
  ✅  ETHUSD: ...
  ✅  SOLUSD: ...
  ...

  Results: 15 passed, 0 failed
  🎉  All sandbox tests passed! Ready for integration.
```

---

## Step 5 — Start the Backend

```bash
npm run start:dev
```

Server starts on `http://localhost:3000`

---

## API Reference

### Auth

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/auth/register` | — | Create account |
| POST | `/api/v1/auth/verify-email` | — | Verify email |
| POST | `/api/v1/auth/login` | — | Login → JWT |
| POST | `/api/v1/auth/refresh` | — | Refresh access token |
| POST | `/api/v1/auth/logout` | JWT | Revoke refresh token |

### User

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/users/me` | JWT | Get profile + wallet_ready |

### Trading

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/trade/buy` | JWT | Buy crypto with USD |
| POST | `/api/v1/trade/sell` | JWT | Sell crypto for USD |

**Buy Request:**
```json
{ "asset": "BTC", "amount_usd": 1000 }
```

**Buy Response:**
```json
{
  "trade_id": "uuid",
  "asset": "BTC",
  "amount_usd": 1000,
  "fee": 5.00,
  "crypto_received": 0.01585,
  "execution_price": 62124.00,
  "status": "filled",
  "filled_at": "2026-04-09T12:00:05Z"
}
```

**Sell Request:**
```json
{ "asset": "BTC", "amount_crypto": 0.015 }
```

### Portfolio

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/portfolio` | JWT | Holdings + live PnL |
| GET | `/api/v1/transactions` | JWT | Trade history (paginated) |
| GET | `/market/prices` | — | Live prices (public) |

### Webhooks

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/webhooks/plaid` | HMAC | Plaid KYC status update |

---

## WebSocket

Connect to `ws://localhost:3000/ws` with your JWT:

```javascript
const socket = io('http://localhost:3000/ws', {
  auth: { token: '<your-access-token>' }
});

// Live prices (broadcast every 5s)
socket.on('price_BTC', (data) => console.log(data));
socket.on('price_ETH', (data) => console.log(data));

// Your portfolio updates (after each trade)
socket.on('portfolio_update', (data) => console.log(data));

// Your order status updates
socket.on('order_update', (data) => console.log(data));
```

---

## Run Tests

```bash
# Unit tests
npm test

# Unit tests with coverage
npm run test:cov

# Sandbox integration test (hits real Paxos sandbox)
npx ts-node test/paxos-sandbox.integration.ts
```

---

## Sandbox → Production Switch

The **only** change needed to go live:

```bash
# In .env (or AWS Secrets Manager):
NODE_ENV=production
```

This flips:
- OAuth token URL: `oauth.sandbox.paxos.com` → `oauth.paxos.com`
- API base URL: `api.sandbox.paxos.com` → `api.paxos.com`

All other code is identical.

> **Warning:** Never use production Paxos credentials in development.  
> All secrets must live in AWS Secrets Manager — never in `.env` files committed to the repo.

---

## Architecture Summary

```
Flutter App
    │  HTTPS + JWT
    ▼
API Gateway (NestJS — port 3000)
    ├── POST /auth/*          → AuthService
    ├── POST /trade/buy|sell  → TradingService ──► ComplianceService
    │                                          ──► WalletService
    │                                          ──► RevenueService (fees)
    │                                          ──► PaxosService (order)
    │                                          ──► PortfolioService
    │                                          ──► AuditService
    │                                          ──► BlockhubGateway (WS push)
    ├── GET  /portfolio        → PortfolioService + MarketDataService
    ├── GET  /market/prices    → MarketDataService (public)
    └── POST /webhooks/plaid  → WalletService.createForUser()

PaxosService (internal — NEVER exposed to client)
    ├── OAuth2 token cache (auto-refresh)
    ├── Exponential backoff retry (429/503/504)
    └── https://api.sandbox.paxos.com/v2

PostgreSQL (Prisma ORM)
    tables: users, wallets, trades, portfolio_holdings, revenues, audit_log

Redis
    └── Market price cache (5s TTL)

WebSocket (/ws)
    ├── price.{ASSET}      → broadcast every 5s
    ├── order.{userId}     → on order state change
    └── portfolio.{userId} → after every trade
```

---

*BlockHub v1.0 — Chronos Fintech · Internal Use Only*
