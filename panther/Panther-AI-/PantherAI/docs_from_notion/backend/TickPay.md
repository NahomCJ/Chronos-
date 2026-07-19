# TickPay

**Purpose:** TickPay is Chronos’ *merchantless BNPL (Buy Now Pay Later)* system.

Key characteristics:

- Merchantless: users can use TickPay anywhere (no merchant integration required).
- Fee: 0.5% of purchase amount, collected in 3 installments (monthly by default).
- Credit decision: AI + scoring service (behavioral credit model, 3rd-party credit checks optional).
- Tied to Chronos cards (TickPay card) and Chronos accounts.
- Repayments pay fees (due installments) first, then principal.
- Supports purchase, refund, repayment, account suspend/resume, and scheduled fee management.

---

## 1) Architecture overview

```
[Chronos API Gateway]
        ├── /api/v1/tickpay  (TickPay Service)
        │       ├─ controllers (HTTP)
        │       ├─ services (business logic)
        │       ├─ models (Prisma)
        │       ├─ schedulers/jobs (daily job)
        │       └─ validators/middlewares
        ├── /api/v1/accounts  (Core banking)
        ├── /api/v1/cards
        └── integrations
                ├─ credit bureaus (Experian/Equifax optional)
                ├─ payment processors (Stripe)
                ├─ notifications (Twilio, SendGrid)
                ├─ Akoya (data/connect) — optional
                └─ Moralis (if crypto payments used)

```

- Language: **TypeScript / Node.js** (same style as Chronos backend)
- ORM: **Prisma** + PostgreSQL
- Queue/scheduler: **node-cron** for daily jobs; optionally **BullMQ** with Redis for heavy work
- Caching/locks: **Redis**
- Logging: **Winston** or existing `logger.ts`
- Tests: **Jest + Supertest**

---

## 2) Business rules (concise)

- **Credit decision**: `scoring.approvePurchase(userId, amount)` returns `{approved: boolean, reason?: string}`. Combine internal heuristics + optional credit bureau.
- **Credit limit**: each TickPay account has `creditLimit`. Purchase cannot exceed `creditLimit - balance`.
- **Fee**: `FEE_RATE = 0.005` (0.5% of purchase). Fee split into `FEE_INSTALLMENTS = 3` equal installments (rounded to cents). Installments due monthly by default (configurable).
- **Fee payment priority**: On repayment, TickPay pays due fee installments (past-due or due today) first. Only after fees are satisfied remaining amount reduces principal.
- **Partial fee payments**: For v1, require full installment payment. (Optionally implement partial with tracking.)
- **Repayments**: Source can be card, wallet balance, bank transfer, TickPay card, or external (meta).
- **Refunds**: Reduce outstanding principal; fee installments remain (unless business rules specify adjusting them).
- **Suspension**: Account can be `ACTIVE` or `SUSPENDED` — decline purchases when suspended.
- **Chargeback/Dispute**: Refund flow to be implemented; hold funds & update principal.
- **Notifications**: Notify user at purchase, installment scheduled, installment due, installment paid, low credit, suspension.
- **Audits**: Every state change must create an audit record.

---

## 3) Prisma schema (TickPay portion) — ready snippet

Add or replace into `prisma/schema.prisma` (ensure types/enums exist elsewhere):

