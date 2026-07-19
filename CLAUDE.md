# CHRONOS — Monorepo Root

## What This Is

CHRONOS is a fintech super-app. Four services, one repo. The backend handles all financial operations. Panther is the AI brain. BlockHub handles crypto/NFT. The mobile app is the user interface.

**Status**: Backend + BlockHub + Panther AI are live on AWS. Mobile is in development.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CHRONOS MOBILE                           │
│                    Flutter / Dart  (chronos/)                   │
└────────────────────────────┬────────────────────────────────────┘
                             │  HTTPS
          ┌──────────────────┴───────────────────┐
          ▼                                       ▼
┌─────────────────────┐              ┌─────────────────────────┐
│   CHRONOS BACKEND   │              │        BLOCKHUB         │
│   Express + TS      │◄────────────►│      NestJS + TS        │
│   Port 3000 (local) │  shared DB   │   Port 3002 (local)     │
│   :8080 (EB)        │              │   :8080 (EB)            │
└──────────┬──────────┘              └─────────────────────────┘
           │  HTTP (internal)
           ▼
┌─────────────────────┐
│     PANTHER AI      │
│  FastAPI + Python   │
│   Port 8000         │
└─────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────────┐
│                     AWS RDS PostgreSQL                          │
│        chronosdb.csjwyuqii28q.us-east-1.rds.amazonaws.com      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Services at a Glance

| Service | Tech | Local Port | Entry Point | Docs |
|---------|------|-----------|-------------|------|
| **Chronos Backend** | Node.js 20 + Express 5 + TypeScript | 3000 | `Chronos-Backend-/src/server.ts` | [CLAUDE.md](Chronos-Backend-/CLAUDE.md) |
| **BlockHub** | Node.js 24 + NestJS 11 + TypeScript | 3002 | `Chronos-Backend-/src/modules/blockhub/src/main.ts` | [CLAUDE.md](Chronos-Backend-/CLAUDE.md) |
| **Panther AI** | Python 3.12 + FastAPI | 8000 | `panther/Panther-AI-/PantherAI/main.py` | [CLAUDE.md](panther/Panther-AI-/PantherAI/CLAUDE.md) |
| **Mobile** | Flutter + Dart 3.7 | — | `chronos/lib/main.dart` | [README](chronos/README.md) |

---

## Live Production URLs

| Service | URL | Health Check |
|---------|-----|-------------|
| Chronos Backend | http://chronos.us-east-1.elasticbeanstalk.com | `GET /health` → `{"status":"ok"}` |
| BlockHub | http://blockhub-env.us-east-1.elasticbeanstalk.com | `GET /health` → `{"status":"ok"}` |
| Panther AI | Not yet on a public URL — runs as internal service | `GET /health` |

---

## Local Setup

### Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | 20+ | https://nodejs.org |
| Python | 3.12 | https://python.org |
| Flutter | 3.x | https://flutter.dev/docs/get-started/install |
| Git | any | — |

---

### 1. Chronos Backend (Express)

```bash
cd "Chronos-Backend-"

# Install deps (already done if node_modules/ exists)
npm install

# Copy env and fill in values
cp .env.example .env
# Edit .env — minimum required: DATABASE_URL, JWT_SECRET

# Start dev server (hot-reload via nodemon + tsx)
npm run dev
# → http://localhost:3000
# → Swagger UI: http://localhost:3000/api/docs
```

**Minimum `.env` for local dev:**
```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://chronos:chronosdbrds@chronosdb.csjwyuqii28q.us-east-1.rds.amazonaws.com:5432/chronosdb
JWT_SECRET=<run: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))">
DEPOSIT_MIN_AMOUNT=1
```

Optional keys (app boots and degrades gracefully without them): `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `ELEVENLABS_API_KEY`, `SMTP_*`, `PLAID_*`, `FCM_SERVICE_ACCOUNT`, `REDIS_HOST`.

Full env reference: [Chronos-Backend-/CLAUDE.md](Chronos-Backend-/CLAUDE.md#environment-variables)

---

### 2. BlockHub (NestJS)

BlockHub lives inside `Chronos-Backend-/` but is a separate NestJS app. Shares `node_modules` and the same PostgreSQL database.

```bash
cd "Chronos-Backend-"

# Dev (tsx direct execution)
npx tsx src/modules/blockhub/src/main.ts
# → http://localhost:3002

