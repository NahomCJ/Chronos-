# Core Banking Module

**Path:** `src/modules/core/`

The financial engine of Chronos. Built ledger-first — every money movement creates immutable `LedgerEntry` records before updating any balance. This ensures auditability and double-entry correctness.

---

## Sub-modules

| Sub-module | Path | Description |
|-----------|------|-------------|
| Accounts | `core/accounts/` | Bank account lifecycle |
| Wallets | `core/wallet/` | Multi-currency wallet management |
| Deposits | `core/deposit/` | ACH deposit into wallet |
| Transfers | `core/transfer/` | Wallet-to-wallet transfers |
| Cards | `core/card/` | Virtual/physical card issuance |
| FX | `core/fx/` | Foreign exchange orders |
| Currency | `core/currency/` | Exchange rate management |
| Bill Payments | `core/bill/` | Bill provider payments |
| Transactions | `core/transactions/` | Ledger queries + autonomous investor |

---

## Ledger Model

Every financial operation follows this pattern:

```
CoreTransaction (header)
    │
    ├── LedgerEntry DEBIT  (source wallet)
    └── LedgerEntry CREDIT (destination wallet)
```

- `CoreTransaction` — the "what": type, status, reference, userId
- `LedgerEntry` — the "where": walletId, direction, amount, currency
- All writes are wrapped in a Prisma `$transaction` — atomic or nothing

---

## Accounts

### Endpoints

| Method | Route | Description |
|--------|-------|-------------|
| POST | `/accounts` | Create a bank account |
| GET  | `/accounts` | List user's accounts |
| GET  | `/accounts/:id` | Get account detail |
| PATCH | `/accounts/:id` | Update account (type, tier) |
| DELETE | `/accounts/:id` | Close account |

### Account Status Flow

```
DRAFT → PENDING (KYC submitted) → APPROVED (KYC passed) → SUSPENDED / REJECTED
```

---

## Wallets

Each `Account` can have multiple `Wallet` records — one per currency/type combination.

### Wallet Types

| Type | Use |
|------|-----|
| `FIAT` | USD, EUR, etc. |
| `CRYPTO` | BTC, ETH, etc. |
| `STABLECOIN` | USDC, USDT |
| `ESCROW` | Held funds |
| `FEE_POOL` | Platform fee collection |
| `SYSTEM` | Internal system wallets |

### Endpoints

| Method | Route | Description |
|--------|-------|-------------|
| POST | `/wallets` | Create wallet for an account |
| GET  | `/wallets/:id` | Get wallet + balance |
| GET  | `/wallets/:id/ledger` | Get ledger history |

---

## Deposits

Funded deposits credit a wallet and create a corresponding `LedgerEntry`.

### Endpoints

| Method | Route | Description |
|--------|-------|-------------|
| POST | `/deposit` | Create a deposit |
| GET  | `/deposit/:id` | Get deposit by ID |
| GET  | `/deposit` | List user's deposits |

### Request Body

```json
{
  "walletId": "uuid",
  "amount": "100.00",
  "currency": "USD",
  "reference": "optional-idempotency-key",
  "source": "ACH",
  "note": "Paycheck"
}
```

- `reference` is idempotent — duplicate submissions return the existing transaction
- `amount` must be ≥ `DEPOSIT_MIN_AMOUNT` (default: $1)

---

## Transfers

Wallet-to-wallet transfers debit the source and credit the destination in the same DB transaction.

### Endpoints

| Method | Route | Description |
|--------|-------|-------------|
| POST | `/transfer` | Initiate a transfer |
| GET  | `/transfer/:id` | Get transfer status |
| GET  | `/transfer` | List user's transfers |

---

## Cards

| Method | Route | Description |
|--------|-------|-------------|
| POST | `/cards` | Issue a card (virtual/physical) |
| GET  | `/cards` | List user's cards |
| PATCH | `/cards/:id/freeze` | Freeze card |
| PATCH | `/cards/:id/unfreeze` | Unfreeze card |

---

## FX Orders

FX orders exchange one wallet currency for another via a provider rate.

### FX Order Status Flow

```
QUOTED → LOCKED → EXECUTED
                → FAILED / EXPIRED / CANCELLED
```

---

## Key Files

| File | Purpose |
|------|---------|
| `deposit/deposit.service.ts` | Deposit + ledger write logic |
| `transfer/services/transfer.service.ts` | Transfer + double-entry logic |
| `accounts/accounts.service.ts` | Account CRUD |
| `wallet/wallet.service.ts` | Wallet balance + ledger queries |
| `card/cards.service.ts` | Card issuance |
| `fx/fx.service.ts` | FX order management |