```
enum TickPayAccountStatus {
  ACTIVE
  SUSPENDED
  CLOSED
}

enum TickPayTransactionType {
  PURCHASE
  REPAYMENT
  REFUND
  ADJUSTMENT
}

enum TickPayTransactionStatus {
  PENDING
  COMPLETED
  FAILED
}

enum TickPayFeeStatus {
  SCHEDULED
  DUE
  PAID
  CANCELED
}

model TickPayAccount {
  id            String                 @id @default(cuid())
  userId        String                 @unique
  user          User                   @relation(fields: [userId], references: [id])
  creditLimit   Decimal                @db.Decimal(30, 8) @default("500")
  balance       Decimal                @db.Decimal(30, 8) @default("0") // outstanding principal
  status        TickPayAccountStatus   @default(ACTIVE)
  createdAt     DateTime               @default(now())
  updatedAt     DateTime               @updatedAt

  transactions  TickPayTransaction[]
  feeSchedules  TickPayFeeInstallment[]
  card          TickPayCard?
}

model TickPayTransaction {
  id               String                     @id @default(cuid())
  tickPayAccountId String
  tickPayAccount   TickPayAccount             @relation(fields: [tickPayAccountId], references: [id])
  type             TickPayTransactionType
  status           TickPayTransactionStatus   @default(PENDING)
  amount           Decimal                    @db.Decimal(30, 8)
  currency         String                     @default("USD")
  merchant         String?
  meta             Json?
  createdAt        DateTime                   @default(now())
}

model TickPayFeeInstallment {
  id               String              @id @default(cuid())
  tickPayAccountId String
  tickPayAccount   TickPayAccount      @relation(fields: [tickPayAccountId], references: [id])
  purchaseTxId     String?
  purchaseTx       TickPayTransaction? @relation("PurchaseFee", fields: [purchaseTxId], references: [id])
  amount           Decimal             @db.Decimal(30, 8)
  status           TickPayFeeStatus    @default(SCHEDULED)
  dueDate          DateTime
  paidAt           DateTime?
  createdAt        DateTime            @default(now())
}

model TickPayCard {
  id               String         @id @default(cuid())
  cardId           String         @unique
  tickPayAccountId String         @unique
  tickPayAccount   TickPayAccount @relation(fields: [tickPayAccountId], references: [id])
  createdAt        DateTime       @default(now())
}

```

> Note: Use Decimal for money; Prisma Decimal requires @db.Decimal(30,8) and handling via Decimal.js or numeric strings.
>

---

## 4) API endpoints (REST) — `/api/v1/tickpay`

Base path: `/api/v1/tickpay`

### Public / User endpoints

1. `POST /account` — create or upsert TickPay account

    **Body:** `{ userId: string, creditLimit?: number }`

    **Response:** `200 { account }`

2. `GET /account` — get TickPay account for current user

    **Response:** `200 { account, transactions[], feeSchedules[], card? }`

3. `POST /card/issue` — issue TickPay card (virtual)

    **Body:** none (user authenticated)

    **Response:** `201 { card }`

4. `POST /purchase` — create purchase using TickPay

    **Body:** `{ amount: number, currency?: string, merchant?: string, meta?: any }`

    **Flow:** credit decision → create TickPayTransaction (PURCHASE) → schedule fee installments → increase account.balance

    **Response:** `201 { purchaseTx, totalFee, perInstallment, installments }`

5. `POST /repayment` — create repayment

    **Body:** `{ amount: number, currency?: string, source?: "CARD" | "WALLET" | "BANK" | "EXTERNAL", meta?: any }`

    **Flow:** pay due fee installments (oldest first) → apply remainder to principal → create REPAYMENT Tx

    **Response:** `200 { repaymentTx, appliedAmount, leftover }`

6. `POST /refund` — refund a purchase

    **Body:** `{ purchaseTxId: string, amount: number }`

    **Flow:** validate purchase → create REFUND tx → reduce principal → keep fees scheduled (policy)

    **Response:** `200 { refundTx }`

7. `GET /transactions` — list transactions (with paging)

    **Query:** `?type=PURCHASE|REPAYMENT&limit=20&cursor=`

    **Response:** `200 { transactions[] }`

8. `GET /fees` — list fee installments for user

    **Response:** `200 { feeInstallments[] }`

9. `POST /account/suspend` — suspend account (admin or system)

    **Body:** `{ userId?: string }`

    **Response:** `200 { account }`

10. `POST /account/resume` — resume account

    **Response:** `200 { account }`


### Admin endpoints (secure RBAC)

- `GET /admin/accounts` — list all TickPay accounts (filterable)
- `POST /admin/fee/run-due` — force transition of scheduled → due (for manual admin job)
- `POST /admin/adjust` — apply manual adjustments to account or fees
- `GET /admin/reports` — generate delinquency and usage reports

---

