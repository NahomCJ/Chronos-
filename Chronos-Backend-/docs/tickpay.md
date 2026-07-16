# TickPay — BNPL Module

**Path:** `src/modules/bnpl/`

TickPay is Chronos's Buy Now Pay Later product. Users apply through an onboarding flow that scores their financial profile, receive a credit limit, and can make purchases repaid in fee installments.

---

## How It Works

```
User onboarding (income, expenses, obligations)
      │
      ▼
Scoring engine → credit limit assigned
      │
      ▼
TickPay account activated
      │
      ▼
User makes purchase → TickPayTransaction created
      │
      ▼
Fee installments scheduled (TickPayFeeInstallment)
      │
      ▼
Repayments reduce outstanding balance
```

---

## Endpoints

### Onboarding

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| POST | `/tickpay/onboard` | Yes | Submit financial profile |
| GET  | `/tickpay/onboard` | Yes | Get onboarding status |

### Account

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET  | `/tickpay/account` | Yes | Get TickPay account + balance |
| GET  | `/tickpay/account/transactions` | Yes | List transactions |
| GET  | `/tickpay/account/installments` | Yes | List fee installments |

### Transactions

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| POST | `/tickpay/purchase` | Yes | Make a purchase |
| POST | `/tickpay/repay` | Yes | Make a repayment |

### Admin

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET  | `/tickpay/admin/accounts` | Admin | List all TickPay accounts |
| PATCH | `/tickpay/admin/accounts/:id/limit` | Admin | Update credit limit |
| PATCH | `/tickpay/admin/accounts/:id/suspend` | Admin | Suspend account |

---

## Onboarding Scoring

The onboarding form collects:

| Field | Description |
|-------|-------------|
| `employmentStatus` | Employed, self-employed, unemployed |
| `monthlySalary` | Gross monthly income |
| `monthlyRent` | Housing expense |
| `monthlyUtilities` | Utilities |
| `otherObligations` | Loan payments, etc. |
| `outstandingLoans` | Total outstanding debt |
| `avgMonthlySpending` | Average spend per month |
| `noRecentBankruptcy` | Boolean |

The scoring engine (`tickpay.service.ts`) produces:
- `score` — 0–100
- `recommendedLimit` — suggested credit limit in USD

---

## Credit Model

| Field | Description |
|-------|-------------|
| `creditLimit` | Maximum outstanding balance (default: $500) |
| `balance` | Current outstanding principal |
| `available` | creditLimit - balance |

---

## Fee Installment Schedule

Each purchase generates `TickPayFeeInstallment` records with scheduled `dueDate` values. A background job (`bnpl/jobs/`) marks installments as `DUE` when they come due and `MISSED` if not paid.

### Fee Statuses

```
SCHEDULED → DUE → PAID
                → MISSED
                → CANCELLED / WAIVED
```

---

## Transaction Types

| Type | Description |
|------|-------------|
| `PURCHASE` | New BNPL purchase |
| `REPAYMENT` | User repays outstanding balance |
| `REFUND` | Merchant refund |
| `FEE` | Platform fee |
| `ADJUSTMENT` | Manual correction |

---

## Key Files

| File | Purpose |
|------|---------|
| `services/tickpay.service.ts` | Core BNPL logic |
| `services/tickpay.scoring.service.ts` | Credit scoring engine |
| `controllers/tickpay.controller.ts` | User-facing routes |
| `controllers/tickpay.admin.controller.ts` | Admin routes |
| `jobs/` | Due-date enforcement cron jobs |
