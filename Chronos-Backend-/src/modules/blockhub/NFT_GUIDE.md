# BlockHub NFT Marketplace Module

A robust, compliant NFT ecosystem powered by Thirdweb and Paxos settlement.

---

## 🏗️ Architecture

The NFT sub-module handles all non-fungible token operations, from lazy-minting to secondary marketplace trading.

*   **Logic Location**: `src/modules/blockhub/src/nft/`
*   **Blockchain Provider**: Thirdweb (Polygon/Ethereum)
*   **Settlement Provider**: Paxos (USD Transfers)

---

## 📂 Sub-Modules

### 1. Marketplace (`/nft/marketplace`)
Coordinates NFT listings and purchases. Uses Paxos for secure USD payment settlement between buyer and seller.

### 2. Minting (`/nft/minting`)
Handles IPFS metadata uploads and on-chain minting operations via Thirdweb.

### 3. Royalty (`/nft/royalty`)
Automates calculations and distributions of creator royalties on secondary sales.

### 4. Websocket (`/nft/websocket`)
Broadcasts real-time blockchain events (minting complete, listing sold) to the frontend.

---

## 🛠️ Configuration
Required `.env` fields:
- `THIRDWEB_SECRET_KEY`
- `PLATFORM_MARKETPLACE_ADDRESS`
- `PAXOS_ESCROW_WALLET_ID`

---
*BlockHub NFT — Distributed Digital Ownership*
