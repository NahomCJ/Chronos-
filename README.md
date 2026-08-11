# Chronos — Fintech Super-App

A full-stack fintech platform with AI-powered financial tools, crypto/NFT trading, BNPL, and a Flutter mobile app.

---

## Architecture

```
┌─────────────────────────────────────────────┐
│            CHRONOS MOBILE (Flutter)          │
└──────────────┬──────────────────────────────┘
               │ HTTPS
    ┌──────────┴──────────┐
    ▼                     ▼
┌──────────────┐   ┌──────────────────┐
│  CHRONOS API │   │    BLOCKHUB      │
│  Express/TS  │◄─►│   NestJS/TS     │
│  Port 3000   │   │   Port 3002      │
└──────┬───────┘   └──────────────────┘
       │ HTTP
       ▼
┌──────────────┐
│  PANTHER AI  │
│  FastAPI/Py  │
│  Port 8000   │
└──────┬───────┘
       ▼
┌─────────────────────────────────────┐
│            Neon Postgres            │
│           (chronosdb)               │
└─────────────────────────────────────┘
```

---

## Services

| Service | Tech | Port | Status |
|---------|------|------|--------|
| **Chronos Backend** | Node.js 20 · Express 5 · TypeScript | 3000 | ✅ Live on AWS EB |
| **BlockHub** | Node.js 24 · NestJS 11 · TypeScript | 3002 | ✅ Live on AWS EB |
| **Panther AI** | Python 3.12 · FastAPI | 8000 | Internal service |
| **Mobile App** | Flutter · Dart 3.7 | — | In development |

---

## Live URLs

| Service | URL |
|---------|-----|
| Chronos Backend | http://chronos.us-east-1.elasticbeanstalk.com |
| BlockHub | http://blockhub-env.us-east-1.elasticbeanstalk.com |
| Swagger Docs | http://chronos.us-east-1.elasticbeanstalk.com/api/docs |

---

## Quick Start

### 1. Backend (Express API)

```bash
cd Chronos-Backend-
npm install
cp .env.example .env   # fill in values
npm run dev
# → http://localhost:3000
```

Minimum `.env`:
```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://<user>:<password>@<project>-pooler.<region>.aws.neon.tech/chronosdb?sslmode=require
DIRECT_URL=postgresql://<user>:<password>@<project>.<region>.aws.neon.tech/chronosdb?sslmode=require
JWT_SECRET=<64-byte hex>
DEPOSIT_MIN_AMOUNT=1
```
Both connection strings come from the Neon dashboard → project → Connect.

### 2. BlockHub (NestJS)

```bash
cd Chronos-Backend-
npx tsx src/modules/blockhub/src/main.ts
# → http://localhost:3002
```

### 3. Panther AI (FastAPI)

```bash
cd panther/Panther-AI-/PantherAI
python -m venv .venv
.venv\Scripts\activate          # Windows
source .venv/bin/activate        # Mac/Linux
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
# → http://localhost:8000
```

### 4. Flutter App

```bash
cd chronos
flutter pub get
flutter run -d chrome        # Web (opens browser automatically)
flutter run -d android       # Android emulator
flutter run -d ios           # iOS simulator
```

---

## Features

### Core Banking
- Account management, virtual/physical cards
- Wallet transfers, ACH deposits
- Real-time FX rates and currency exchange
- Transaction ledger

### TickPay (BNPL)
- Buy Now Pay Later — 0% APR installment plans
- AI affordability scoring via Panther AI
- Active plan tracking with payment reminders
- Rewards points system

### BlockHub (Crypto & NFT)
- Crypto wallets — BTC, ETH, SOL
- Buy/sell via Paxos API
- NFT minting, gallery, and transfers
- Real-time portfolio tracking

### Panther AI
- **Chris** — conversational AI assistant for financial actions
- Voice transcription (Whisper) + synthesis (ElevenLabs)
- Transaction classification (DistilBERT)
- Portfolio rebalancing suggestions
- BNPL risk scoring

### LifeX (11 Modules)
Education · Health · Finance · Vision · Activity · AI Coach · Export · Family · Social · Spiritual · Feed