# Or with watch mode
npx nodemon --watch src/modules/blockhub --ext ts,js --exec "npx tsx src/modules/blockhub/src/main.ts"
```

**Minimum `.env` additions for BlockHub:**
```env
# BlockHub reads from the same .env as the main backend
# These are already covered if you set up backend .env above
```

Optional: `REDIS_URL` (NFT minting queue), `PAXOS_CLIENT_ID`, `PAXOS_CLIENT_SECRET`, `PAXOS_ENV`.

---

### 3. Panther AI (FastAPI)

```bash
cd "panther/Panther-AI-/PantherAI"

# Create and activate virtualenv
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Mac/Linux:
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy env (already exists if .env is present)
cp .env.example .env   # skip if .env already exists

# Start dev server
uvicorn main:app --reload
# → http://localhost:8000
# → Swagger UI: http://localhost:8000/docs
```

**Minimum `.env` for Panther AI:**
```env
ENVIRONMENT=development
LOG_LEVEL=DEBUG
ANTHROPIC_API_KEY=sk-ant-...
PANTHER_MODEL_PATH=services/TC-TransactionClassifier/models/distilbert_v1_colab/
CHRONOS_BACKEND_URL=http://localhost:3000
BLOCKHUB_URL=http://localhost:3002
```

Full env reference: [panther/Panther-AI-/PantherAI/.env.example](panther/Panther-AI-/PantherAI/.env.example)

---

### 4. Mobile (Flutter)

```bash
cd chronos

# Get packages
flutter pub get

# Run on connected device or emulator
flutter run

