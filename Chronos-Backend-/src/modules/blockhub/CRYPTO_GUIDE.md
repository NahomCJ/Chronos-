# BlockHub Crypto Module

institutional-grade infrastructure for high-performance crypto trading, powered by Paxos.

---

## 🏗️ Architecture

Separated within the BlockHub module, the Crypto sub-module focuses exclusively on digital asset trading and institutional wallet management.

*   **Logic Location**: `src/modules/blockhub/src/crypto/`
*   **Provider**: Paxos (Sandbox/Production)
*   **Database**: Shared PostgreSQL (via Prisma)

---

## 📂 Sub-Modules

### 1. Trading (`/crypto/trading`)
Handles the lifecycle of market orders:
- Compliance checks (KYC/AML)
- Paxos order execution
- Portfolio/Revenue record updates

### 2. Wallet (`/crypto/wallet`)
Manages automated provisioning of Paxos Identity and Profiles when a user passes KYC.

### 3. Compliance (`/crypto/compliance`)
Pre-trade gatekeeping that enforces KYC status and trading limits.

### 4. Revenue & Portfolio
Calculates trading fees/spreads and maintains real-time user holdings.

---

## 🛠️ Configuration
Required `.env` fields:
- `PAXOS_CLIENT_ID`
- `PAXOS_CLIENT_SECRET`

---
*BlockHub Crypto — Professional Trading Infrastructure*
