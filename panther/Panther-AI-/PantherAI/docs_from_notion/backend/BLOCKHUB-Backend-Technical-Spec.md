# BLOCKHUB — Backend Technical Spec

**Stack assumption:** Node.js (TypeScript), NestJS or Express with modular structure, Prisma + PostgreSQL, Redis (cache/locks/queues), BullMQ (or Bull) for background jobs, Docker, Kubernetes/ECS for deployment.

---

## 1 — High Level Architecture (Backend only)

```
Clients (Web, Mobile)
    ↓ HTTPS
API Gateway (nginx / ALB) -> Auth Middleware (JWT)
    ↓
Backend Monolith / Microservices (NestJS)
    ├─ Auth Service
    ├─ User Service
    ├─ Wallet Service (blockchain interaction)
    ├─ Trading Service (orders, swaps)
    ├─ NFT Service (mint/list/marketplace)
    ├─ Portfolio Service
    ├─ AI Research Service (embeddings, LLM calls)
    ├─ Notification Service
    └─ Admin Service
    ↓
Postgres (Prisma)  Redis (cache, locks)  BullMQ (jobs)
    ↓
External Integrations:
  - Blockchain nodes/providers (Alchemy, Infura, QuickNode)
  - Moralis (NFT + token metadata + indexing)
  - On-chain indexer (The Graph / custom indexer)
  - Swap aggregators (1inch, 0x, Uniswap)
  - Market data (CoinGecko, CoinMarketCap)
  - Custodial provider (optional) / Custody APIs
  - KYC provider (Sumsub/Persona/Onfido)
  - Payment provider (Fiat on/off ramps: Moonpay/Transak/Stripe)
  - Storage (S3 for metadata/images)

```

---

## 2 — Repo & Folder Structure (recommended)

```
chronos-backend/
├─ src/
│  ├─ modules/
│  │  ├─ auth/
│  │  │  ├─ auth.controller.ts
│  │  │  ├─ auth.service.ts
│  │  │  ├─ auth.routes.ts
│  │  │  └─ auth.dto.ts
│  │  ├─ users/
│  │  ├─ wallet/
│  │  │  ├─ wallet.controller.ts
│  │  │  ├─ wallet.service.ts
│  │  │  ├─ wallet.provider.ts         # blockchain providers wrapper
│  │  │  └─ wallet.utils.ts
│  │  ├─ trading/
│  │  │  ├─ trading.controller.ts
│  │  │  ├─ trading.service.ts
│  │  │  ├─ orderbook.service.ts
│  │  │  ├─ swap.service.ts
│  │  │  └─ trading.dto.ts
│  │  ├─ nft/
│  │  │  ├─ nft.controller.ts
│  │  │  ├─ nft.service.ts
│  │  │  ├─ mint.service.ts
│  │  │  └─ nft.dto.ts
│  │  ├─ portfolio/
│  │  ├─ ai/
│  │  ├─ notifications/
│  │  └─ admin/
│  ├─ jobs/
│  │  ├─ indexer.job.ts
│  │  ├─ reconcile.job.ts
│  │  └─ alerts.job.ts
│  ├─ config/
│  │  ├─ moralis.config.ts
│  │  ├─ nodeProviders.config.ts
│  │  └─ env.ts
│  ├─ models/
│  │  └─ prisma.ts
│  ├─ middlewares/
│  ├─ utils/
│  ├─ app.ts
│  └─ server.ts
├─ prisma/
│  └─ schema.prisma
├─ scripts/
├─ .env.example
├─ Dockerfile
└─ README.md

```

---

## 3 — Database Design (Prisma) — core tables

Paste into `prisma/schema.prisma` and run `prisma generate` / `prisma migrate`.