# Run on specific platform
flutter run -d chrome        # Web
flutter run -d ios           # iOS Simulator
flutter run -d android       # Android Emulator
```

The app points to the live backend by default. To use local backend, update the base URL in `lib/core/config/`.

---

## Running All Services at Once (Windows)

Open 3 terminals and run each service in its own:

**Terminal 1 — Backend:**
```powershell
cd "C:\Users\Nahom\Desktop\Chronos Full Code\Chronos-Backend-"
npm run dev
```

**Terminal 2 — Panther AI:**
```powershell
cd "C:\Users\Nahom\Desktop\Chronos Full Code\panther\Panther-AI-\PantherAI"
.venv\Scripts\activate
uvicorn main:app --reload --port 8000
```

**Terminal 3 — BlockHub (optional for crypto/NFT work):**
```powershell
cd "C:\Users\Nahom\Desktop\Chronos Full Code\Chronos-Backend-"
npx tsx src/modules/blockhub/src/main.ts
```

**Terminal 4 — Mobile (optional):**
```powershell
cd "C:\Users\Nahom\Desktop\Chronos Full Code\chronos"
flutter run
```

---

## Database

Shared PostgreSQL on AWS RDS. Both Chronos Backend and BlockHub connect to it.

```
Host:     chronosdb.csjwyuqii28q.us-east-1.rds.amazonaws.com
Port:     5432
DB:       chronosdb
User:     chronos
```

**Schema changes — run locally, never on EB:**
```powershell
cd "Chronos-Backend-"
$env:DATABASE_URL="postgresql://chronos:chronosdbrds@chronosdb.csjwyuqii28q.us-east-1.rds.amazonaws.com:5432/chronosdb"
npx prisma db push --accept-data-loss
```

**If RDS is offline (auto-stops after inactivity):** AWS Console → RDS → `chronosdb` → Actions → Start. Takes ~2 min.

**Prisma Studio (visual DB browser):**
```bash
cd "Chronos-Backend-"
npm run prisma:studio
# → http://localhost:5555
```

---

## Deployment

Both backend services deploy to AWS Elastic Beanstalk. Full deploy instructions in [Chronos-Backend-/CLAUDE.md](Chronos-Backend-/CLAUDE.md#aws-deployment-setup).

| Service | App Name | Environment | Platform |
|---------|----------|-------------|----------|
| Chronos Backend | `chronos-backend` | `chronos-backend-env` | Node.js 20 / Amazon Linux 2023 |
| BlockHub | `chronos-blockhub` | `blockhub-env` | Node.js 24 / Amazon Linux 2023 |

AWS credentials: `~/.aws/credentials` (persistent). Add to PATH if needed:
```powershell
$env:PATH += ";C:\Users\Nahom\AppData\Roaming\Python\Python313\Scripts"
```

---

## API Quick Reference

### Chronos Backend (port 3000 local / EB prod)

| Route | Purpose |
|-------|---------|
| `POST /api/v1/auth/register` | Create account |
| `POST /api/v1/auth/login` | Login, returns JWT |
| `GET  /api/home` | Dashboard |
| `GET  /api/core/accounts` | Bank accounts |
| `GET  /api/transactions` | Transaction ledger |
| `POST /api/ai/chris/chat` | Panther AI chat |
| `POST /api/ai/tickpay/affordability` | BNPL risk check |
| `GET  /api/lifex/*` | 11 LifeX modules |
| `GET  /health` | Health check (no auth) |
| `GET  /api/docs` | Swagger UI |

Full route list: [Chronos-Backend-/CLAUDE.md](Chronos-Backend-/CLAUDE.md#active-api-routes)

### BlockHub (port 3002 local / EB prod)

| Route | Purpose |
|-------|---------|
| `POST /api/v1/auth/register` | BlockHub register |
| `POST /api/v1/auth/login` | BlockHub login |
| `GET  /api/v1/crypto` | Crypto wallets |
| `POST /api/v1/nft` | NFT operations |
| `GET  /health` | Health check |

### Panther AI (port 8000)

| Route | Purpose |
|-------|---------|
| `POST /classify` | Classify a transaction |
| `POST /bnpl/risk-score` | BNPL affordability score |
| `GET  /health` | Health check |
| `GET  /docs` | Swagger UI |

---

## Postman

**Collection**: `Chronos-Backend-/Chronos-API.postman_collection.json` (~185 requests)
**Environment**: `Chronos-Backend-/Chronos-ENV.postman_environment.json`
**Base URL**: `http://chronos.us-east-1.elasticbeanstalk.com`

Token auto-saves on register (201) and login (200). Import both files into Postman and use the `Chronos-ENV` environment.

---

## What's Live vs Planned

### Live [LIVE]
- Auth (register, login, OTP, password reset)
- Bank accounts, cards, wallets, transfers, deposits
- Transaction ledger
- BNPL (TickPay)
- All 11 LifeX modules (education, health, finance, vision, activity, AI, export, family, social, spiritual, feed)
- Panther AI: Chris chat, alerts, BNPL scoring, user level, voice (transcribe + synthesize)
- Email notifications (20 event types)
- KYC via Plaid
- Redis-cached FX rates
- BlockHub: crypto wallets, buy/sell (Paxos sandbox), NFT minting/gallery/transfer
- Flutter mobile (auth, home, core features)

### Needs Env Keys on EB [NEEDS CONFIG]
- Email sending: `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS` not yet set on EB main API
- Push notifications: `FCM_SERVICE_ACCOUNT` not set on EB
- Voice transcription: `OPENAI_API_KEY` not set on EB
- Crypto trading: `PAXOS_CLIENT_ID`, `PAXOS_CLIENT_SECRET` not set on BlockHub EB
- Redis: not provisioned (ElastiCache/Upstash) — NFT queue and cache run in-memory fallback

### Planned [PLANNED]
- Firecrawl integration for marketplace search (`/api/ai/tickpay/search`)
- Redis on ElastiCache or Upstash for production queue + cache
- HTTPS/SSL on both EB environments
- AWS Secrets Manager for credentials
- LLM Queue (Tier 3) in Panther transaction classifier

---

## Docs Index

| Service | File | Contents |
|---------|------|----------|
| **Root** | `CLAUDE.md` ← you are here | Full platform overview |
| **Backend** | [Chronos-Backend-/CLAUDE.md](Chronos-Backend-/CLAUDE.md) | Stack, all routes, env vars, deploy commands, bug history |
| **Panther AI** | [panther/Panther-AI-/PantherAI/CLAUDE.md](panther/Panther-AI-/PantherAI/CLAUDE.md) | Vision, golden rules, pipeline architecture, project map |
| **Panther AI** | [panther/Panther-AI-/PantherAI/README.md](panther/Panther-AI-/PantherAI/README.md) | Folder structure, quick start |
| **Mobile** | [chronos/README.md](chronos/README.md) | Flutter project basics |
| **TC Architecture** | [panther/Panther-AI-/PantherAI/docs/PantherAI/TransactionClassifier/ARCHITECTURE.md](panther/Panther-AI-/PantherAI/docs/PantherAI/TransactionClassifier/ARCHITECTURE.md) | 3-tier classifier design |
| **Agent Rules** | [panther/Panther-AI-/PantherAI/.agent/rules/CLAUDE.md](panther/Panther-AI-/PantherAI/.agent/rules/CLAUDE.md) | AI agent behavior rules |

---

## Documentation Style

All docs in this project follow **Hormozi Rules**:
- Short sentences. If it takes two reads, rewrite it.
- No filler words. Cut "basically", "essentially", "in order to".
- Lead with the what, then the why.
- Label status: `[LIVE]` / `[PLANNED]` / `[DEPRECATED]`. Never let a reader confuse design from reality.
- One source of truth. Never duplicate. Link instead.