## 5) Controller → Service mapping (file layout suggestions)

```
src/modules/tickpay/
  controllers/
    tickpay.controller.ts      // routes above
    admin.tickpay.controller.ts
  services/
    tickpay.service.ts         // core flows (createPurchase, createRepayment)
    scoring.service.ts         // credit decision wrapper (local + external)
    card.service.ts            // issue card (calls card module or create Card + TickPayCard)
    scheduler.service.ts       // daily jobs (runTickPayDailyJob)
  models/
    prisma.ts (shared)
  jobs/
    tickpay.scheduler.ts
  validators/
    tickpay.validate.ts
  types/
    tickpay.types.ts

```

---

## 6) Business logic details — flows

### A. `createPurchase(userId, amount, currency, merchant, meta)`

- Validate user and TickPay account:
    - Account must exist and `status == ACTIVE`
    - Amount > 0
    - `available = creditLimit - balance` → require `amount <= available`
- Credit decision:
    - `decision = scoring.approvePurchase(userId, amount)`
    - If `!decision.approved` → reject with reason
- Create `TickPayTransaction` (PURCHASE, status COMPLETED or PENDING if waiting)
- Update `TickPayAccount.balance += amount`
- Schedule fee installments:
    - `totalFee = round(amount * FEE_RATE, 2)`
    - `perInstallment = round(totalFee / FEE_INSTALLMENTS, 2)`
    - For i in [1..FEE_INSTALLMENTS]: create `TickPayFeeInstallment` with dueDate = now + i * billingInterval
    - (If rounding leftover, apply to final installment)
- Notify user (email/push) with purchase details and fee schedule.

Edge cases:

- Floating rounding: ensure sum of installments equals totalFee (adjust last installment).
- Re-entrancy: use DB transaction and row-level locks.

### B. `createRepayment(userId, amount, source, meta)`

- Validate account and amount
- Load `feeInstallments` ordered by dueDate where status in [SCHEDULED, DUE] and dueDate <= now (or include DUE regardless dueDate)
- Loop through dueFees:
    - If `remaining >= fee.amount`: mark fee PAID, set `paidAt`
    - If `remaining < fee.amount`: do not partially pay (v1) — stop and return leftover
- If remaining > 0: reduce `TickPayAccount.balance = max(balance - remaining, 0)`
- Create REPAYMENT transaction record
- Notify user
- Return applied amount + leftover

Edge:

- Partial payments policy may be extended to allow partial fee payments and keep state of partialPaid amount (requires field on installment).

### C. `refundPurchase(userId, purchaseTxId, amount)`

- Validate: purchaseTx exists and belongs to user; is type PURCHASE
- Create REFUND transaction
- Decrease account.balance by `min(amount, balance)` — principal reduced
- Do not auto-adjust fee installments in v1 (business decision)
- Log audit

### D. `fee scheduler job` (daily)

- Run daily (configurable cron) — tasks:
    1. Find fee installments where `status = SCHEDULED` and `dueDate <= now` → mark `status = DUE` (notify user: fee due).
    2. Optionally, for DUE with overdue threshold > N days → mark account `SUSPENDED` or escalate (send collection emails).
    3. Generate monthly statements or emails.
    4. Produce delinquency metrics for admin dashboard.

Scheduler implementation:

- Put `runTickPayDailyJob()` in `src/jobs/tickpay.scheduler.ts`
- Use `prisma.$transaction` for batch updates
- Ensure idempotency (job may run twice); only update records in known previous states.

---

## 7) Scoring service / credit decision

`scoring.service.ts` responsibilities:

- Basic heuristic scoring (internal): usage history, repayment timeliness, account balance history, net income (if available), frequency of late payments.
- External credit check (optional): call Experian/Equifax/NovaCredit for users who opt-in — use this to boost/deny decisions.
- AI scoring (future): ingest features (transactions, LifeX signals) and call FinGPT/FinRobot ensemble for more nuanced risk decisions.

Return type:

```tsx
type ScoringDecision = {
  approved: boolean;
  reason?: string;
  score?: number; // 0-100
  recommendedLimit?: number;
}

```

