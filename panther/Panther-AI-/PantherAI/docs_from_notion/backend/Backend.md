# Backend

Contents:

1. Goals & assumptions
2. High-level architecture
3. Folder / repo structure (VS Code ready)
4. Full Prisma schema (tokens, NFTs, wallets, orders, listings, trades, events)
5. Moralis integration module (config + service) — code you can drop in
6. Controller / service / route templates (skeletons + key methods)
7. API endpoints (full list) with example request/response for each main flow (mint, list, buy, transfer, wallet connect, portfolio)
8. Webhooks & scheduler (how to handle onchain events)
9. Custodial vs Semi-custodial design & recommended approach for Phase 1 (cost/time/pros/cons)
10. Security best practices (API key management, signing, rate limits)
11. Postman / testing checklist + unit/integration tests to write
12. Staging / deployment plan & env variables
13. UI pages mapping (~60 pages) — each feature → the backend endpoints/data it needs (for mobile/stitch design)
14. Prioritized Phase 1 deliverables & roadmap

---

## 1) Goals & assumptions

- Phase-1 goal: get a **semi-custodial** marketplace + custodial wallet flows working quickly using **Moralis** (read/write on chains, metadata, minting), enabling mobile app testing, NFT mint/list/buy/sell and basic token buy/sell flows.
- Chains initially supported: **Ethereum (testnets), Polygon (mainnet/testnet)**. Add others later.
- Moralis used for: indexer/data, NFT minting helper, on-chain calls, and webhook events.
- Custody: Phase 1 = **semi-custodial** (Chronos holds custodial keys for on-chain settlement but allow external linking via MetaMask as optional). This reduces complexity vs full custody.
- DB: **Postgres** via Prisma. Critical datamodels included below.

---

## 2) High-level architecture

```
Mobile App (Flutter)
     ↕ REST / GraphQL
Chronos API Gateway (Express / Nest)
     ├─ /api/v1/blockhub
     │    ├─ controllers (wallets, nft, marketplace, tokens)
     │    ├─ services (moralis, orders, custody, fees)
     │    ├─ integrations (moralis.config.ts)
     │    └─ jobs (webhook handlers, reconciliations)
     ├─ Core Banking (Chronos core)
     ├─ TickPay
     └─ AI (Kevin)
Moralis SDK & Webhooks
Blockchain nodes (Infura/Alchemy/Chain RPC)
Postgres (Prisma), Redis (locks/queues), S3 (media)

```

---

## 3) Folder structure (drop into `src/modules/blockhub`)

```
src/modules/blockhub/
├─ controllers/
│   ├─ wallet.controller.ts
│   ├─ nft.controller.ts
│   ├─ marketplace.controller.ts
│   ├─ token.controller.ts
│   └─ webhooks.controller.ts
├─ services/
│   ├─ moralis.service.ts
│   ├─ wallet.service.ts
│   ├─ nft.service.ts
│   ├─ marketplace.service.ts
│   ├─ order.service.ts
│   └─ reconciliation.service.ts
├─ jobs/
│   ├─ moralis.webhook.processor.ts
│   └─ reconcile.job.ts
├─ models/
│   └─ prisma.ts
├─ routes/
│   └─ blockhub.routes.ts
├─ validators/
│   └─ nft.validators.ts
├─ types/
│   └─ blockhub.types.ts
└─ README.md

```

---

## 4) Prisma schema (BlockHub portion)

Add the following to `prisma/schema.prisma`. It’s designed to be integrated with your existing `User`, `Account` models.