```
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum UserRole {
  USER
  ADMIN
  CREATOR
}

model User {
  id            String   @id @default(uuid())
  email         String   @unique
  password      String?
  displayName   String?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  role          UserRole @default(USER)
  wallets       Wallet[]
  kycStatus     String   @default("PENDING")
  profile       Json?
}

model Wallet {
  id            String   @id @default(cuid())
  userId        String
  chain         String
  address       String
  type          String   // NONCUSTODIAL | CUSTODIAL
  meta          Json?
  createdAt     DateTime @default(now())
  user          User     @relation(fields: [userId], references: [id])
  transactions  Transaction[]
  nfts          NFT[]    @relation("owner")
  @@unique([chain, address])
}

model Transaction {
  id            String   @id @default(cuid())
  walletId      String
  txHash        String?  @unique
  type          String   // SEND | RECEIVE | SWAP | MINT
  amount        Decimal? @db.Decimal(30, 18)
  token         String?
  chain         String
  status        String   // PENDING | SUCCESS | FAILED
  meta          Json?
  createdAt     DateTime @default(now())
  wallet        Wallet   @relation(fields: [walletId], references: [id])
}

model Order {
  id            String   @id @default(cuid())
  userId        String
  pair          String
  side          String   // BUY | SELL
  type          String   // MARKET | LIMIT | STOP
  price         Decimal? @db.Decimal(30, 18)
  amount        Decimal  @db.Decimal(30, 18)
  filledAmount  Decimal  @db.Decimal(30, 18) @default("0")
  status        String   // OPEN | PARTIAL | FILLED | CANCELED
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  user          User     @relation(fields: [userId], references: [id])
}

model NFTCollection {
  id            String   @id @default(cuid())
  name          String
  slug          String   @unique
  creatorId     String
  contract      String
  chain         String
  metadata      Json?
  createdAt     DateTime @default(now())
  creator       User     @relation(fields: [creatorId], references: [id])
  nfts          NFT[]
}

model NFT {
  id            String   @id @default(cuid())
  tokenId       String
  contract      String
  chain         String
  ownerWalletId String?
  metadataUrl   String
  metadata      Json?
  price         Decimal? @db.Decimal(30, 18)
  currency      String?
  status        String   // LISTED | SOLD | NOT_LISTED
  createdAt     DateTime @default(now())
  owner         Wallet?  @relation("owner", fields: [ownerWalletId], references: [id])
}

model PriceSnapshot {
  id        String   @id @default(cuid())
  symbol    String
  chain     String?
  price     Decimal  @db.Decimal(30, 18)
  source    String
  ts        DateTime @default(now())
}

```

Notes:

- Use `Decimal` for monetary precision.
- Keep NFT metadata as JSON (IPFS links, traits).
- `Wallet.type` distinguishes custodial vs non-custodial.

---

## 4 — Key Backend Services & Responsibilities

### 4.1 Auth Service

- JWT access & refresh tokens (rotate refresh tokens).
- SIWE endpoint for Ethereum login.
- RBAC (roles in DB).
- Session tracking (store refresh tokens in DB/Redis).

### 4.2 User Service

- Profile, KYC status, preferences, email/sms verification.
- Upload and store KYC documents to S3, store metadata.

### 4.3 Wallet Service (critical)

- Manage wallet creation (non-custodial via client-side key generation) and custodial wallets (via custody provider or MPC).
- Provider wrapper for node interactions: `wallet.provider.ts` (abstract Alchemy/Infura/QuickNode).
- Balance polling & on-chain event listeners (via WebSockets or Alchemy webhooks).
- Transaction signing (for custodial) or building transactions for client signing (non-custodial).
- Gas estimation, nonce management, retries.

### 4.4 Indexer / On-chain Sync

- Use Moralis + optional custom indexer (The Graph or custom).
- Jobs to sync:
    - token balances
    - ERC-20 transfers
    - NFT transfers / mint events
    - marketplace events (list/buy)
- Persist events into `Transaction`, `NFT`, and `PriceSnapshot`.

### 4.5 Trading Service

- Spot orders management (if offering internal orderbook) OR routing to DEX aggregators.
- Swap service integrates with 1inch / 0x / Uniswap.
- Order matching (if internal) — care for matching engine scale. For MVP, prefer swap aggregation and market orders.
- WebSocket endpoints for real-time orderbook & trades.

### 4.6 NFT Service

