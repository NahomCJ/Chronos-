# BlockHub Backend

A cryptocurrency trading backend built with NestJS and TypeScript, powered by the Paxos API. Supports user registration, KYC via Plaid, wallet provisioning, and live BUY/SELL market orders for BTC, ETH, and SOL.

## Quick Start

```bash
# 1. Copy environment variables
cp .env.example .env

# 2. Start PostgreSQL and Redis
docker-compose up postgres redis -d

# 3. Install dependencies
npm install

# 4. Generate Prisma client and run migrations
npm run prisma:generate
npm run prisma:migrate:dev

# 5. Start the development server
npm run start:dev
```

API available at `http://localhost:3000/api/v1`

## Tech Stack

- **Framework:** NestJS 10 (TypeScript)
- **Database:** PostgreSQL 15 + Prisma ORM
- **Cache / Queue:** Redis + Bull
- **Auth:** JWT RS256 + bcrypt
- **Exchange:** Paxos API (sandbox + production)
- **Real-time:** Socket.io WebSocket gateway
- **KYC:** Plaid (webhook-based)

## Key Features

- JWT authentication with RS256 and refresh token rotation
- Plaid KYC → Paxos wallet provisioning
- Live market orders (BUY/SELL) with fee and spread calculation
- Portfolio tracking with real-time PnL
- WebSocket price and portfolio updates (every 5 seconds)
- Immutable audit log enforced at the database level
- Pre-trade compliance gate (KYC, daily limits, account status)

## Supported Assets

| Asset | Symbol |
|-------|--------|
| Bitcoin | BTC |
| Ethereum | ETH |
| Solana | SOL |

## Environment Variables

See [.env.example](.env.example) for the full list. Required variables:

```
DATABASE_URL        PostgreSQL connection string
REDIS_URL           Redis connection string
JWT_PRIVATE_KEY     RS256 private key
JWT_PUBLIC_KEY      RS256 public key
PAXOS_CLIENT_ID     Paxos OAuth2 client ID
PAXOS_CLIENT_SECRET Paxos OAuth2 client secret
```

Generate RSA keys:
```bash
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -out public.pem
```

## API Overview

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/auth/register` | — | Create account |
| POST | `/api/v1/auth/login` | — | Login → JWT tokens |
| POST | `/api/v1/auth/refresh` | — | Rotate access token |
| GET | `/api/v1/users/me` | JWT | Get profile |
| POST | `/api/v1/trade/buy` | JWT | Buy crypto |
| POST | `/api/v1/trade/sell` | JWT | Sell crypto |
| GET | `/api/v1/portfolio` | JWT | Holdings + PnL |
| GET | `/api/v1/transactions` | JWT | Trade history |
| GET | `/api/v1/market/prices` | — | Live prices (public) |

## Scripts

```bash
npm run start:dev           # Development server (watch mode)
npm run build               # Compile TypeScript
npm run start:prod          # Run compiled build
npm test                    # Unit tests
npm run test:cov            # Tests with coverage
npm run prisma:studio       # Open Prisma Studio GUI
npm run prisma:migrate:dev  # Create and run migrations
```

## Documentation

See [DOCUMENTATION.md](DOCUMENTATION.md) for the full reference:
- Complete API endpoint reference with request/response examples
- Full database schema
- Service architecture and trade flow walkthrough
- WebSocket events
- Security considerations
- Production deployment checklist
