# BlockHub Integrations

> Scope: backend only (Node.js + TypeScript), Prisma + PostgreSQL, Redis + BullMQ, Docker/K8s. Integrations:
>

(1) Wallet Provider

(2) Node Provider

(3) Portfolio/Indexing (Moralis/Covalent/etc.)

(4) Trade Execution (DEX aggregator)

---

## Quick links — provider docs (grab keys & SDKs here)

- **Wallet providers / SDKs**
    - WalletConnect (App + Wallet SDKs): [https://docs.walletconnect.com/](https://docs.walletconnect.com/) [docs.walletconnect.network+1](https://docs.walletconnect.network/wallet-sdk/overview?utm_source=chatgpt.com)
    - Coinbase Wallet SDK: [https://www.coinbase.com/developer-platform/products/wallet-sdk](https://www.coinbase.com/developer-platform/products/wallet-sdk?utm_source=chatgpt.com) (repo: [https://github.com/coinbase/coinbase-wallet-sdk](https://github.com/coinbase/coinbase-wallet-sdk?utm_source=chatgpt.com)). [Coinbase+1](https://www.coinbase.com/developer-platform/products/wallet-sdk?utm_source=chatgpt.com)
    - Magic (embedded wallets / passwordless): https://docs.magic.link/overview. [docs.magic.link+1](https://docs.magic.link/embedded-wallets/sdk/overview?utm_source=chatgpt.com)
    - Fireblocks (enterprise custodial): [https://developers.fireblocks.com/](https://developers.fireblocks.com/) (if you need institutional custody). [Fireblocks Developer Portal+1](https://developers.fireblocks.com/reference/api-overview?utm_source=chatgpt.com)
- **Node providers (RPC / WebSocket / Streams)**
    - Alchemy docs: [https://docs.alchemy.com/](https://docs.alchemy.com/) (APIs, webhooks, enhanced endpoints). [Alchemy](https://www.alchemy.com/docs?utm_source=chatgpt.com)
    - Infura: [https://infura.io/](https://infura.io/) (Ethereum & IPFS endpoints). [Infura](https://www.infura.io/?utm_source=chatgpt.com)
    - QuickNode: [https://www.quicknode.com/docs/welcome](https://www.quicknode.com/docs/welcome?utm_source=chatgpt.com) (multi-chain support, streams). [Quicknode+1](https://www.quicknode.com/docs/welcome?utm_source=chatgpt.com)
- **Portfolio / Indexing / NFT & token metadata**
    - Moralis Web3 Data API (NFT, token balances, websockets/webhooks): [https://docs.moralis.com/](https://docs.moralis.com/?utm_source=chatgpt.com) (NFT API examples). [docs.moralis.com+1](https://docs.moralis.com/?utm_source=chatgpt.com)
    - Covalent API: https://www.covalenthq.com/docs/ (useful for token balances & historical transfers). *(link in real doc; Covalent is a recommended alternative)*
- **Trade execution / Swap aggregators**
    - 0x API (swap/quote): [https://0x.org/docs](https://0x.org/docs) (Swap API docs).
    - 1inch API: [https://docs.1inch.io/](https://docs.1inch.io/)
    - ParaSwap API: https://www.paraswap.io/#/developer

        *(Use 0x/1inch/ParaSwap — pick 1 primary aggregator, add fallback)*


> Grab API keys at each provider’s console/dashboard. Use the SDK docs above for integration steps. Moralis | Enterprise-Grade Web3 APIs+4docs.walletconnect.network+4Coinbase+4
>

---

# 1. System overview (how the pieces fit)

```
Client (Web / Mobile)
  ⇅ Wallet SDK (WalletConnect / Coinbase Wallet / Magic)          ← user signs tx
  ⇅ API Gateway (auth)
    ⇅ Backend Services (NestJS/Express)
       • Auth, Users, KYC
       • Wallet Service (provider wrapper)
       • Node Provider Adapter (Alchemy / Infura / QuickNode)
       • Portfolio & Indexer (Moralis / Covalent)
       • Trading Service (0x / 1inch / ParaSwap)
       • NFT Service (mint, list, buy)
       • Jobs (indexing, reconcile)
       • Notifications
    ⇅ Postgres (Prisma) + Redis + BullMQ
External:
  - Moralis / Covalent (indexing, NFT metadata)
  - Node provider (Alchemy/Infura/QuickNode)
  - DEX aggregator (0x / 1inch / ParaSwap)
  - Custodial provider (optional: Fireblocks)
  - On/Off ramp (Transak / Moonpay)

```

**Key rules**

- Wallet SDKs let users sign and authorize — DO NOT send raw private keys to your servers for non-custodial users.
- Node provider broadcasts signed txs; aggregator returns quote + routing for swap tx payloads.
- Moralis (or Covalent) answers portfolio / NFT metadata / webhooks for on-chain events. [Moralis | Enterprise-Grade Web3 APIs+1](https://moralis.com/api/nft/?utm_source=chatgpt.com)

---

# 2. Repo & folder structure (recommended)

```
chronos-backend/
├─ src/
│  ├─ modules/
│  │  ├─ auth/
│  │  ├─ users/
│  │  ├─ wallet/                # wallet.controller.ts, wallet.service.ts, wallet.provider.ts
│  │  ├─ node/                  # node.provider.ts (alchemy/infura/quicknode adapter)
│  │  ├─ indexer/               # moralis.indexer.ts, webhooks
│  │  ├─ trading/               # swap.service.ts (0x/1inch), orders.service.ts
│  │  ├─ nft/
│  │  ├─ portfolio/
│  │  ├─ notifications/
│  │  └─ admin/
│  ├─ jobs/
│  ├─ config/
│  ├─ utils/
│  ├─ models/
│  │  └─ prisma.ts
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

# 3. Prisma schema (core models — copy to `prisma/schema.prisma`)

Use `Decimal` for monetary values. This is a practical schema for trading + NFTs + wallets:

```
generator client { provider = "prisma-client-js" }
datasource db { provider = "postgresql"; url = env("DATABASE_URL") }

enum Role { USER ADMIN CREATOR }
enum WalletType { NONCUSTODIAL CUSTODIAL }
enum TxStatus { PENDING CONFIRMED FAILED }

model User {
  id         String   @id @default(uuid())
  email      String   @unique
  password   String?
  firstName  String?
  lastName   String?
  role       Role     @default(USER)
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt
  wallets    Wallet[]
  kycStatus  String   @default("PENDING")
}

model Wallet {
  id        String     @id @default(cuid())
  userId    String
  chain     String
  address   String
  type      WalletType
  meta      Json?
  createdAt DateTime   @default(now())
  user      User       @relation(fields:[userId], references:[id])

  transactions Transaction[]
  nfts         NFT[]    @relation("owner")
  @@unique([chain,address])
}

model Transaction {
  id         String   @id @default(cuid())
  walletId   String
  txHash     String?  @unique
  type       String
  amount     Decimal? @db.Decimal(30, 18)
  token      String?
  chain      String
  status     TxStatus @default(PENDING)
  meta       Json?
  createdAt  DateTime @default(now())
  wallet     Wallet   @relation(fields:[walletId], references:[id])
}

model NFT {
  id            String   @id @default(cuid())
  contract      String
  tokenId       String
  chain         String
  ownerWalletId String?
  metadataUrl   String
  metadata      Json?
  price         Decimal? @db.Decimal(30, 18)
  currency      String?
  status        String
  createdAt     DateTime @default(now())
  owner         Wallet?  @relation("owner", fields:[ownerWalletId], references:[id])
}

model Order {
  id          String   @id @default(cuid())
  userId      String
  pair        String
  side        String
  type        String
  price       Decimal? @db.Decimal(30, 18)
  amount      Decimal  @db.Decimal(30, 18)
  filled      Decimal  @db.Decimal(30, 18) @default("0")
  status      String
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  user        User     @relation(fields:[userId], references:[id])
}

```

---

# 4. Core API endpoints (representative)

All under `/api/v1`

**Auth**

- POST `/auth/register` — register
- POST `/auth/login` — login (email/password)
- POST `/auth/siwe` — sign-in-with-ethereum (SIWE) for wallet users
- POST `/auth/refresh` — refresh token
- POST `/auth/logout`

**Users**

- GET `/users/me`
- PATCH `/users/me`
- POST `/users/kyc` — upload KYC docs

**Wallets**

- POST `/wallets/register` — register user wallet (non-custodial) — store address + chain
- POST `/wallets/create-custodial` — (admin) create custodial wallet via partner
- GET `/wallets/:address/balance` — aggregate balances (calls Moralis/Node)
- POST `/wallets/:chain/prepare-tx` — server builds unsigned transaction (optional)
- POST `/wallets/:chain/send` — broadcast signed tx via node provider

**Trading / Swaps**

- GET `/swap/quote` — returns quote from aggregator (0x/1inch)
- POST `/swap/execute` — server returns txPayload for client to sign (or executes if custodial)
- GET `/trade/orders/me` — user orders
- POST `/trade/order` — (if you implement internal orderbook)

**NFTs**

- GET `/nft/collections`
- POST `/nft/mint` — trigger mint workflow (upload metadata → return tx or execute custodial mint)
- POST `/nft/list` — list for sale
- POST `/nft/buy` — buy flow (returns tx or executes)

**Portfolio**

- GET `/portfolio/summary` — calls Moralis/Covalent + local holdings
- GET `/portfolio/history` — historical snapshots from `PriceSnapshot` + internal ledger

**Admin**

- GET `/admin/analytics`
- POST `/admin/collections/approve`

---

# 5. Integration details & code snippets

Below are **copy/paste-ready** Node.js/TypeScript snippets (simplified) for each of the 4 integrations.

> Note: replace process.env.* values with actual keys from provider consoles.
>

---

## 5.1 Wallet SDK integration (client + backend notes)

**Recommended approach:** Use **WalletConnect** or **Coinbase Wallet SDK** on the client to let users connect wallets and sign transactions. On backend, accept signed payloads (e.g., SIWE for login) and *never* store user private keys for non-custodial users.

**WalletConnect docs:** [https://docs.walletconnect.com/](https://docs.walletconnect.com/) [docs.walletconnect.network+1](https://docs.walletconnect.network/wallet-sdk/overview?utm_source=chatgpt.com)

**Coinbase Wallet SDK docs:** [https://www.coinbase.com/developer-platform/products/wallet-sdk](https://www.coinbase.com/developer-platform/products/wallet-sdk?utm_source=chatgpt.com) [Coinbase](https://www.coinbase.com/developer-platform/products/wallet-sdk?utm_source=chatgpt.com)

### SIWE auth (server snippet)

```tsx
// src/modules/auth/siwe.controller.ts (express)
import express from 'express';
import { verifyMessage } from 'siwe';
const router = express.Router();

router.post('/siwe', async (req, res) => {
  const { message, signature } = req.body;
  try {
    const siwe = await verifyMessage(message, signature); // use siwe lib
    // Validate nonce, chainId, domain...
    // Find or create user by address
    // issue JWT
    res.json({ accessToken, refreshToken });
  } catch (err) {
    res.status(400).json({ error: 'Invalid SIWE' });
  }
});
export default router;

```

---

## 5.2 Node provider adapter (Alchemy / Infura / QuickNode)

**Alchemy docs:** [https://docs.alchemy.com/](https://docs.alchemy.com/) [Alchemy](https://www.alchemy.com/docs?utm_source=chatgpt.com)

**Infura:** [https://infura.io/](https://infura.io/) [Infura](https://www.infura.io/?utm_source=chatgpt.com)

**QuickNode:** [https://www.quicknode.com/docs/welcome](https://www.quicknode.com/docs/welcome?utm_source=chatgpt.com). [Quicknode](https://www.quicknode.com/docs/welcome?utm_source=chatgpt.com)

### node.provider.ts (ethers wrapper)

```tsx
import { ethers } from 'ethers';

class NodeProvider {
  providers: Record<string, ethers.providers.JsonRpcProvider> = {};
  constructor() {
    this.providers['ethereum'] = new ethers.providers.JsonRpcProvider(process.env.ALCHEMY_RPC_URL);
    // add fallbacks for infura/quicknode
  }
  async broadcastTx(chain: string, signedTx: string) {
    const p = this.providers[chain];
    return p.sendTransaction(signedTx);
  }
  async getTx(txHash: string, chain = 'ethereum') {
    return this.providers[chain].getTransaction(txHash);
  }
  async getBalance(address: string, chain = 'ethereum') {
    return this.providers[chain].getBalance(address);
  }
}
export default new NodeProvider();

```

Use web socket providers for pending tx subscriptions, or Alchemy Streams/QuickNode Streams for event push. [Alchemy+1](https://www.alchemy.com/docs?utm_source=chatgpt.com)

---

## 5.3 Portfolio / Indexing integration (Moralis example)

**Moralis docs (NFT & balances):** [https://docs.moralis.com/](https://docs.moralis.com/?utm_source=chatgpt.com) and [https://moralis.com/api/nft/](https://moralis.com/api/nft/?utm_source=chatgpt.com) [docs.moralis.com+1](https://docs.moralis.com/?utm_source=chatgpt.com)

### Example: fetch token balances & NFTs

```tsx
import axios from 'axios';

const MORALIS_KEY = process.env.MORALIS_API_KEY;
async function getBalances(address: string, chain = 'eth') {
  const url = `https://deep-index.moralis.io/api/v2/${address}/balance?chain=${chain}`;
  const res = await axios.get(url, { headers: { 'X-API-Key': MORALIS_KEY }});
  return res.data;
}

async function getNFTs(address: string, chain = 'eth') {
  const url = `https://deep-index.moralis.io/api/v2/${address}/nft?chain=${chain}&format=decimal`;
  const res = await axios.get(url, { headers: { 'X-API-Key': MORALIS_KEY }});
  return res.data;
}

```

**Webhooks:** configure Moralis to POST to `/webhooks/moralis` for transfer events and update database accordingly. [docs.moralis.com](https://docs.moralis.com/?utm_source=chatgpt.com)

---

## 5.4 Trade execution (0x swap API example)

**0x docs:** [https://0x.org/docs](https://0x.org/docs) (quotes & swap endpoints)

**1inch docs:** [https://docs.1inch.io/](https://docs.1inch.io/)

(Choose one primary aggregator; 0x is a solid default.)

### Quote + tx payload flow

1. Client asks for quote: backend calls aggregator `/quote` endpoint.
2. Backend returns quote to client (price, to, data, estimatedGas).
3. Client signs the transaction (if non-custodial) and sends back signed tx → backend broadcasts via Node Provider.
4. If custodial, backend signs via custody provider and broadcasts.

```tsx
// swap.service.ts
import axios from 'axios';
const ZEROX_API = 'https://api.0x.org/swap/v1/quote';

export async function getQuote(fromToken, toToken, amount, takerAddress) {
  const q = `${ZEROX_API}?buyToken=${toToken}&sellToken=${fromToken}&sellAmount=${amount}&takerAddress=${takerAddress}`;
  const res = await axios.get(q);
  return res.data; // includes to, data, value, gas etc
}

```

> For user-signed flows: return res.data to client and instruct client to sign & send tx using Wallet SDK. For custodial flows: use custodial provider signing (Fireblocks) and broadcast using node provider. Alchemy+1
>

---

# 6. Webhooks & background jobs

**Important webhooks**

- Moralis webhook for transfers / NFT events → update DB, notify users. [docs.moralis.com](https://docs.moralis.com/?utm_source=chatgpt.com)
- On-ramp / off-ramp webhook (Transak / Moonpay) → reconcile fiat settlements.
- Node provider webhook / Alchemy webhooks (transaction confirmations / pending tx).

**Background jobs (BullMQ workers)**

- Indexer worker: poll Moralis or listen to Streams to ingest transfers & mint events into DB.
- Reconciliation worker: reconcile custodial balances + fees.
- Fee scheduler: when swap completes, compute and record 0.3% fee, route to revenue account (smart contract or on-chain settlement).
- Alerts worker: price alerts & NFT floor watchers.

---

# 7. Fee capture pattern (0.3%)

Two options:

**A. Smart-contract fee (on-chain)** — preferred for transparency:

- For swaps via DEX aggregator, route through your fee-collecting smart contract that calls aggregator, takes 0.3% and forwards the rest. Requires custom contract or router. (Complex: needs audits.)

**B. Off-chain fee accounting (simpler MVP)**:

- Execute the swap normally; after tx confirmed, compute fee = 0.3% of `amountOut` and create internal ledger entry: debit user, credit Chronos revenue account. For custodial wallets you can withdraw funds accordingly. For non-custodial, you must collect fees at time-of-trade (e.g., user prepays fee) — legal/business considerations apply.

**Recommendation:** Start with **off-chain fee accounting** for MVP (simpler), move to on-chain fee router later.

---

# 8. Security & compliance

- **No private keys on server** for non-custodial users.
- **Custodial** models must use vetted providers (Fireblocks, BitGo) and strong HSM/MPC. [Fireblocks Developer Portal](https://developers.fireblocks.com/docs/introduction?utm_source=chatgpt.com)
- **KYC/AML**: integrate Sumsub / Persona / Onfido for KYC flows.
- **Data protection**: encrypt PII in transit & at rest; use secrets manager.
- **Smart contract audits** for minting & fee router.
- **Rate-limiting** and bot mitigation for swap endpoints.
- **Logging & audit trail** for each financial action.

---

# 9. Testing plan

- Unit tests (Jest) for services.
- Integration tests: Docker Compose with Postgres, Redis — run worker jobs.
- E2E on testnets (Goerli, Mumbai): full flows: connect wallet → quote → sign → broadcast → confirm.
- Postman collection (we can generate this from endpoints above).

---

# 10. Deployment & infra (recommended)

- Containerize (Docker).
- K8s (EKS / GKE) for production; use managed Postgres (RDS / CloudSQL).
- Use Redis managed service (Elasticache).
- Alchemy / QuickNode for RPC endpoints; keep key rotation & fallbacks. [Alchemy+1](https://www.alchemy.com/docs?utm_source=chatgpt.com)
- Monitoring: Prometheus + Grafana, Sentry for errors.

---

# 11. Dev tasks / Sprint plan (MVP scope — 6 weeks)

**Week 1**

- Provision accounts (Moralis, Alchemy/Infura/QuickNode, 0x/1inch API, Wallet SDK dev keys). [docs.moralis.com+2Alchemy+2](https://docs.moralis.com/?utm_source=chatgpt.com)
- Create Prisma schema + migrations.
- Implement Auth + SIWE.

**Week 2**

- Wallet registration flows (client + SIWE) + Node provider adapter.
- Basic Moralis balance + NFT fetch endpoints.

**Week 3**

- Swap quote flow (0x) + return tx payload endpoint.
- Client sign & broadcast path (non-custodial).
- Background worker for Moralis webhooks.

**Week 4**

- NFT mint/list/buy (testnet).
- Fee accounting (0.3%) off-chain.

**Week 5**

- KYC flow integration + admin UI endpoints.
- Add monitoring + logging.

**Week 6**

- E2E test on testnet. QA. Security checklist.

---

# 12. Example environment variables (`.env.example`)

```
DATABASE_URL=postgresql://...
PORT=3000
JWT_SECRET=...
MORALIS_API_KEY=your_moralis_key
ALCHEMY_RPC_URL=https://eth-mainnet.alchemyapi.io/v2/...
INFURA_API_KEY=...
QUICKNODE_RPC=https://...
ZEROX_API=https://api.0x.org
ONEINCH_API=https://api.1inch.io/v5.0
WALLETCONNECT_PROJECT_ID=...
MAGIC_SECRET_KEY=...
FIREBLOCKS_API_KEY=...

```

---

# 13. Useful doc links (again) — quick reference

- WalletConnect: [https://docs.walletconnect.com/](https://docs.walletconnect.com/) [docs.walletconnect.network+1](https://docs.walletconnect.network/wallet-sdk/overview?utm_source=chatgpt.com)
- Coinbase Wallet SDK: [https://www.coinbase.com/developer-platform/products/wallet-sdk](https://www.coinbase.com/developer-platform/products/wallet-sdk?utm_source=chatgpt.com) (GH: [https://github.com/coinbase/coinbase-wallet-sdk](https://github.com/coinbase/coinbase-wallet-sdk?utm_source=chatgpt.com)). [Coinbase+1](https://www.coinbase.com/developer-platform/products/wallet-sdk?utm_source=chatgpt.com)
- Magic: https://docs.magic.link/overview. [docs.magic.link+1](https://docs.magic.link/embedded-wallets/sdk/overview?utm_source=chatgpt.com)
- Fireblocks (custody): https://developers.fireblocks.com/overview. [Fireblocks Developer Portal+1](https://developers.fireblocks.com/reference/api-overview?utm_source=chatgpt.com)
- Alchemy: [https://docs.alchemy.com/](https://docs.alchemy.com/) (RPC, Webhooks, Streams). [Alchemy](https://www.alchemy.com/docs?utm_source=chatgpt.com)
- Infura: [https://infura.io/](https://infura.io/) (RPC & IPFS). [Infura](https://www.infura.io/?utm_source=chatgpt.com)
- QuickNode: [https://www.quicknode.com/docs/welcome](https://www.quicknode.com/docs/welcome?utm_source=chatgpt.com). [Quicknode](https://www.quicknode.com/docs/welcome?utm_source=chatgpt.com)
- Moralis (NFT & balances): [https://docs.moralis.com/](https://docs.moralis.com/?utm_source=chatgpt.com) (NFT API). [docs.moralis.com+1](https://docs.moralis.com/?utm_source=chatgpt.com)
- 0x Swap API: [https://0x.org/docs](https://0x.org/docs) (quotes & swap endpoints).
- 1inch API: [https://docs.1inch.io/](https://docs.1inch.io/)
- ParaSwap: https://www.paraswap.io/#/developer

---