- Mint workflow (create metadata → upload to IPFS/S3 → call smart contract).
- Listing/purchase workflow (smart contract call or marketplace escrow).
- Royalty enforcement (on-chain via ERC-2981).
- Collection management and approvals (admin moderation).

### 4.7 Market Data Service

- Fetch rates from CoinGecko / CoinMarketCap / exchange APIs.
- Normalize and store snapshots in `PriceSnapshot`.

### 4.8 AI Research Service (optional)

- Embed market news & token docs (Pinecone or vector DB).
- LLM-based insights (OpenAI/Anthropic) but with safe prompts/guardrails.

### 4.9 Notifications Service

- Push, Email, SMS for tx status, price alerts, NFT drops.

### 4.10 Jobs / Workers

- Indexing job (continuous)
- Reconciliation job (settlements / fiat integration)
- Alerts job (price/nft floor)
- Retry job for failed transactions / webhooks

---

## 5 — Integrations & Providers

### 5.1 Moralis

- Use Moralis SDK / REST to:
    - Fetch token balances
    - Fetch NFT metadata (resolve IPFS)
    - Webhook subscriptions for transfers/events
- `src/config/moralis.config.ts` holds base url & API key.

### 5.2 Node Providers (Alchemy / Infura / QuickNode)

- RPC endpoints per chain: eth, polygon, bsc, solana separate providers.
- Use a provider factory to switch/resiliency:
    - Try Alchemy → fallback to Infura → fallback to QuickNode.
- Websocket subscriptions for pending tx / events.

### 5.3 Swap Aggregators

- 1inch / 0x / Paraswap or use native DEX on chain.
- For multiple chains, use chain-specific aggregators (Jupiter for Solana).

### 5.4 Custodial Providers (optional)

- For custodial wallets, integrate vendor SDK (Fireblocks, BitGo, or custodian partner).
- Use their APIs for address generation, signing, and transfers.

### 5.5 Off-ramp / On-ramp (Fiat)

- Integrate Transak / Moonpay / Ramp for fiat → crypto.
- Use Stripe for fiat card payments if necessary.

### 5.6 KYC / AML

- Persona / Sumsub / Onfido for document verification.
- Hook verification status into `User.kycStatus`.

### 5.7 Storage

- S3 for NFT metadata images and original files.
- Pinning service for IPFS (Pinata / Infura IPFS).

---

## 6 — API Endpoints (Representative)

All endpoints under `/api/v1`.

### Auth

- `POST /auth/register` — register user.
- `POST /auth/login` — password login.
- `POST /auth/siwe` — sign-in-with-ethereum.
- `POST /auth/refresh` — refresh token.
- `POST /auth/logout` — revoke refresh.

### Users

- `GET /users/me` — profile.
- `POST /users/kyc` — upload docs.
- `GET /users/:id/wallets` — list wallets.

### Wallets

- `POST /wallets` — create custodial wallet (admin) or register non-custodial address.
- `GET /wallets/:chain/:address/balance`
- `POST /wallets/:chain/send` — custodial send (signed via custody provider)
- `POST /wallets/:chain/prepare-tx` — create unsigned tx for client to sign

### Trading / Swap

- `POST /trading/swap` — request swap estimate + tx build
    - body: `{ userId, chain, fromToken, toToken, amount, slippage }`
- `POST /trading/order` — create order (if internal)
- `GET /trading/orderbook/:pair` — snapshot

### NFTs

- `POST /nft/collections` — create collection (creator)
- `POST /nft/mint` — mint (admin/creator flow)
- `POST /nft/list` — list NFT for sale
- `POST /nft/buy` — buy NFT (triggers tx)
- `GET /nft/:contract/:tokenId` — get metadata

### Portfolio

- `GET /portfolio/summary` — holdings + net worth
- `GET /portfolio/history` — historical net worth

### Admin

- `GET /admin/transactions`
- `POST /admin/collections/approve`

---

## 7 — Event Flows (Examples)

### 7.1 Mint Flow (NFT)

