# Integrations

External service integrations used across Chronos.

---

## Plaid

**Used by:** KYC module (`src/modules/core/kyc/`)  
**Config:** `src/config/plaid.ts`

| Product | Purpose |
|---------|---------|
| Identity Verification (IDV) | KYC — photo ID, selfie, address verification |
| Auth | Bank account linking for ACH deposits |

See [kyc.md](kyc.md) for full integration details.

**Keys needed:**
```env
PLAID_CLIENT_ID=
PLAID_SECRET=
PLAID_ENV=sandbox
PLAID_IDV_TEMPLATE_ID=
```

---

## Paxos

**Used by:** BlockHub module (`src/modules/blockhub/`)

Institutional-grade crypto brokerage and custody API.

| Capability | Usage |
|-----------|-------|
| Identity + Profile creation | Wallet provisioning after KYC |
| USD balance | Pre-trade balance check |
| Crypto balance | Pre-trade balance check |
| Market price | Real-time price for fee calculation |
| Market orders | BUY/SELL execution |
| Order polling | Detect FILLED status |

**Keys needed:**
```env
PAXOS_API_URL=https://api.sandbox.paxos.com/v2
PAXOS_CLIENT_ID=
PAXOS_CLIENT_SECRET=
PAXOS_PROFILE_ID=
```

---

## Akoya

**Path:** `src/modules/akoya/` + `src/modules/integrations/services/akoya.service.ts`

Open banking data network — alternative to Plaid for account aggregation and read-only financial data access.

**Status:** Integration scaffolded, implementation in progress.

**Keys needed:**
```env
AKOYA_CLIENT_ID=
AKOYA_CLIENT_SECRET=
AKOYA_BASE_URL=
```

---

## Moralis

**Path:** `src/modules/crypto/integrations/` + `src/modules/integrations/services/moralis.service.ts`

On-chain data API — used for NFT metadata, wallet balances, and blockchain analytics for the crypto module.

**Keys needed:**
```env
MORALIS_API_KEY=
MORALIS_API_URL=https://deep-index.moralis.io/api/v2
```

---

## FinGPT

**Path:** `src/modules/integrations/services/fingpt.service.ts`

AI-powered financial data and sentiment analysis.

**Status:** Scaffolded, integration in progress.

**Keys needed:**
```env
FINGPT_API_KEY=
FINGPT_BASE_URL=
```

---

## Sentry

**Path:** `src/server.ts` (initialized at startup)

Error tracking and performance monitoring.

```env
SENTRY_DSN=
```

---

## Kevin AI

**Path:** `src/modules/ai/kevin-ai/`

Chronos's internal AI assistant for financial guidance and chat.

---

## Adding a New Integration

1. Create `src/modules/integrations/services/<name>.service.ts`
2. Create `src/modules/integrations/config/<name>.config.ts` for the base URL and keys
3. Add env vars to `.env.example` with comments
4. Document here in this file