Business rule:

- If external credit says “decline” then decline. Otherwise combine features to compute score and threshold.

---

## 8) Integrations & dependencies

- **Card issuing:** Use Chronos `Card` module / Stripe Issuing / Marqeta sandbox to create a card object and link via `TickPayCard`.
- **Notifications:** SendGrid / Twilio / Push system — notify schedule and due events.
- **Credit bureau (optional):** Experian/Equifax/NovaCredit — requires consent and PII compliance.
- **Accounting / Core banking:** When purchase happens, create internal ledger entries (debit user account? If using external wallet, create ledger references).
- **Akoya:** optional for data sharing/aggregation (if partnering to get bank account data for affordability).
- **Redis:** for locking and OTP caching if repayment confirmation needs OTP.

---

## 9) Validations & constraints

- **Amount validation:** positive number, not exceeding two decimals.
- **Currency validation:** support ISO codes; convert using FX module when necessary.
- **Idempotency:** For purchase and repay endpoints accept `idempotency_key` header to avoid double charges.
- **Concurrency:** use DB transactions and `SELECT FOR UPDATE` patterns or Prisma transaction locks to prevent race conditions on `TickPayAccount.balance`.
- **Limits & thresholds:** Daily transaction volume caps; automatic suspend for delinquent accounts after `X` days of missed fees.

---

## 10) Notifications & UX messages

Events that trigger notifications:

- Account created
- Card issued
- Purchase complete (with fee schedule)
- Fee installment scheduled
- Fee installment due (DUE)
- Fee installment paid
- Repayment processed
- Account suspended/resumed
- Refund processed

Notification channels:

- Push (mobile)
- Email
- SMS (critical events only)

Templates: keep sample templates stored in `src/templates/notifications/tickpay/*.hbs` or plain text.

---

## 11) Scheduler implementation (simplified)

`src/jobs/tickpay.scheduler.ts`

- Exposes `export async function runTickPayDailyJob(): Promise<void>`
- Steps:
    1. Transition `SCHEDULED` installments to `DUE` where `dueDate <= now`.
    2. For `DUE` installments older than `overdueThresholdDays` (configurable), flag account delinquent and optionally suspend.
    3. Send summary notifications.
    4. Generate daily admin report (counts: new dues, delinquents).

Cron example (server.ts):

```tsx
import cron from "node-cron";
cron.schedule("0 8 * * *", async () => {
  try {
    await runTickPayDailyJob();
  } catch (err) {
    logger.error("TickPay daily job failed", err);
  }
});

```

---

## 12) Tests to implement

- Unit:
    - `createPurchase` happy path
    - `createPurchase` credit decision decline
    - `createRepayment` paying fees then principal
    - `refundPurchase` adjust principal
    - rounding logic for fee installments
    - idempotency behavior
- Integration:
    - Purchase → FeeInstallments created
    - Repayment → fees marked PAID
    - Scheduler job transitions `SCHEDULED` → `DUE`
- End-to-end:
    - Full flow with mock external integrations (mock scoring, mock card issuance)

Use `jest` + `supertest` and a test DB (or Prisma sqlite) with migrations.

---

## 13) Env vars (example)

Add to `.env`:

```
TICKPAY_FEE_RATE=0.005
TICKPAY_FEE_INSTALLMENTS=3
TICKPAY_BILL_CYCLE_MONTHS=1
DATABASE_URL=postgresql://...
JWT_SECRET=...
REDIS_URL=redis://...
CREDIT_API_KEY=...
NOTIFY_SENDGRID_API_KEY=...
STRIPE_API_KEY=...
AKOYA_API_KEY=...

```

---

## 14) Admin & Monitoring

- Admin dashboard features:
    - View TickPay accounts + credit utilization
    - List delinquent accounts
    - Force-run scheduler actions
    - Adjust account limits
    - Manual mark fee PAID/CANCEL
- Metrics to export: new purchases/day, total outstanding principal, delinquency rate, avg fee per purchase, repayment rate.

---

## 15) Security & compliance

