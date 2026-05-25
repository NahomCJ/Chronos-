# Core Banking Engine

The Core Banking module is the heart of the Chronos Backend. It handles the fundamental financial operations, account management, and compliance logic.

---

## 🏛️ Module Overview

This module is built using a Controller/Service architecture integrated into the main Express application. It manages the lifecycle of bank accounts, transactions, and user identity verification.

---

## 📂 Core Components

### 1. Account Management (`/accounts`)
Handles the creation and management of user accounts.
*   **Virtual Accounts**: Mapping individual user balances to real bank rails.
*   **Balance Tracking**: Real-time ledger management via Prisma.

### 2. Transaction Engine (`/transactions`)
The ledger system that records every movement of funds.
*   **Atomic Transactions**: Ensures fund transfers are consistent (Debit/Credit logic).
*   **History**: Paginated access to historical transaction data.

### 3. Fund Transfers (`/transfer`)
Logic for moving money between internal accounts and external banks.
*   **Internal Transfers**: Instant P2P transfers within the Chronos ecosystem.
*   **External Transfers**: ACH and Wire integrations via providers like Akoya.

### 4. KYC & Compliance (`/kyc`)
Identity verification and AML (Anti-Money Laundering) checks.
*   **Verification Flows**: Managed via third-party integrations.
*   **Compliance Gates**: Blocks high-risk users from sensitive financial operations.

---

## 🔌 External Providers

The Core module relies on several integration partners:
*   **Akoya**: For bank data aggregation and open banking.
*   **Plaid**: (Optional/Legacy) For secondary verification checks.
*   **Internal Audit**: Every financial action is logged via the `AuditService`.

---

## 🛠️ Development & Testing

Core banking services are tested using unit tests that mock the database and external providers.

**Example: Run KYC Service tests**
```bash
npm test src/modules/core/kyc/kyc.service.spec.ts
```

---
*Chronos Core Banking — Integrity at Scale*