1. Creator uploads metadata → backend validates → stores to S3/IPFS.
2. Backend calls smart contract (if custodial) or returns signed tx for creator to sign.
3. On tx confirmed (Moralis webhook), backend updates `NFT` row, sets owner to creator wallet.
4. Admin may list collection as featured.

### 7.2 Buy NFT Flow

1. Buyer triggers `/nft/buy` — backend builds tx or uses escrow smart contract.
2. If custodial, backend initiates custody transfer via provider; else, provides tx for buyer signature.
3. On confirmation, update `NFT.status = SOLD`, record transaction, and notify both parties.
4. Distribute royalties automatically via contract.

### 7.3 Swap Flow (on-chain DEX)

1. Client requests estimate `/trading/swap`.
2. Backend calls aggregator API and returns quote + route.
3. Client signs tx (non-custodial) or backend executes (custodial).
4. Monitor tx via websocket; on confirmation update `Transaction` and portfolio.

---

## 8 — Webhooks & Background Workers

- **Moralis webhooks**: bind to /webhooks/moralis — handle events (ERC20 transfer, NFT transfer). Validate signature & save events.
- **Node provider webhooks** (Alchemy) for pending tx confirmations.
- **On-ramp webhooks** (Transak / Moonpay) for fiat settlements.
- Use BullMQ workers to process:
    - tx confirmations
    - reconcile unsettled balances
    - notify users
    - run price alerts

---

## 9 — Security & Compliance

### 9.1 Authentication & Authorization

- JWT access token short lived (15 min), refresh token stored hashed in DB (rotation).
- RBAC middleware: routes guarded by roles.
- SIWE support for Web3 login (valid nonce check).

### 9.2 Secrets & Keys

- Use Secrets Manager (AWS Secrets Manager / Vault) for API keys & node provider keys.

### 9.3 PII & KYC

- Store KYC docs encrypted on S3 (server-side encryption).
- Hash personally identifying fields if needed.
- Maintain audit logs for KYC decisions.

### 9.4 Transaction Safety

- Nonce management for custodial wallets.
- Rate limit high-value operations.
- Implement multi-sig or approval flows for admin fund moves.

### 9.5 Smart Contract Safety

- Use vetted contracts; get external audits for minting marketplace & escrow.

---

## 10 — Testing Strategy

### 10.1 Unit Tests

- Jest + ts-jest for all services.
- Mock Prisma (use in-memory or test DB).

### 10.2 Integration Tests

- Docker-compose with Postgres + Redis for integration.
- Supertest to hit endpoints.

### 10.3 End-to-End Tests

- Use a staging environment with testnet nodes (Goerli, Mumbai).
- Use scripted flows: create wallet → mint NFT → list → buy.

### 10.4 Postman Collection

- Create collection for main flows: auth, wallet, swap, mint, buy.
- Automated Newman runner in CI.

---

## 11 — Observability & Monitoring

- **Logs**: pino/winston to structured logs → central log (Loki/CloudWatch).
- **Errors**: Sentry for exceptions.
- **Metrics**: Prometheus + Grafana (request latency, tx processing times, queue length).
- **Audits**: store important actions to `audit_logs` table (userId, action, payload, createdAt).

---

## 12 — Deployment & Infra

### 12.1 Containers

- Dockerfile per service; multi-stage build.
- Kubernetes (EKS/GKE) or ECS Fargate.

### 12.2 Database

- Managed Postgres (RDS / Cloud SQL / Neon).
- Backups daily; PITR enabled.

### 12.3 Redis & BullMQ

- Hosted Redis; ensure persistence for delayed jobs.

### 12.4 CI/CD

- GitHub Actions:
    - run lint, tests
    - build docker image
    - run migrations `prisma migrate deploy`
    - deploy to staging/prod

### 12.5 Secrets

- Store env in AWS Secrets Manager; reference in K8s via Secret.

---

## 13 — Scaling & Performance Considerations

- **Indexing**: Ensure DB indices on wallet address, txHash, token, createdAt.
- **Sharding**: Archive old transactions to time-series store if large.
- **Cache**: Price data and user portfolio summary cached in Redis (TTL 30s).
- **Rate limit**: protect swap endpoints and wallet sends.

