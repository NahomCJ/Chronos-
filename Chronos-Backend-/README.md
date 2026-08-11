# Chronos Backend

A unified financial super-app backend combining core banking, BNPL credit, FX, KYC, AI, personal development, and crypto — built with Express 5, TypeScript, and Prisma on PostgreSQL.

**Main API** — `http://chronos.us-east-1.elasticbeanstalk.com` (legacy EB, migrating — see [Hosting](#hosting))  
**BlockHub** — `http://blockhub-env.us-east-1.elasticbeanstalk.com` (legacy EB, migrating — see [Hosting](#hosting))  
**Health check**: `GET /health` → `{"status":"ok"}`

---

## Table of Contents

| # | Section |
|---|---------|
| 1 | [Architecture](#architecture) |
| 2 | [Quick Start](#quick-start) |
| 3 | [Environment Variables](#environment-variables) |
| 4 | [API Reference — Auth](#auth) |
| 5 | [API Reference — Core Banking](#core-banking) |
| 6 | [API Reference — TickPay (BNPL)](#tickpay-bnpl) |
| 7 | [API Reference — LifeX](#lifex) |
| 8 | [API Reference — Panther AI](#panther-ai) |
| 9 | [API Reference — BlockHub](#blockhub-api) |
| 10 | [Notifications & Email](#notifications--email) |
| 11 | [Database](#database) |
| 12 | [AWS Deployment](#aws-deployment) |
| 13 | [Contributing](#contributing) |

---

## Architecture

Two apps share one repo — only the Express API is deployed to production:

| App | Entry Point | Framework | Port | Status |
|-----|------------|-----------|------|--------|
| Main API | `src/server.ts` | Express 5 + TypeScript | 3000 (local) / 8080 (EB) | **Live ✅** |
| BlockHub | `src/modules/blockhub/src/main.ts` | NestJS 11 | 3000 | **Live ✅** |

### Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js 20 + TypeScript 5 |
| Framework | Express 5 |
| ORM | Prisma 6 + PostgreSQL |
| Auth | JWT (HS256) + bcrypt |
| KYC / Bank Linking | Plaid Sandbox (IDV + Auth) |
| AI | Anthropic Claude (Panther) + OpenAI Whisper (STT) + ElevenLabs (TTS) |
| Email | Nodemailer (SMTP / SendGrid) |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Crypto | Paxos (BlockHub — live at blockhub-env) |
| Real-time | Socket.io (BlockHub GatewayModule) |
| Cache | Redis (optional — falls back to in-memory) |

### Folder Layout

```
src/
├── config/              # Prisma client, Plaid client, env wrappers
├── middlewares/         # Global Express middleware (auth, admin)
├── routes/              # Top-level route aggregator (index.ts)
└── modules/
    ├── auth/            # Registration, login, JWT, OTP, forgot/reset password
    ├── notification/    # Email (nodemailer), push (FCM), SMS stub
    ├── core/
    │   ├── accounts/    # Bank account CRUD
    │   ├── wallet/      # Ledger-first wallets
    │   ├── deposit/     # ACH deposit flow
    │   ├── transfer/    # Wallet-to-wallet + external transfers
    │   ├── kyc/         # Plaid IDV + bank linking + webhook verification
    │   ├── card/        # Virtual/physical cards, PIN, spending limits
    │   ├── currency/    # FX rates (Redis-cached, 5 min TTL)
    │   ├── fx/          # FX orders (quote + execute)
    │   ├── bill/        # Bill payments
    │   ├── transactions/ # Ledger + transaction history
    │   └── home/        # Dashboard aggregation
    ├── bnpl/            # TickPay — Buy Now Pay Later
    ├── lifex/           # Personal development super-module
    │   ├── education/   # Courses, scholarships, tutors, student loans
    │   ├── financial/   # Budgets, financial plans
    │   ├── health/      # Health metrics, habits, HSA
    │   ├── vision/      # Vision boards, long-term goals
    │   ├── activity/    # Activity logs, streaks, stats
    │   ├── ai/          # LifeX AI coach (insights, chat, weekly plan)
    │   ├── export/      # Data export (health, finance, education, vision)
    │   ├── family/      # Family groups, shared goals, shared budgets
    │   ├── social/      # Follow/unfollow, posts, likes, community feed
    │   ├── spiritual/   # Meditation, gratitude, spiritual goals
    │   └── feed/        # Unified personal + community feed
    ├── ai/              # Panther AI — Chris chat, alerts, voice, scoring
    └── blockhub/        # Crypto + NFT (NestJS, deployed separately)
```

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/NahomJan/Chronos-Backend-
cd Chronos-Backend-

# 2. Install
npm install

# 3. Configure environment
cp .env.example .env
# Fill in DATABASE_URL, JWT_SECRET

# 4. Generate Prisma client + push schema
npx prisma generate
npx prisma db push

# 5. Run dev server
npm run dev
```

Server starts on `http://localhost:3000`.

---

## Environment Variables

### Required

```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/chronos
JWT_SECRET=your_64_byte_hex_secret_here
DEPOSIT_MIN_AMOUNT=1
```

### Optional — app boots without these, features degrade gracefully

```env
# Plaid — KYC and bank linking
PLAID_CLIENT_ID=
PLAID_SECRET=
PLAID_ENV=sandbox
PLAID_IDV_TEMPLATE_ID=
PLAID_VERIFY_WEBHOOKS=true    # Set true in production to enforce Plaid signature verification

# Panther AI
ANTHROPIC_API_KEY=            # Required for Chris chat, AI alerts, LifeX AI coach

# Voice (Whisper + ElevenLabs)
OPENAI_API_KEY=               # Required for voice transcription
ELEVENLABS_API_KEY=           # Required for voice synthesis
ELEVENLABS_VOICE_ID=          # Optional — defaults to ElevenLabs Rachel

# Email (SendGrid or any SMTP)
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=your_sendgrid_api_key
SMTP_FROM="Chronos" <noreply@chronos.app>

# Push Notifications (Firebase)
FCM_SERVICE_ACCOUNT={"type":"service_account","project_id":"..."}  # Full JSON string

# Redis (optional — app falls back to in-memory cache without it)
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# Error monitoring
SENTRY_DSN=
```

---

## Auth

**Base URL**: `http://chronos.us-east-1.elasticbeanstalk.com/api/v1/auth`

No auth header required on any of these endpoints.

### Token Overview

| Token | Field | Expiry | Purpose |
|-------|-------|--------|---------|
| Access token | `accessToken` | **15 minutes** | Sent as `Authorization: Bearer <accessToken>` on every API request |
| Refresh token | `refreshToken` | **7 days** | Stored securely on device; used only to get a new access token |

**Recommended mobile flow:**
1. Login → store both `accessToken` and `refreshToken` in secure storage
2. Attach `accessToken` to every request header
3. On `401 Unauthorized` → call `POST /api/v1/auth/refresh` with the `refreshToken`
4. Replace the stored `accessToken` with the new one and retry the original request
5. If `/refresh` also returns `401`, the refresh token has expired → redirect to login

---

### Register

```
POST /api/v1/auth/register
```

```json
{
  "email": "user@example.com",
  "password": "SecurePass123",
  "firstName": "Nahom",
  "lastName": "Teklay"
}
```

Response `201`:
```json
{
  "user": { "id": "...", "email": "...", "firstName": "...", "role": "USER" },
  "accessToken": "<jwt — expires in 15 min>",
  "refreshToken": "<jwt — expires in 7 days>"
}
```

> Sends a **welcome email** to the user on success.

### Login

```
POST /api/v1/auth/login
```

```json
{ "email": "user@example.com", "password": "SecurePass123" }
```

Response `200`: same shape as register — `user`, `accessToken`, `refreshToken`.

### Refresh Access Token

```
POST /api/v1/auth/refresh
```

```json
{ "refreshToken": "<your refresh token>" }
```

Response `200`:
```json
{ "accessToken": "<new jwt — expires in 15 min>" }
```

| Status | Meaning |
|--------|---------|
| `200` | New access token issued |
| `400` | `refreshToken` field missing from body |
| `401` | Token invalid, tampered, or expired — user must log in again |

### Forgot Password

```
POST /api/v1/auth/forgot-password
```

```json
{ "email": "user@example.com" }
```

Sends a **6-digit OTP email** valid for 15 minutes. Response is always the same regardless of whether the email exists (prevents enumeration).

In non-production: response also includes `dev_otp` for testing.

### Reset Password

```
POST /api/v1/auth/reset-password
```

```json
{
  "email": "user@example.com",
  "otp": "123456",
  "newPassword": "NewSecurePass123"
}
```

Sends a **password changed confirmation email** on success.

---

## Core Banking

All endpoints require `Authorization: Bearer <jwt>`.

### Accounts — `/api/core/accounts`

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/create` | Create a bank account |
| `GET` | `/` | List user's accounts |
| `GET` | `/:id` | Get single account |
| `GET` | `/:id/statements` | Account statements |
| `POST` | `/freeze` | Freeze an account |
| `POST` | `/upgrade-tier` | Upgrade account tier |

### Wallets — `/api/wallet`

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/create` | Create a wallet |
| `GET` | `/list/:accountId` | List wallets for account |
| `GET` | `/get/:walletId` | Get wallet by ID |
| `POST` | `/cashout` | Cash out wallet balance |

### Cards — `/api/cards`

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/issue` | Issue a new card |
| `GET` | `/` | List cards |
| `GET` | `/:id` | Get card by ID |
| `PATCH` | `/:id/status` | Freeze / unfreeze card |
| `PUT` | `/:id/pin` | Change card PIN |
| `PUT` | `/:id/spending-limits` | Set daily/monthly limits |
| `POST` | `/:id/replace` | Replace a card |

> Card events (issued, frozen, PIN changed, replaced) send **email notifications**.

### Transfers — `/api/v1/transfer`

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/` | Create transfer (internal or external) |
| `GET` | `/` | List user's transfers |
| `GET` | `/:id` | Get transfer by ID |
| `POST` | `/:id/cancel` | Cancel a pending transfer |

Transfer body:
```json
{
  "fromWalletId": "...",
  "toWalletId": "...",         // for internal transfer
  "toExternal": { ... },       // for external transfer
  "amount": 100,
  "currency": "USD",
  "note": "Rent",
  "reference": "idempotency-key"
}
```

> Sends **email notification** on completed, failed, or cancelled.

### Transactions — `/api/transactions`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | List transactions (paginated, filterable) |
| `GET` | `/:id` | Get transaction detail |

Query params: `?page=1&limit=20&type=TRANSFER&status=COMPLETED&from=2026-01-01&to=2026-04-01`

### Bills — `/api/bills`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/providers` | List bill providers |
| `POST` | `/pay` | Pay a bill |
| `GET` | `/history` | Bill payment history |

Pay body:
```json
{ "providerId": "...", "amount": 50 }
```

> Sends **email receipt** on payment.

### FX — `/api/fx`

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/quote` | Get an FX quote (valid 5 min) |
| `POST` | `/execute` | Execute a quoted order |

Quote body:
```json
{
  "fromWalletId": "...",
  "toWalletId": "...",
  "buyCurrency": "EUR",
  "sellCurrency": "USD",
  "amount": 500,
  "amountType": "SELL"
}
```

> Sends **FX executed email** with sell/buy amounts and rate.

### Currency Rates — `/api/currency`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/rate/:base/:quote` | Latest rate (Redis-cached 5 min) |
| `POST` | `/convert` | Convert amount between currencies |
| `GET` | `/history/:base/:quote` | Historical rates by date range |

### KYC — `/api/kyc`

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/session` | Create a Plaid IDV session |
| `GET` | `/profile` | Get KYC profile |
| `POST` | `/link-token` | Create Plaid Link token (bank linking) |
| `POST` | `/exchange-token` | Exchange public token after bank link |
| `GET` | `/auth` | Get linked bank account + routing numbers |
| `POST` | `/webhook` | Plaid webhook receiver (no auth — Plaid-signed) |

> Webhook signature verification uses `jose` JWT verification against Plaid's JWK endpoint. Set `PLAID_VERIFY_WEBHOOKS=true` to enforce.  
> KYC approval/rejection sends **email notifications** to the user.

### Home / Dashboard — `/api/home`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/summary` | Balance, recent transactions, quick stats |
| `GET` | `/spending-analysis` | Spending breakdown by category |
| `GET` | `/offers` | Personalized offers |

---

## TickPay (BNPL)

**Base URL**: `/api/tickpay`  
All endpoints require `Authorization: Bearer <jwt>`.

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/account` | Create TickPay account |
| `GET` | `/account` | Get TickPay account |
| `POST` | `/card` | Issue TickPay virtual card |
| `POST` | `/purchase` | Create BNPL purchase |
| `GET` | `/purchases` | List purchases |
| `GET` | `/purchases/:id` | Get purchase detail |
| `GET` | `/installments` | List upcoming installments |
| `POST` | `/repay` | Make a repayment |
| `GET` | `/score` | Get BNPL credit score |

> Purchase approval/denial sends **email notifications**. AI affordability scoring available via `/api/ai/tickpay/affordability`.

---

## LifeX

**Base URL**: `/api/lifex`  
All endpoints require `Authorization: Bearer <jwt>`.

### Education — `/api/lifex/education`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/courses` | Browse courses |
| `GET` | `/courses/:id` | Course detail |
| `POST` | `/courses/:id/enroll` | Enroll in course |
| `GET` | `/scholarships` | List scholarships |
| `GET` | `/tutors` | Browse tutors |
| `POST` | `/tutors/:id/book` | Book a tutor session |
| `POST` | `/loans/apply` | Apply for a student loan |
| `GET` | `/loans` | List loan applications |

### Health — `/api/lifex/health`

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/metrics` | Log a health metric |
| `GET` | `/metrics` | Get health metrics |
| `POST` | `/habits` | Log a habit |
| `GET` | `/habits` | List habits |
| `GET` | `/habits/streak` | Get habit streak |
| `GET` | `/hsa` | Get HSA balance |
| `POST` | `/hsa/contribute` | Contribute to HSA |
| `GET` | `/appointments` | List appointments |
| `POST` | `/appointments` | Book appointment |

### Vision — `/api/lifex/vision`

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/boards` | Create a vision board |
| `GET` | `/boards` | List vision boards |
| `POST` | `/boards/:id/goals` | Add goal to board |
| `GET` | `/goals` | List all goals |
| `PATCH` | `/goals/:id/progress` | Update goal progress |

### Financial — `/api/lifex/finance`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/budgets` | List budgets |
| `POST` | `/budgets` | Create budget |
| `GET` | `/plans` | List financial plans |
| `POST` | `/plans` | Create financial plan |

### Activity — `/api/lifex/activity`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | List activity logs |
| `POST` | `/` | Log an activity |
| `GET` | `/stats` | Activity stats by module/type |
| `GET` | `/streak` | Current activity streak |

Activity log body:
```json
{
  "module": "health",
  "type": "workout",
  "title": "Morning run",
  "metadata": { "distanceKm": 5 }
}
```

### Family — `/api/lifex/family`

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/groups` | Create a family group |
| `GET` | `/groups` | List my family groups |
| `GET` | `/groups/:id` | Get group detail |
| `POST` | `/groups/:id/members` | Add member to group |
| `DELETE` | `/groups/:id/members/:userId` | Remove member |
| `GET` | `/groups/:id/goals` | List group goals |
| `POST` | `/groups/:id/goals` | Create group goal |
| `POST` | `/groups/:id/goals/:goalId/contribute` | Contribute to goal |
| `GET` | `/groups/:id/budgets` | List group budgets |
| `POST` | `/groups/:id/budgets` | Create group budget |

### Social — `/api/lifex/social`

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/follow/:userId` | Follow a user |
| `DELETE` | `/follow/:userId` | Unfollow a user |
| `GET` | `/followers` | List my followers |
| `GET` | `/following` | List who I follow |
| `POST` | `/posts` | Create a post |
| `GET` | `/posts` | Feed (my posts + following) |
| `GET` | `/posts/me` | My posts only |
| `DELETE` | `/posts/:id` | Delete a post |
| `POST` | `/posts/:id/like` | Like a post |
| `DELETE` | `/posts/:id/like` | Unlike a post |

Post body:
```json
{
  "content": "Just hit my savings goal!",
  "type": "ACHIEVEMENT",
  "metadata": { "goalId": "..." }
}
```

### Spiritual — `/api/lifex/spiritual`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/dashboard` | Spiritual dashboard summary |
| `POST` | `/meditation` | Log a meditation session |
| `GET` | `/meditation` | List meditation sessions |
| `GET` | `/meditation/stats` | Meditation stats |
| `POST` | `/gratitude` | Add gratitude entry |
| `GET` | `/gratitude` | List gratitude entries |
| `POST` | `/goals` | Create spiritual goal |
| `GET` | `/goals` | List spiritual goals |
| `PATCH` | `/goals/:id/progress` | Update goal progress |
| `GET` | `/streak` | Meditation streak |

Meditation body:
```json
{
  "durationMin": 15,
  "type": "mindfulness",
  "moodBefore": 5,
  "moodAfter": 8,
  "notes": "Very calming session"
}
```

### LifeX AI Coach — `/api/lifex/ai`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/insights` | AI-generated insights across all LifeX domains |
| `POST` | `/chat` | Chat with LifeX AI coach |
| `GET` | `/weekly-plan` | AI-generated 7-day personal development plan |

Chat body:
```json
{ "message": "Help me build a morning routine" }
```

> Requires `ANTHROPIC_API_KEY`.

### Data Export — `/api/lifex/export`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Export health data |
| `GET` | `/finance` | Export financial data |
| `GET` | `/education` | Export education data |
| `GET` | `/vision` | Export vision board data |
| `GET` | `/full` | Full LifeX data export |

### Feed — `/api/lifex/feed`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | Personal feed (activities, posts, goals, meditations) |
| `GET` | `/community` | Community feed (posts from followed users) |
| `GET` | `/summary` | Today's stats aggregate |

Feed items are sorted newest first and include activities, social posts, vision goals, and meditation sessions in a unified timeline.

---

## Panther AI

**Base URL**: `http://chronos.us-east-1.elasticbeanstalk.com/api/ai`  
All endpoints require `Authorization: Bearer <jwt>`.

> `ANTHROPIC_API_KEY` must be set in EB environment variables for AI to function.

### Chris Chat

```
POST /api/ai/chris/chat
```

```json
{
  "message": "How much did I spend this month?",
  "responseMode": "text"
}
```

`responseMode`: `"text"` (default) or `"voice"`

Response:
```json
{
  "reply": "Based on your recent transactions...",
  "domain": "BANKING",
  "userLevel": "BEGINNER",
  "timestamp": "2026-04-25T..."
}
```

### AI Alerts

```
GET    /api/ai/alerts             # List active alerts
POST   /api/ai/alerts/generate    # Generate alerts for the user
DELETE /api/ai/alerts/:id         # Dismiss an alert
```

Alert object:
```json
{
  "id": "...",
  "type": "LOW_BALANCE | HIGH_RISK | BNPL_OVERDUE | BNPL_UTILIZATION | CASHFLOW",
  "domain": "BANKING | TICKPAY | LIFEX | BLOCKHUB",
  "message": "Your TickPay utilization is above 80%",
  "severity": "INFO | WARNING | CRITICAL",
  "read": false,
  "createdAt": "..."
}
```

### BNPL Affordability Check

```
POST /api/ai/tickpay/affordability
```

```json
{ "amount": 250, "merchant": "Apple Store" }
```

Response:
```json
{
  "approved": true,
  "riskScore": 0.3,
  "maxAmount": 400,
  "message": "You can afford this purchase.",
  "reasoning": "..."
}
```

### User Level (Onboarding Quiz)

```
GET  /api/ai/user-level            # BEGINNER | INTERMEDIATE | ADVANCED
PUT  /api/ai/user-level            # { "level": "INTERMEDIATE" }
POST /api/ai/user-level/quiz       # Score onboarding quiz
```

Quiz body (`a` = beginner, `b` = intermediate, `c` = advanced):
```json
{ "answers": { "q1": "a", "q2": "b", "q3": "c", "q4": "a", "q5": "b" } }
```

### Voice

```
POST /api/ai/voice/transcribe    # multipart/form-data, field: "audio" → { "text": "..." }
POST /api/ai/voice/synthesize    # { "text": "Hello" } → audio/mpeg binary stream
```

Requires `OPENAI_API_KEY` (Whisper) and `ELEVENLABS_API_KEY` (ElevenLabs TTS).

### Marketplace Search *(scaffold — Firecrawl not connected)*

```
POST /api/ai/tickpay/search
{ "query": "iPhone 15" }
```

### BlockHub Portfolio

```
GET /api/ai/blockhub/portfolio
```

---

## BlockHub API

**Base URL**: Chronos Backend, same host as the main API

BlockHub crypto trading is mounted in the Chronos Express API for the backend-only Paxos sandbox sprint. It shares the same JWT — log in via the main API and use the same token here.

All endpoints require `Authorization: Bearer <jwt>` unless marked public.

### Market Prices (public)

```
GET /api/v1/crypto/price/:asset → Price for a single asset, e.g. /api/v1/crypto/price/BTC
```

Response:
```json
{ "asset": "BTC", "market": "BTCUSD", "price": 68420.50, "source": "paxos" }
```

### Crypto Portfolio

```
GET /api/v1/crypto              → Wallet status, Paxos balances, holdings, supported assets
POST /api/v1/crypto/account     → Create or return the user's Paxos sandbox identity/profile
GET /api/v1/crypto/history      → Trade history plus Paxos transfer references
```

Query params for transactions: `?page=1&limit=20&asset=BTC&from=2026-01-01&to=2026-04-30`

`POST /api/v1/crypto/account` is idempotent. It returns `201` when a new Paxos identity/profile is created and `200` when the local Paxos account mapping already exists. The user must have approved KYC and Paxos credentials must be configured.

Response:
```json
{
  "created": true,
  "paxos": { "configured": true, "environment": "sandbox" },
  "wallet": {
    "status": "ready",
    "id": "wallet-id",
    "paxosCustomerId": "identity-id",
    "paxosWalletId": "profile-id",
    "createdAt": "2026-06-06T00:00:00.000Z"
  }
}
```

### Crypto Trading

```
POST /api/v1/crypto/buy         → Buy crypto with USD
POST /api/v1/crypto/sell        → Sell crypto for USD
```

Buy body:
```json
{ "asset": "BTC", "amount_usd": 5 }
```

Sell body:
```json
{ "asset": "ETH", "amount_crypto": 0.05 }
```

### NFT — Browse

```
GET  /api/v1/nft                          → Browse all NFTs (filterable)
GET  /api/v1/nft/:id                      → NFT detail
GET  /api/v1/nft/:id/history              → Ownership + transaction history
GET  /api/v1/nft/collections              → All collections (paginated)
GET  /api/v1/nft/collections/:id          → Collection detail + its NFTs
POST /api/v1/nft/:id/favorite             → Toggle favorite
```

### NFT — Minting

```
POST /api/v1/minting/mint                 → Start async mint (multipart/form-data)
GET  /api/v1/minting/status/:jobId        → Poll mint job status
POST /api/v1/minting/collection/create    → Deploy a new NFT collection (Admin/Creator role)
```

Mint form fields (`multipart/form-data`):

| Field | Type | Notes |
|-------|------|-------|
| `image` | file | JPG/PNG/GIF/WEBP/MP4, max 50 MB |
| `name` | text | NFT name |
| `description` | text | |
| `collectionId` | text | Target collection ID |
| `royaltyPercent` | text | e.g. `5` |
| `attributes` | text | JSON array: `[{"trait_type":"Rarity","value":"Rare"}]` |

Mint response: `{ "jobId": "..." }` — poll `/api/v1/minting/status/:jobId` until `status: "COMPLETED"`.

### NFT — Marketplace

```
GET    /api/v1/marketplace                  → Browse active listings
GET    /api/v1/marketplace/:listingId       → Listing detail
GET    /api/v1/marketplace/my/listings      → My active listings
GET    /api/v1/marketplace/my/purchases     → My purchase history (paginated)
POST   /api/v1/marketplace/list             → List an NFT for sale
POST   /api/v1/marketplace/buy             → Buy a listed NFT
DELETE /api/v1/marketplace/:listingId       → Cancel a listing
```

List body:
```json
{ "nftId": "...", "priceUsd": 250, "currency": "USD" }
```

Buy body:
```json
{ "listingId": "...", "walletId": "..." }
```

### NFT — Portfolio

```
GET /api/v1/portfolio/nfts        → All NFTs owned by the user
GET /api/v1/portfolio/summary     → Portfolio stats (floor value, total minted, royalties earned)
GET /api/v1/portfolio/royalties   → Creator royalty earnings history (paginated)
```

### BlockHub Health (public)

```
GET /health    → { "status": "ok", "database": "connected" }
```

---

## Notifications & Email

The notification system fires automatically — mobile clients don't need to do anything special.

### What triggers emails

| Event | Email |
|-------|-------|
| User registers | Welcome email |
| Forgot password | OTP code (6 digits, 15 min expiry) |
| Password reset | Confirmation |
| Transfer completed | Amount + currency |
| Transfer failed | Amount + reason |
| Transfer cancelled | Amount |
| Card issued | Card type + last 4 |
| Card replaced | New card last 4 |
| Card frozen | Last 4 + security note |
| Card PIN changed | Security confirmation |
| Bill payment | Provider + amount + reference |
| FX order executed | Sell/buy amounts + rate |
| KYC approved | Verification success |
| KYC rejected | Retry instructions |
| Bank re-auth required | Reconnect bank prompt |
| TickPay account created | Account ready |
| TickPay card issued | Card ready |
| BNPL purchase approved | Amount + merchant |
| BNPL purchase denied | Amount + merchant |

### Push Notifications

Push is sent alongside email when the user's `deviceToken` is stored. Send the FCM device token on login:

```
PUT /api/notifications/device-token
{ "deviceToken": "<FCM_TOKEN>" }
```

### In-App Notifications — `/api/notifications`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | List notifications (unread first) |
| `PATCH` | `/read-all` | Mark all as read |
| `PATCH` | `/:id/read` | Mark one as read |
| `DELETE` | `/:id` | Delete notification |

---

## Database

- **ORM**: Prisma 6
- **Production DB**: AWS RDS PostgreSQL `chronosdb` (us-east-1)
- **Schema**: [`prisma/schema.prisma`](prisma/schema.prisma)

```bash
npx prisma generate           # Regenerate client (run after schema changes)
npx prisma db push            # Push schema to DB (dev/staging)
npm run prisma:studio         # Visual DB browser
```

> **Production schema changes**: Run `npx prisma db push --accept-data-loss` locally with `DATABASE_URL` pointed at RDS. Never run directly on the production host.

---

## Hosting

**[PLANNED]** Migrating off AWS Elastic Beanstalk — the S3-zip-upload workflow below is retired; too much time went into debugging EB itself instead of the app. New host TBD. Until the move is done, both apps still run on their old EB environments:

| Resource | Details |
|----------|---------|
| Main API (legacy EB) | `chronos-backend-env` — `http://chronos.us-east-1.elasticbeanstalk.com` |
| BlockHub (legacy EB) | `blockhub-env` — `http://blockhub-env.us-east-1.elasticbeanstalk.com` |
| Database | AWS RDS PostgreSQL `chronosdb` — not part of the migration, stays put |

Build commands are host-agnostic and unchanged:
```bash
# Main API
npx prisma generate
npm run build      # → dist/, run with: node dist/server.js

# BlockHub
npx tsc -p tsconfig.blockhub.json   # → dist-blockhub/, run with: node dist-blockhub/main.js
```

`.ebextensions/`, the root `Procfile`, and the `zip:blockhub` script have been removed — they only existed to package EB's S3-zip deploy format.

### BlockHub Environment Variables

| Key | Value |
|-----|-------|
| `NODE_ENV` | `production` |
| `JWT_SECRET` | 64-byte hex string |
| `DATABASE_URL` | `postgresql://chronos:...@chronosdb...` |
| `REDIS_URL` | Redis URL (optional — NFT minting queue; app starts without it) |
| `PAXOS_ENV` | `sandbox` or `production` |
| `PAXOS_CLIENT_ID` | Paxos API credentials |
| `PAXOS_CLIENT_SECRET` | Paxos API credentials |
| `PAXOS_PROFILE_ID` | Platform Paxos profile ID for sandbox smoke tests |
| `PAXOS_SETTLEMENT_PROFILE_ID` | Optional settlement profile for internal transfer checks |

### Main API Environment Variables to Set

Set on whatever host is running the app (currently: EB Console → `chronos-backend-env` → Configuration → Environment properties):

| Key | Value |
|-----|-------|
| `NODE_ENV` | `production` |
| `DATABASE_URL` | `postgresql://chronos:...@chronosdb...` |
| `JWT_SECRET` | 64-byte hex string |
| `ANTHROPIC_API_KEY` | Required for Chris + LifeX AI |
| `OPENAI_API_KEY` | Required for voice transcription |
| `ELEVENLABS_API_KEY` | Required for voice synthesis |
| `SMTP_HOST` | `smtp.sendgrid.net` |
| `SMTP_PORT` | `587` |
| `SMTP_USER` | `apikey` |
| `SMTP_PASS` | SendGrid API key |
| `SMTP_FROM` | `"Chronos" <noreply@chronos.app>` |
| `FCM_SERVICE_ACCOUNT` | Firebase service account JSON (stringified) |
| `PLAID_VERIFY_WEBHOOKS` | `true` |

---

## Contributing

### Branch Strategy

```
main         → production-ready, protected
feature/*    → new features (PR into main)
fix/*        → bug fixes
chore/*      → tooling, deps, refactors
```

### PR Checklist

- [ ] `npm run build` passes (no new errors in active modules)
- [ ] `npx prisma generate` run after any schema changes
- [ ] New env vars documented in README and `.env.example`
- [ ] All routes have `requireAuth` middleware
- [ ] No secrets committed
- [ ] New module wired into `src/routes/index.ts` or `lifex.routes.ts`

### Deployment Checklist — Main API

**[PLANNED]** Steps below through "create EB version" reflect the legacy EB workflow until the new host is chosen.

- [ ] `npx prisma generate` locally
- [ ] `npm run build`
- [ ] If schema changed: `npx prisma db push` locally with production `DATABASE_URL`
- [ ] Deploy `dist/`, `node_modules`, `package.json`, `prisma/` to the host
- [ ] Verify `GET /health` returns `{"status":"ok"}`
- [ ] Run Newman: `newman run Chronos-API.postman_collection.json`

### Deployment Checklist — BlockHub

- [ ] `npx tsc -p tsconfig.blockhub.json`
- [ ] Deploy `dist-blockhub/`, `node_modules`, `package.json`, `prisma/` to the host (run with `node dist-blockhub/main.js`)
- [ ] Verify `GET /health` returns `{"status":"ok"}`