---

## API Reference

### Auth
```
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/forgot-password
POST /api/v1/auth/reset-password
```

### Core
```
GET  /api/home                        Dashboard
GET  /api/core/accounts               Bank accounts
GET  /api/transactions                Ledger
GET  /api/wallet                      Wallets
POST /api/v1/transfer                 Transfer funds
POST /api/fx/quote                    FX rate quote
POST /api/fx/execute                  Execute FX order
```

### AI
```
POST /api/ai/chris/chat               AI chat
POST /api/ai/tickpay/affordability    BNPL risk check
GET  /api/ai/alerts                   AI alerts
GET  /api/ai/user-level               User financial level
POST /api/ai/voice/transcribe         Voice to text
POST /api/ai/voice/synthesize         Text to voice
```

### BlockHub
```
GET  /api/v1/crypto                   Crypto wallets
POST /api/v1/nft                      NFT operations
GET  /health                          Health check
```

---

## Project Structure

```
Chronos Full Code/
├── Chronos-Backend-/          # Express API + BlockHub (NestJS)
│   ├── src/
│   │   ├── modules/
│   │   │   ├── auth/          # JWT auth, OTP, password reset
│   │   │   ├── ai/            # Panther AI routes
│   │   │   ├── bnpl/          # TickPay BNPL
│   │   │   ├── blockhub/      # NestJS crypto/NFT app
│   │   │   ├── lifex/         # 11 LifeX modules
│   │   │   ├── notification/  # Email + push notifications
│   │   │   └── wallet/        # Wallets, transfers, FX
│   │   └── routes/            # Route index
│   └── prisma/                # Database schema
│
├── panther/                   # Panther AI service
│   └── Panther-AI-/PantherAI/
│       ├── main.py            # FastAPI entry point
│       └── services/          # TC classifier, BNPL scorer
│
├── chronos/                   # Flutter mobile app
│   └── lib/
│       ├── core/              # Router, DI, network, theme
│       └── features/          # Auth, home, exchange, blockhub, panther, profile
│
└── README.md
```

---

## Deployment

**[PLANNED]** Migrating off AWS Elastic Beanstalk — new host TBD. Build steps are unchanged:
```bash
cd Chronos-Backend-
npx prisma generate
npm run build
```
See [Chronos-Backend-/CLAUDE.md](Chronos-Backend-/CLAUDE.md#hosting--migrating-off-aws-elastic-beanstalk) for current hosting status.

### Required environment variables
- `DATABASE_URL` (Neon, pooled), `DIRECT_URL` (Neon, unpooled — for migrations), `JWT_SECRET`, `NODE_ENV=production`
- `ANTHROPIC_API_KEY` — Panther AI chat
- `SMTP_*` — Email notifications
- `FCM_SERVICE_ACCOUNT` — Push notifications

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.x · Dart 3.7 · BLoC · GoRouter |
| Backend | Node.js 20 · Express 5 · TypeScript · Prisma 6 |
| BlockHub | Node.js 24 · NestJS 11 · Socket.io |
| AI | Python 3.12 · FastAPI · Anthropic Claude · DistilBERT |
| Database | PostgreSQL (Neon) |
| Auth | Firebase Auth · JWT (HS256) · bcrypt |
| Storage | AWS S3 · Elastic Beanstalk |
| Payments | Plaid (KYC/ACH) · Paxos (crypto) |
| Media | Pexels API · ElevenLabs (TTS) · OpenAI Whisper (STT) |

---

## Local Dev — All Services (Windows)

```powershell
# Terminal 1 — Backend
cd "Chronos-Backend-"; npm run dev

# Terminal 2 — Panther AI
cd "panther\Panther-AI-\PantherAI"; .venv\Scripts\activate; uvicorn main:app --reload --port 8000

# Terminal 3 — Flutter
cd "chronos"; flutter run -d chrome

# Terminal 4 — BlockHub (optional)
cd "Chronos-Backend-"; npx tsx src/modules/blockhub/src/main.ts
```

---

*Built by Nahom Teklay*