```
// BlockHub / NFT & Token models
model Wallet {
  id          String   @id @default(cuid())
  userId      String
  address     String   @unique
  type        WalletType  // CUSTODIAL | EXTERNAL
  chain       String    // e.g., "polygon", "ethereum"
  metadata    Json?
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  user        User      @relation(fields: [userId], references: [id])
  balances    TokenBalance[]
  nfts        NftOwnership[]
}

enum WalletType {
  CUSTODIAL
  EXTERNAL
}

model TokenBalance {
  id         String   @id @default(cuid())
  walletId   String
  tokenSymbol String
  tokenAddress String?
  balance    Decimal  @db.Decimal(30, 8)
  updatedAt  DateTime @updatedAt

  wallet     Wallet   @relation(fields: [walletId], references: [id])
}

model Nft {
  id            String   @id @default(cuid())
  tokenId       String   // on-chain token id (string)
  contract      String
  chain         String
  ownerWalletId String?
  creatorId     String?
  metadataUrl   String
  metadata      Json?
  mintedAt      DateTime?
  createdAt     DateTime @default(now())

  ownerWallet   Wallet?  @relation(fields: [ownerWalletId], references:[id])
  creator       User?    @relation(fields: [creatorId], references:[id])
  listings      Listing[]
  trades        Trade[]
}

model NftOwnership {
  id       String @id @default(cuid())
  nftId    String
  walletId String
  acquiredAt DateTime @default(now())

  nft      Nft   @relation(fields: [nftId], references: [id])
  wallet   Wallet @relation(fields: [walletId], references: [id])
}

enum ListingType { FIXED_PRICE, AUCTION }

model Listing {
  id            String   @id @default(cuid())
  nftId         String
  sellerWalletId String
  price         Decimal  @db.Decimal(30, 8)
  currency      String   // "USD" or on-chain token symbol
  type          ListingType @default(FIXED_PRICE)
  active        Boolean  @default(true)
  createdAt     DateTime @default(now())
  endsAt        DateTime?

  nft           Nft      @relation(fields: [nftId], references: [id])
  sellerWallet  Wallet   @relation(fields: [sellerWalletId], references: [id])
  offers        Offer[]
}

model Offer {
  id         String   @id @default(cuid())
  listingId  String
  buyerWalletId String
  amount     Decimal @db.Decimal(30, 8)
  currency   String
  status     String  // PENDING, ACCEPTED, REJECTED
  createdAt  DateTime @default(now())

  listing    Listing @relation(fields: [listingId], references: [id])
  buyerWallet Wallet @relation(fields: [buyerWalletId], references: [id])
}

model Trade {
  id          String   @id @default(cuid())
  nftId       String
  buyerWalletId String
  sellerWalletId String
  price       Decimal @db.Decimal(30, 8)
  currency    String
  txHash      String?
  chain       String
  createdAt   DateTime @default(now())

  nft         Nft      @relation(fields: [nftId], references: [id])
  buyer       Wallet   @relation("Buyer", fields: [buyerWalletId], references: [id])
  seller      Wallet   @relation("Seller", fields: [sellerWalletId], references: [id])
}

model TokenOrder {
  id          String @id @default(cuid())
  userId      String
  walletId    String
  tokenSymbol String
  amount      Decimal @db.Decimal(30, 8)
  price       Decimal? @db.Decimal(30, 8)
  side        String // BUY | SELL
  status      String // PENDING | FILLED | CANCELLED
  createdAt   DateTime @default(now())
  filledAt    DateTime?
}

```

Notes:

- Use Decimal for money.
- `Nft` stores canonical on-chain tokenId/contract/chain and metadataUrl (IPFS or S3).
- `Wallet.type` distinguishes custodial wallets (managed keys) vs external (user's MetaMask).

---

## 5) Moralis Integration Module

### `src/config/moralis.config.ts`

```tsx
// src/config/moralis.config.ts
const MORALIS_API_KEY = process.env.MORALIS_API_KEY || "";
const MORALIS_BASE = process.env.MORALIS_BASE_URL || "https://deep-index.moralis.io/api/v2";

export default {
  apiKey: MORALIS_API_KEY,
  baseUrl: MORALIS_BASE,
  webhookSecret: process.env.MORALIS_WEBHOOK_SECRET || "",
  defaultChain: process.env.MORALIS_DEFAULT_CHAIN || "polygon",
};

```

### `src/services/moralis.service.ts` (skeleton + key methods)

```tsx
// src/services/moralis.service.ts
import fetch from "node-fetch";
import moralisConfig from "../config/moralis.config";

function api(path: string, method = "GET", body?: any) {
  const url = `${moralisConfig.baseUrl}${path}`;
  const headers: any = {
    "X-API-Key": moralisConfig.apiKey,
    "Content-Type": "application/json",
  };
  return fetch(url, { method, headers, body: body ? JSON.stringify(body) : undefined })
    .then((r) => r.json());
}

export default class MoralisService {
  async getTokenBalance(address: string, chain = moralisConfig.defaultChain) {
    return api(`/erc20/${address}?chain=${chain}`);
  }

  async getNfts(address: string, chain = moralisConfig.defaultChain) {
    return api(`/nft/${address}?chain=${chain}`);
  }

  async mintNft(contractAddress: string, toAddress: string, metadataUri: string, chain = moralisConfig.defaultChain) {
    // recommended: use Moralis NFT API or run a transaction through provider (Alchemy/Infura)
    // Example endpoint (pseudo)
    return api(`/nft/mint`, "POST", { contractAddress, to: toAddress, uri: metadataUri, chain });
  }

  async transferNft(contractAddress: string, tokenId: string, from: string, to: string, chain = moralisConfig.defaultChain) {
    return api(`/nft/transfer`, "POST", { contractAddress, tokenId, from, to, chain });
  }

  async getTransaction(txHash: string) {
    return api(`/transaction/${txHash}`);
  }

  // Webhook verification
  verifyWebhookSignature(rawBody: Buffer, signature: string) {
    // Implement HMAC verification using moralisConfig.webhookSecret
    // return true/false
  }
}

export const moralisService = new MoralisService();

```

Notes:

- Moralis has multiple endpoints; prefer their official SDK for node (if available) or direct REST API.
- For minting you might need to send signed transactions from a custodial key (server) via a provider (Alchemy). Moralis can help or you can deploy an on-chain minting script.

---

## 6) Controller / Service templates (key flows)

I'll list skeletons — engineer can fill details from spec.

### `nft.service.ts` (key functions)

- `createMetadata(userId, metadataJson)` — store metadata on IPFS/S3, return metadataUri
- `mintNft(userId, contract, metadataUri)` — call moralisService.mintNft or send tx via provider, create `Nft` row with tokenId
- `listNft(userId, nftId, price, currency)` — create `Listing` row and mark `active`
- `buyListing(userId, listingId)` — funds flow:
    - lock listing (DB transaction)
    - escrow funds (from user wallet or Chronos custodial wallet)
    - call onchain transfer (custodial key or buyer signed tx)
    - create `Trade` record, mark listing inactive
    - distribute funds less fees to seller
- `transferNftOnChain(...)` — used for withdrawals/external transfers

### `wallet.service.ts`

- `createCustodialWallet(userId, chain)` — creates an onchain wallet (generate keypair or use custodian provider), store address & encrypted private key (if doing true custody) or use custody provider API
- `getOrCreateExternalLink(userId)` — stores external wallet addresses
- `getBalances(userId)` — aggregate TokenBalance and onchain balances via Moralis

### `marketplace.service.ts`

- `searchListings(filters)`
- `placeOffer(listingId, userId, amount)`
- `acceptOffer(offerId)`
- `cancelListing(listingId)`
- `reconcileOnChainEvents()` — ensure DB aligned to chain

---

## 7) API Endpoints (full list with examples)

Base: `/api/v1/blockhub`

### Wallet & Accounts

- `POST /wallets/custodial` — create custodial wallet for user

    **Body:** `{ chain: "polygon" }`

    **Response:** `{ wallet: { id, address, chain } }`

- `POST /wallets/link` — link external wallet (MetaMask)

    **Body:** `{ address, chain }` (server stores after verifying signature)

- `GET /wallets/:userId` — list wallets & balances
- `GET /wallets/:walletId/balances` — list token balances (calls Moralis + DB)

### NFT (creator)

- `POST /nft/metadata` — upload metadata (title, description, image)

    **Response:** `{ metadataUrl }`

- `POST /nft/mint` — mint new NFT (custodial mint)

    **Body:** `{ metadataUrl, contractAddress? }`

    **Response:** `{ nft: {...}, txHash }`


### Marketplace

- `POST /nft/:nftId/list` — create listing

    **Body:** `{ price, currency, type }`

- `GET /nft/listings` — search & filter marketplace
- `POST /listing/:id/buy` — buy a listing (handles escrow/settlement)

    **Body:** `{ paymentMethod: "WALLET"|"CARD"|"CRYPTO", walletId? }`

- `POST /listing/:id/offer` — make an offer on listing

    **Body:** `{ amount, currency }`

- `POST /offer/:id/accept` — accept offer (seller action)

### Trades & Orders

- `GET /orders/:userId` — token buy/sell orders (TokenOrder)
- `POST /token/order` — place market/limit order for token

    **Body:** `{ tokenSymbol, amount, side }`


### Withdrawals / Transfer

- `POST /nft/:nftId/withdraw` — withdraw NFT to external wallet

    **Body:** `{ toAddress }`

    *Will perform onchain transfer; requires KYC/limits check*


### Webhooks

- `POST /blockhub/webhooks/moralis` — Moralis webhook receiver (verify signature)
    - Handles events: Transfer, Mint, Sale, Approvals.

---

## 8) Webhooks & Scheduler

**Webhooks**:

- Receive Moralis notifications for on-chain events. Always verify signature using HMAC and `MORALIS_WEBHOOK_SECRET`.
- Typical events to handle:
    - `nft_minted` -> update `Nft` row with tokenId, mintedAt
    - `transfer` -> reconcile ownership; create `NftOwnership` entry
    - `nft_sold` -> create `Trade` entry and settle ledger
    - `erc20_transfer` -> update `TokenBalance` record

**Schedulers / Jobs**:

- `reconcile.job.ts` — run every 5–15 min: check pending txs for confirmations; reconcile failed/confirmed txs
- `relist.job.ts` — handle timed auctions expired
- `payout.job.ts` — settle and push payouts to seller (batch payouts via core banking or custodial payment rails)

---

## 9) Custodial vs Semi-Custodial vs Non-Custodial

**Non-Custodial (user controls keys, e.g., MetaMask)**

- Pros: Lower legal/risk burden, users control assets, less responsibility for Chronos.
- Cons: Harder UX for mobile (wallet connect flows), on-chain fees paid by user, complex mobile signing.

**Custodial (Chronos holds private keys)**

- Pros: Best UX (users tap and buy), offloads complexity from user, easier fiat on/off ramps.
- Cons: Heavy legal & compliance (KYC/AML), higher security/custody costs, insurance needs.

**Semi-Custodial (recommended Phase 1)**

- Chronos provides custodial wallets for in-app flows; users can link external wallets for withdrawal. Chronos holds keys but enforces KYC and limits.
- Pros: balanced UX & speed to market.
- Cons: still has custody costs; need secure key storage & HSM or custody provider.

**Recommendation:** Start Phase 1 as **Semi-Custodial** (Chronos holds keys in a secure, encrypted vault or via a custody provider like Fireblocks/Bitgo later). Allow external wallet linking for withdrawals.

---

## 10) Security best practices

- **Never store private keys in plaintext** — use HSM / vault (AWS KMS, HashiCorp Vault) or a custody provider.
- **Webhook verification**: HMAC using `MORALIS_WEBHOOK_SECRET`.
- **Idempotency keys**: For buy/list/mint endpoints support `Idempotency-Key` header.
- **Rate limiting** on endpoints to prevent abuse.
- **Transaction safety**: use DB transactions and row locks when moving ownership / funds.
- **PCI**: if taking card payments for NFT purchases, use Stripe and tokenized card flows.
- **KYC/AML**: ensure withdrawals/payouts run through KYC flags; limit unverified accounts.
- **Mask sensitive data** in logs (no private keys, no full addresses unless encrypted).
- **Monitoring**: set alerts for failed payouts, high pending tx counts, suspicious volume patterns.

---

## 11) Postman & Testing checklist

**Postman collection** should include:

- Auth flow (login, JWT)
- Wallet creation & link
- Upload metadata
- Mint NFT (simulate Moralis response)
- Create listing
- Buy listing (happy + failed insufficient funds)
- Make offer -> accept offer
- Withdraw NFT
- Webhook simulator (Moralis webhook payload)

**Tests to write**

- Unit tests for `nft.service` methods (mint, list, buy) with mocked moralisService
- Integration test: listing -> buy -> trade created; DB changes
- Webhook tests: valid signature vs invalid signature
- Reconciliation tests: pending tx -> confirmed -> reconcile owner
- Security tests: idempotency and double-buy prevention (race condition tests)

---

## 12) Env variables to add

```
MORALIS_API_KEY=
MORALIS_BASE_URL=
MORALIS_WEBHOOK_SECRET=
MORALIS_DEFAULT_CHAIN=polygon
INFURA_API_KEY=
ALCHEMY_API_KEY=
CUSTODY_PROVIDER_URL=
CUSTODY_API_KEY=
IPFS_GATEWAY_URL=
S3_BUCKET_NAME=
S3_ACCESS_KEY=
S3_SECRET_KEY=
HSM/KMS configs...
STRIPE_SECRET=
DATABASE_URL=
REDIS_URL=

```

---

## 13) UI pages mapping — **~60 pages** (each page mapped to backend endpoints & responsibilities)

Below I present a grouped list of pages (mobile & web) and what backend they require. This is long — I grouped by section and included endpoints the page will need to call. This gives your mobile designer + backend engineer exact contract.

### A. BlockHub Home & Discovery (8 pages)

1. **BlockHub Home (discover)** — calls `/nft/listings` (top picks), `/social/ai-recommendations` (if recommending)
2. **Trending NFTs** — `/nft/listings?sort=trending`
3. **Featured Collections** — `/collections/featured` (you may implement collections endpoint)
4. **New Listings** — `/nft/listings?sort=new`
5. **Categories / Filters** — search API `/nft/listings?q=&tags=&price_min=&price_max=`
6. **Artist Spotlight** — `/users/:creatorId/nfts`
7. **Video Panel (left) + BlockHub CTA** — static + `/nft/listings`
8. **Market Insights Panel** — `/market/insights` (AI-powered; optional)

### B. Wallet & Portfolio (7 pages)

1. **Wallet Dashboard** — `/wallets/:userId` (list wallets, balances)
2. **Token Portfolio** — `/wallets/:walletId/balances`
3. **NFT Portfolio** — `/wallets/:walletId/nfts` (calls moralis + DB)
4. **Add / Link External Wallet** — `/wallets/link` (signature verification)
5. **Create Custodial Wallet** — `/wallets/custodial`
6. **Wallet Details (Transactions)** — `/wallets/:walletId/transactions`
7. **Find Nearby On/Off Ramp** — static or partner API

### C. NFT Creation / Minting (6 pages)

1. **Create New NFT (form)** — POST `/nft/metadata` then `/nft/mint`
2. **Upload Media (images/video)** — IPFS / S3 upload endpoint `/media/upload`
3. **Set Royalties & Metadata** — includes fields in `/nft/metadata`
4. **Choose Collection/Contract** — `/collections` listing
5. **Mint Progress / Tx status** — `/nft/:id/status` poll via moralis/webhook
6. **Creator Dashboard** — list of owned & minted NFTs `/users/:id/nfts`

### D. NFT Listing & Marketplace (8 pages)

1. **Listing Form** — `/nft/:id/list` POST
2. **Listing Detail Page** — GET `/listings/:id`
3. **Make Offer Page** — POST `/listing/:id/offer`
4. **Accept Offer / Seller Actions Page** — POST `/offer/:id/accept`
5. **Auction (if used)** — `/listings/:id/bids`, place bid endpoint
6. **Seller Dashboard** — `/wallets/:id/listings`
7. **Collection Page (collection details)** — `/collections/:id`
8. **Search Results (market)** — `/nft/listings?q=...`

### E. Buying & Payments (7 pages)

1. **Buy Now / Checkout** — `POST /listing/:id/buy` (support multiple payment methods)
2. **Payment Methods (card/crypto/wallet)** — `/payment/methods`
3. **Payment Confirmation Page** — displays txHash & receipt `/trades/:id`
4. **Order History** — `/orders/:userId`
5. **Escrow Status Page** — `/orders/:orderId/status`
6. **Dispute / Claim Page** — `POST /trades/:id/dispute` (future)
7. **Receipt / Invoice** — `/trades/:id/receipt` (PDF)

### F. Token Trading (6 pages)

1. **Token Markets** — `/tokens/markets` (list tokens)
2. **Token Order Entry** — `POST /token/order` (market/limit)
3. **Order Book / Depth** — `/tokens/:symbol/orderbook` (maybe external/exchange)
4. **My Orders** — `/orders/:userId`
5. **Portfolio Token View** — integration with TokenBalance
6. **Top Movers / Market Insights** — `/market/insights/tokens`

### G. Creator & Collection Management (6 pages)

1. **Create Collection** — `/collections` POST
2. **Collection Editor** — `/collections/:id` PUT
3. **Creator Stats** — `/users/:id/stats` (sales, revenue)
4. **Royalty Setup Page** — part of mint/list metadata
5. **Bulk Minting Tools** — admin-only endpoints
6. **Creator Payouts Page** — `/payouts/:userId` (admin to payout)

### H. Account & Security (5 pages)

1. **KYC & Verification** — `/kyc/status` & file upload flows
2. **Withdrawal Limits & Settings** — `/user/:id/withdrawals/settings`
3. **API Keys & Integrations (for creators)** — manage API keys to auto-list etc.
4. **Security (2FA) & Device Management** — tie to core auth

### I. Admin & Reconciliation (6 pages)

1. **Admin Dashboard** — metrics: volume, pending txs, fees
2. **Pending Transactions** — list & reconcile `/admin/pending`
3. **Webhook Monitor & Replay** — `/admin/webhooks`
4. **Payout Queue** — `/admin/payouts`
5. **Fee & Royalties Reports** — `/admin/reports/fees`
6. **Fraud Alerts** — `/admin/fraud`

### J. Help & Docs (2 pages)

1. **Help / How it works** — static + endpoints for support
2. **Terms & Withdrawal Policy** — static + links to compliance pages

---

For each mobile page above, the backend endpoints shown are the *minimum* required. Many pages will poll `/nft/:id/status` or subscribe to change events via websockets or FCM push for instant updates once webhooks processed.

---

## 14) Phase 1 prioritized deliverables (what to build first)

**Sprint 1 (MVP — 2–4 weeks)**:

- Wallet: custodial wallet create, link external wallet (core flows)
- NFT: metadata upload (IPFS/S3), mint (testnet) via Moralis/provider
- Marketplace: list NFT (fixed-price), browse listings
- Buy flow: buy fixed-price listing (escrow logic), trade record creation
- Moralis webhooks: handle mint/transfer events & reconcile ownership
- Basic Admin: pending txs dashboard
- Security: webhook verification, idempotency

**Sprint 2**:

- Offers & accept offers
- Withdrawals (KYC gating)
- Token trading (simple market buy/sell via liquidity provider)
- Royalties & payout scheduler
- Admin reports & reconciliation automation

**Sprint 3+**:

- Auctions, advanced order types, custody provider integration, cross-chain flows, fiat rails, insurance.

---

## 15) Example code snippets (Buy flow: simplified)

Pseudo flow inside `marketplace.service.buyListing(listingId, buyerId)`:

1. Begin DB transaction.
2. Fetch listing row and lock it (SELECT FOR UPDATE).
3. Verify listing active and price.
4. Reserve buyer funds (if custodial: debit buyer custodial balance or create Hold record).
5. Create Trade row with status `PENDING`.
6. Call Moralis transfer function to transfer NFT onchain (seller -> buyer). If custodial, sign with Chronos custodian key or run a marketplace contract transfer.
7. Wait for tx confirmation (or poll); on confirmed:
    - Update Trade.txHash and status `COMPLETED`.
    - Update `Nft.ownerWalletId` to buyer wallet.
    - Mark listing inactive.
    - Release funds to seller less fees (create payout entry).
8. Commit DB transaction.
9. Send notifications to buyer & seller.

---

## 16) Testing & Postman sample

- Mint test:
    - Upload metadata -> call POST `/nft/metadata` -> returns metadataUrl
    - Call POST `/nft/mint` -> returns `nftId` and txHash
    - Poll `/nft/:nftId/status` or listen to webhook to confirm minted.
- Buy test:
    - Create listing -> POST `/nft/:id/list`
    - Use buyer account with custodial funds -> POST `/listing/:id/buy`
    - Simulate Moralis webhook of transfer or poll provider for tx

---

## 17) Deployment & staging plan

- Use a **Moralis test server** and blockchain testnets (Mumbai/Goerli) for dev & staging.
- Start with **staging DB** and `BLOCKHUB` feature flag.
- Map webhooks to staging endpoint first; verify signature handling.
- Deploy with containers (ECS/GCP) and setup a worker queue (BullMQ) for jobs to process webhooks reliably.
- Use Redis for locks and job queues.

---