---

## 14 — Data Privacy & Retention Policy

- KYC docs retention based on jurisdiction (e.g., 7 years).
- Users can request data deletion (GDPR) — soft-delete with legal hold override.
- Encrypt backups at rest.

---

## 15 — Example Code Skeletons

### 15.1 `wallet.provider.ts` (provider wrapper)

```tsx
import { ethers } from "ethers";

export class NodeProvider {
  providers: Record<string, ethers.providers.JsonRpcProvider>;

  constructor(config) {
    this.providers = {};
    for (const chain of Object.keys(config)) {
      this.providers[chain] = new ethers.providers.JsonRpcProvider(config[chain].rpc);
    }
  }

  async getBalance(chain: string, address: string) {
    const p = this.providers[chain];
    return p.getBalance(address);
  }

  async getTransaction(chain: string, txHash: string) {
    return this.providers[chain].getTransaction(txHash);
  }
}
export default new NodeProvider(require("../config/nodeProviders.config").default);

```

### 15.2 `nft.service.ts` snippet

```tsx
import prisma from "../models/prisma";
import Moralis from "moralis";

export class NftService {
  async createCollection(data) { /* create collection */ }
  async mintNFT(collectionId, metadataUrl, recipient) {
    // call smart contract or return tx for signing
  }
  async handleMoralisWebhook(evt) {
    // validate signature
    // update DB accordingly
  }
}

```

---

## 16 — Roadmap (implementation phases)

**MVP (0–3 months)**

- Auth, user, KYC integration
- Wallet registration + read-only balances
- Moralis integration for balance & NFT metadata
- Basic swap via 1inch
- NFT browse + mint (testnet)
- Postman collection + CI

**Phase 2 (3–6 months)**

- Custodial wallet support (partner)
- Payment on/off ramps
- Full marketplace buy/sell flows
- Orderbook or advanced swap routing
- Admin moderation tools

**Phase 3 (6–12 months)**

- Multi-region compliance
- MPC wallet or custodian integration scaled
- Derivatives / margin (if desired, regulatory heavy)
- Institutional APIs

---

## 17 — Security Checklist Before Production

- Smart contract audits
- Penetration test
- Secrets rotation
- Formal KYC/AML policy and procedures
- PCI compliance if handling cards
- SOC2 readiness plan

---

## 18 — Deliverables for Backend Engineer (Action items)

1. Create `prisma/schema.prisma` from schema above. Run migrations.
2. Implement `wallet.provider.ts` factory (Alchemy + Infura fallback).
3. Implement Moralis config & webhook route; wire to `jobs/indexer.job.ts`.
4. Build `wallet.service.ts`: balance poller + tx listener.
5. Build `nft.service.ts`: mint/list/buy logic (testnet first).
6. Build `trading.swap.service.ts`: integrate 1inch or 0x for quotes and tx build.
7. Add Redis + BullMQ: jobs for indexing and reconcile.
8. Add Postman collection of core flows and automate in CI (newman).
9. Add logging & Sentry integration.
10. Deploy staging to testnets (Goerli, Mumbai) — validate flows end-to-end.

---

## 19 — Testing Checklist (what to verify)

- Register user → create non-custodial wallet → show balance from Moralis.
- Mint NFT on testnet → Moralis webhook triggers → NFT appears in DB.
- Swap estimate → return quote → client signs tx → broadcast → tx confirmation handled.
- List NFT → buy NFT → confirm on-chain transfer & DB update.
- Price alert subscription → worker triggers notification when condition met.

---

## 20 — Final Notes & Next Steps

- Prefer **non-custodial** MVP to reduce regulatory burden. Add custodial only when you have partners & licensing.
- Use **Moralis** for quick indexing and metadata resolution — it speeds development massively.
- Keep `AI Research Service` isolated and with strict prompt guardrails (no trading calls that could be construed as personalized investment advice).
- Document every webhook and provider secret handling in README.