- PII must be encrypted at rest (DB) and in transit (TLS).
- GDPR: provide opt-in/opt-out for credit checks.
- Access control: admin endpoints RBAC-only.
- Logging: do NOT log sensitive PAN/full card numbers; store tokens or masked last4.
- PCI: If you process card data, use Stripe/Marqeta to avoid direct PCI scope.

---

## 16) Migration & deployment checklist

1. Add Prisma models and create migration `npx prisma migrate dev --name tickpay_init`.
2. Seed sample TickPay accounts for dev.
3. Run unit tests and integration tests.
4. Deploy on staging with env vars.
5. Add cron job on staging to run scheduler.
6. Manual E2E test: create purchase, check fee schedules, create repayment.
7. Observe logs and metrics.

---

## 17) Edge cases & decisions to confirm

- Partial fee payments vs require whole installment (we recommended require whole installment v1).
- When refund occurs, do we reduce future fee installments? (We chose to keep them in v1; adjust later.)
- How to handle currency conversions when purchase currency != account currency? (Use FX module to normalize).
- Delinquency policy & collections: what action after N missed installments? (suspension, collection agency, legal)
- Grace periods for small payments.

---

## 18) Example payloads

**Purchase request**

`POST /api/v1/tickpay/purchase`

```json
{
  "amount": 120.00,
  "currency": "USD",
  "merchant": "Shoes Online",
  "meta": { "cartId": "abc123" }
}

```

**Purchase response**

```json
{
  "purchaseTx": {
    "id": "cuid_xxx",
    "type": "PURCHASE",
    "status": "COMPLETED",
    "amount": "120.00",
    "currency": "USD",
    "createdAt": "2025-11-02T12:00:00Z"
  },
  "totalFee": "0.60",
  "perInstallment": "0.20",
  "installments": 3
}

```

**Repayment request**

`POST /api/v1/tickpay/repayment`

```json
{
  "amount": 150.00,
  "currency": "USD",
  "source": "WALLET"
}

```

**Repayment response**

```json
{
  "repaymentTx": { "id": "cuid_yyy", "amount": "150.00", "status": "COMPLETED" },
  "appliedAmount": "150.00",
  "leftover": 0
}

```

---

## 19) Prioritized TODOs for the backend engineer

**Phase 1 (MVP)** — complete in order:

1. Add Prisma TickPay models + run migrations.
2. Implement `tickpay.service.ts` with `createAccount`, `getAccount`, `createPurchase`, `createRepayment`, `refundPurchase`, `listTransactions`, `listFees`, `issueTickPayCard`.
3. Implement `tickpay.controller.ts` endpoints with validation and RBAC where needed.
4. Implement `scoring.service.ts` (simple rule-based) and mock external scoring adapter.
5. Implement scheduler `runTickPayDailyJob()` and wire cron in `server.ts`.
6. Integrate notifications (email/push) on key events.
7. Add unit & integration tests for main flows.
8. Add admin endpoints and basic admin UI or API for reports.
9. Load testing for concurrency (simulate many purchases/repayments).
10. Document API (OpenAPI/Swagger).

**Phase 2 (enhancements):**

- Partial installment support
- Integration with Experian/NovaCredit
- Auto-collection & delinquency escalations
- Card physical issuance via card provider
- Reconciliation jobs with core banking ledger

---

## 20) Contacts / references for implementer

- **Lead architect / product owner:** (put your contact)
- **DevOps:** (put contact)
- **QA:** (put contact)
- **Example PRs / style guide**: follow existing Chronos repo patterns (controllers → services → models)

[ReadMe File ](TickPay/ReadMe%20File%2029eed62a3eb480a8a62dd6d318b2e794.md)

[TickPay — Full Backend Spec](TickPay/TickPay%20%E2%80%94%20Full%20Backend%20Spec%202a7ed62a3eb480cead12ebcaf1eae34b.md)

[**TickPay AI Marketplace Search Engine**](TickPay/TickPay%20AI%20Marketplace%20Search%20Engine%202bded62a3eb480c1bffdcdcdf096dce5.md)
