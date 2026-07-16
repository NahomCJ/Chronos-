# TickPay — Full Backend Spec

TickPay is a **merchantless BNPL** (Buy-Now-Pay-Later) product inside Chronos.

Key characteristics:

- Merchantless: user can use TickPay anywhere (not limited to participating merchants).
- Credit decision uses an AI scoring service (`tickpay.scoring.service`) that uses behavior & financial telemetry, not classical credit bureau (but must optionally check credit histories).
- Fee = **0.5% upfront** on purchases (configurable), charged across **3 scheduled installments** (monthly by default).
- Users may also use a TickPay card (virtual / physical) for purchases.
- Integrates with core banking accounts (to capture repayments), notification system, audit logs, and accounting.
- Must be robust, auditable, and compliant-ready (KYC/AML hooks).

---

## Table of contents

1. High-level architecture
2. Business logic / flows
3. Data model (Prisma schema) — full TickPay section
4. API design (routes, controllers, request/response examples)
5. Services & internal modules (scoring, billing, accounting, notifications)
6. Scheduler / Cron jobs (tickpay.scheduler)
7. Integrations (Akoya, Moralis optional, FinGPT for scoring insights)
8. Security, compliance, and audit requirements
9. Testing & QA plan (unit/integration/e2e + Postman collection)
10. Deployment & infra recommendations
11. Observability & monitoring
12. Operational playbook (runbook, failure handling)
13. Roadmap & extension points (AI autopay, chargebacks, card issuing)
14. Example .env and README starter
15. Folder structure and where to put validations

---

## 1 — High-level architecture

```
Mobile / Web UI
    ↕
Chronos API Gateway (auth, rate-limit)
    ↕
TickPay API (express/fastify)  [controllers -> services -> models/prisma]
    ↕
Postgres (Prisma)
Redis (locks, rate-limiting, queues)
Message Queue (SQS / RabbitMQ) for async jobs
Background workers (cron / node-cron or BullMQ)
Notification Service (email / push / sms)
Accounting / Core Banking (external BAAS provider or internal core API)
AI Scoring Service (local microservice or external FinGPT-backed)
3rd-party integrations: Akoya (data), payment processors, card issuing provider

```

Key components:

- **API Layer** — controllers + route validation.
- **Service Layer** — business logic (TickPayService).
- **Persistence** — Prisma models in PostgreSQL.
- **Background workers** — schedule installments, send reminders, perform delinquency checks, reconciliation.
- **Message queue** for heavy async tasks (notify, reconcile, call external provider).
- **AI Scoring** — separate microservice or local service for credit decisioning.
- **Audit / Logs** — append-only audit log table for all actions.

---

## 2 — Business logic & flows (concise)

### A. Create TickPay account

- When a user enables TickPay, create `TickPayAccount` with default credit limit (e.g., $500).
- Optionally run KYC / identity checks first.

### B. Issue TickPay Card

- Create a Card record (type TICKPAY).
- If using card issuer: call card provider API to issue virtual card.
- Associate card to TickPayAccount via `TickPayCard`.

### C. Purchase flow (card or manual)

1. User attempts purchase of amount A. (merchant param optional)
2. Service checks TickPayAccount status (ACTIVE).
3. Score via `tickpay.scoring.service.approvePurchase(userId, amount)`:
    - returns `{ approved: bool, reason?: string, limit?: number }`
4. If approved and within available credit, create `TickPayTransaction` type PURCHASE (status COMPLETED/PENDING depending on flow).
5. Increase account `balance` by `amount` (principal outstanding).
6. Schedule fee installments: totalFee = amount * FEE_RATE (0.5%). Split into N installments (default 3), each scheduled one billing cycle apart — insert into `TickPayFeeInstallment`.
7. Return purchase confirmation and fee schedule.

### D. Repayment flow

- User repays amount X:
    1. Apply to DUE or SCHEDULED fee installments first (dueDate <= now), mark as PAID when full installment matched.
    2. Remaining amount applies to principal balance.
    3. Create TickPayTransaction type REPAYMENT (status COMPLETED).
    4. Emit notification and accounting entries.
- Partial fee payments: prefer full installment; system can be extended to accept partial amounts but current business rule: only fully pay scheduled fees; remainder goes to principal if fee installments are fully satisfied.

### E. Refunds

- On refunds, decrease outstanding principal accordingly; do not automatically modify fee schedule (service fee policy). Create refund transaction.

### F. Delinquency & Collections

- Daily job checks overdue installments > grace period => mark as DUE.
- After X days, mark as LATE and escalate: suspend account, reduce credit limit, notify user, optionally escalate to collections via third party.

### G. Reconciliation

- Daily job reconciles with payment provider and core bank ledger; any mismatch raises alerts.

### H. Account lifecycle

- SUSPENDED / ACTIVE / CLOSED statuses. Suspend on high risk or regulatory requirement.

---

## 3 — Data model (Prisma) — TickPay focused schema

Add these models to your `schema.prisma` (refined and consistent types). I’ll include the main TickPay models plus necessary relations.

```
// prisma/schema.prisma (append or new file)
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum TickPayAccountStatus {
  ACTIVE
  SUSPENDED
  CLOSED
}

enum TickPayTransactionType {
  PURCHASE
  REPAYMENT
  REFUND
  FEE
  ADJUSTMENT
}

enum TickPayTransactionStatus {
  PENDING
  COMPLETED
  FAILED
  CANCELLED
}

enum TickPayFeeStatus {
  SCHEDULED
  DUE
  PAID
  MISSED
  CANCELLED
}

model User {
  id        String   @id @default(uuid())
  email     String   @unique
  createdAt DateTime @default(now())
  // ... other fields
  tickPayAccount TickPayAccount?
}

model TickPayAccount {
  id            String                 @id @default(cuid())
  userId        String                 @unique
  user          User                   @relation(fields: [userId], references: [id])
  creditLimit   Decimal                @db.Decimal(30, 8) @default("500")
  balance       Decimal                @db.Decimal(30, 8) @default("0") // outstanding principal
  available     Decimal?               @db.Decimal(30, 8)
  status        TickPayAccountStatus   @default(ACTIVE)
  createdAt     DateTime               @default(now())
  updatedAt     DateTime               @updatedAt

  transactions  TickPayTransaction[]
  feeInstallments TickPayFeeInstallment[]
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
  reference        String?                    // external provider reference
  createdAt        DateTime                   @default(now())
  updatedAt        DateTime                   @updatedAt

  @@index([tickPayAccountId])
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
  updatedAt        DateTime            @updatedAt

  @@index([tickPayAccountId, dueDate])
}

model TickPayCard {
  id               String         @id @default(cuid())
  cardId           String         @unique   // FK to Card.id if shared model
  tickPayAccountId String         @unique
  tickPayAccount   TickPayAccount @relation(fields: [tickPayAccountId], references: [id])

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model TickPayAudit {
  id         String   @id @default(cuid())
  accountId  String
  actorId    String?
  action     String
  payload    Json?
  createdAt  DateTime @default(now())
}

```

> Notes:
>
> - Use `Decimal` types for money (Prisma Decimal).
> - `available` can be computed, but storing a cached value with proper locks prevents race conditions. Recompute on transactions as needed or use DB constraints & transactional updates.
> - Keep an audit table `TickPayAudit` to store all actions for compliance.

---

## 4 — API design (routes + controller contract)

I'll provide endpoint list + examples (JSON).

### Base path

`/api/tickpay`

### Routes

### Account management

- `POST /api/tickpay/accounts`

    Description: create/enroll TickPay account (idempotent).

    Request:

    ```json
    { "userId": "uuid", "initialCreditLimit": 1000 }

    ```

    Response:

    ```json
    { "id": "cuid", "userId": "...", "creditLimit": "1000.00", "balance": "0.00", "status":"ACTIVE" }

    ```

- `GET /api/tickpay/accounts/:userId`

    Get account details including transactions and fee schedule.

    Response: full account object.


### Card & Issuance

- `POST /api/tickpay/accounts/:userId/issue-card`

    Issue TickPay card. Creates a `Card` if not present and associates `TickPayCard`.

    Response: card object (masked number, last4, expiry).


### Purchase

- `POST /api/tickpay/purchases`

    Create a purchase via TickPay.

    Request:

    ```json
    {
      "userId": "uuid",
      "amount": 120.5,
      "currency": "USD",
      "merchant": "Amazon",
      "meta": { "cart": [...] }
    }

    ```

    Response:

    ```json
    {
      "purchaseTx": { "id": "...", "amount": "120.5", ... },
      "totalFee": "0.6025",
      "perInstallment": "0.20",
      "installments": 3
    }

    ```

- `POST /api/tickpay/purchases/card`

    For card based webhook or 3rd-party call (accept merchant, card id and route).


### Repayment

- `POST /api/tickpay/repayments`

    Create repayment (user pays X amount). Business logic: pay fees due first then principal.

    Request:

    ```json
    { "userId":"uuid", "amount": 130, "currency":"USD", "source":"bank_account_123" }

    ```

    Response:

    ```json
    { "repaymentTx": {...}, "appliedAmount": "130", "leftover": "0.00" }

    ```


### List & queries

- `GET /api/tickpay/accounts/:userId/transactions`
- `GET /api/tickpay/accounts/:userId/fees`

### Admin

- `POST /api/tickpay/admin/adjust` — adjust credit limits, balances (RBAC protected).
- `GET /api/tickpay/admin/audits` — audit listing.

### Webhooks

- `POST /api/tickpay/webhooks/card-provider` — handle card events (issued, frozen, chargeback).
- `POST /api/tickpay/webhooks/payment-provider` — external settlement confirmations.

---

## 5 — Services & internal modules

Suggested service modules:

- `tickpay.service.ts` — main business logic (createPurchase, createRepayment, issueCard, suspend/resume).
- `tickpay.scoring.service.ts` — credit decision logic (calls AI engine / FinGPT or rules).
- `tickpay.billing.service.ts` — fee schedule creation and management.
- `tickpay.scheduler.ts` / `tickpay.dailyJob.ts` — scheduled tasks (run installments, mark DUE).
- `tickpay.accounting.service.ts` — record accounting entries, generate ledger items for reconciliation.
- `tickpay.notification.service.ts` — send email/push/SMS.
- `tickpay.audit.service.ts` — write audit entries.

Key function signatures (TypeScript-like):

```tsx
class TickPayService {
  async createAccount(userId: string, creditLimit?: number): Promise<TickPayAccount> { ... }
  async issueTickPayCard(userId: string): Promise<Card> { ... }
  async createPurchase(userId: string, opts: { amount: number, currency?: string, merchant?: string, meta?: any }): Promise<PurchaseResult> { ... }
  async createRepayment(userId: string, amount: number, source?: string): Promise<RepaymentResult> { ... }
  async listTransactions(userId: string): Promise<TickPayTransaction[]> { ... }
  async listFees(userId: string): Promise<TickPayFeeInstallment[]> { ... }
  async suspendAccount(userId: string): Promise<void> { ... }
}

```

### Scoring service

- Must be asynchronous & fast (small latency).
- Should return `approved: boolean`, `reason`, `score`, `recommendedLimit`.
- Use ensemble approach: rules + ML model + bureau check (if available via Akoya or 3rd party).
- Ensure scoring decisions are logged for audit.

---

## 6 — Scheduler / CRON jobs

Use `node-cron` or better, a worker queue (BullMQ + Redis) for reliability.

### Daily jobs (run at 08:00 server)

- `runTickPayDailyJob`:
    1. Mark fee installments with dueDate <= now as `DUE`.
    2. For DUE installments past grace period → mark MISSED and flag account LATE.
    3. Create billing report for the day (for accounting).
    4. Notify users with upcoming due installments (D-1, D-7).
    5. Run auto-collections for ACH/auto-debit agreements (if user authorized). This should be a queued job per user.
    6. Reconciliation with bank settlement (pull transactions, match).
    7. Produce alerts for anomalies (e.g., failed repayments, double charges).

### Hourly / Real-time jobs

- Listen to card provider webhooks for purchase events if card integration occurs.
- Process failed webhooks retries.

### Retry / Backoff

- For external calls (bank, card provider), implement exponential backoff & dead-letter queue for failures.

---

## 7  Integrations

### Akoya

- Akoya can provide bank-permissioned account data (balances/transactions). Use to:
    - Validate on-file bank account during repayment setup.
    - Perform affordability checks during scoring.
- Implement connectors in `src/config/akoya.config.ts` and services to call Akoya endpoints.

### Card Issuer

- If the TickPay card is issued by 3rd party (e.g., Marqeta or a BIN sponsor), connect to their API to create virtual cards & manage lifecycle.

### Payment processors

- For fiat on/off ramps, integrate with providers (Stripe, Plaid, Circle, Transak, MoonPay) based on region.

### Moralis / BlockHub

- Not directly required by TickPay unless allowing crypto repayments or converting crypto to fiat to repays.
- If you support crypto repayments: integrate Moralis or a custodial provider to accept tokens, convert to fiat (on-ramp), and then credit TickPay account.

### AI Scoring (FinGPT/Custom)

- Scoring microservice:
    - Inference model for credit / risk scoring.
    - Use features: income inflows, spending patterns, TickPay history, LifeX signals (e.g., employment), external credit bureau if available.
    - Ensure decisions are explainable & logged.

---

## 8 — Security & Compliance

### Authentication & RBAC

- All endpoints must be protected behind `auth.middleware` (JWT / session).
- Admin endpoints require RBAC (roles: ADMIN, SUPPORT, AUDITOR).
- Rate-limits on sensitive endpoints.

### Data protection

- PCI compliance: if storing card PANs — you must not store PAN unencrypted (use tokenization through card provider). Prefer using a card token and store only last4 and token id.
- PII storage: encrypt sensitive fields at rest (e.g., KYC docs links).
- Secrets: store in environment manager (AWS Secrets Manager).
- Use HTTPS only for all endpoints.

### Audit & logging

- Every state change must produce an audit row (TickPayAudit) with actor, action, payload.
- Keep immutable logs for 7+ years depending on jurisdiction.

### Fraud & AML

- Integrate with standard AML providers or implement basic heuristics:
    - Velocity checks (too many purchases in short time).
    - Suspicious merchant patterns.
    - Geo mismatch (card used in country different from billing without travel flags).
- Expose manual freeze/suspend actions for Support.

---

## 9 — Testing & QA

### Unit tests

- For each service (createPurchase, repay, refund, fee scheduling).
- Mock Prisma, scoring service, message queue.

### Integration tests

- Spin a test DB (Postgres) via Docker, run end-to-end routes:
    - Create account -> Make purchase -> Verify fees scheduled -> Repayment flows.

### End-to-end (Postman / Newman)

- Provide Postman collection with:
    - Create test user (seed).
    - Enroll TickPay account.
    - Issue card.
    - Make purchase (simulate success & failure).
    - Make repayment.
    - Simulate due installments (fast-forward DB or run scheduler with custom dates).
- Use `newman` to run collection in CI.

### Test cases (examples)

- Purchase > credit limit -> rejected.
- Purchase -> schedules 3 installments -> verify dates.
- Repayment less than one fee -> expected: do not mark fee paid (or follow chosen partial logic).
- Partial payment equal to fee -> mark PAID and remainder applied to principal.
- Refund -> decrease balance, create refund transaction.

---

## 10 — Deployment & infra recommendations

### Recommended stack

- Node.js (16+), TypeScript
- Prisma ORM
- PostgreSQL (AWS RDS / Neon / Supabase)
- Redis (for locks, BullMQ)
- BullMQ for reliable job queues or AWS SQS + Lambda workers
- Docker for containerization
- Kubernetes/ECS or serverless containers for scale
- nginx / ALB in front

### Deployment pattern

- CI: GitHub Actions
    - Run tests, lint, build
    - Deploy to staging
    - Run migrations (`prisma migrate deploy`)
- Production:
    - Blue/Green deploys
    - DB backups & automated migrations
- Secrets in AWS Secrets Manager or Vault
- Use infrastructure as code (Terraform)

### Cost considerations

- DB (RDS) + Redis + App nodes + queue + Sentry + monitoring
- Card issuing & payment providers have fees — factor into business model (interchange, issuance, settlement fees)

---

## 11 — Observability & monitoring

- Logs: structured JSON logs (winston/pino) to CloudWatch/ELK.
- Errors: Sentry integration.
- Metrics: Prometheus + Grafana for:
    - Purchase rate, repayment rate
    - Queue backlog
    - Error rates
- Alerts:
    - High failure rates
    - Queue backlog > threshold
    - Reconciliation mismatches
- Audit reporting: daily ledger and audit snapshot to S3 for compliance.

---

## 12 — Operational playbook / runbook (short)

### Common issues

- Payment provider webhook failed: retry with exponential backoff; if dead → manual reconcile.
- DB migration failure: halt deploy, run `prisma migrate resolve`, inspect migration.
- User disputes a purchase: freeze account, create investigation ticket, mark in audit.

### Manual actions

- Freeze/suspend account endpoint for support.
- Adjust credit limit via admin endpoint.
- Refund manual via admin endpoint (record reason).

---

## 13 — Roadmap & extension points

- **Phase 1 (MVP)**: Cardless BNPL via API + TickPay accounts + scheduled fee installments + repayment + basic scoring.
- **Phase 2**: Card issuing integration (Marqeta), auto-withdraw from linked bank accounts, advanced scoring with FinGPT.
- **Phase 3**: AI agent suggestions for purchases, dynamic limits, merchant acquisition API.
- **Phase 4**: Full credit product (installment terms), collections integration, securitization support.

---

## 14 — Example .env (sane defaults)

```
PORT=4000
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@host:5432/chronos
REDIS_URL=redis://:pass@redis-host:6379
JWT_SECRET=xxx
TICKPAY_FEE_RATE=0.005
TICKPAY_FEE_INSTALLMENTS=3
TICKPAY_BILL_CYCLE_MONTHS=1
AKOYA_API_KEY=...
AKOYA_BASE_URL=https://api.akoya.com
CARD_PROVIDER_API_KEY=...
PAYMENT_PROVIDER_API_KEY=...
NOTIFICATION_PROVIDER_API_KEY=...
SENTRY_DSN=...

```

---

## 15 — Folder structure & where to place validation

Recommended layout inside your existing `chronos-backend/src`:

```
src/
  controllers/
    tickpay.controller.ts
  services/
    tickpay.service.ts
    tickpay.scoring.service.ts
    tickpay.billing.service.ts
    tickpay.notification.service.ts
    tickpay.accounting.service.ts
  models/
    prisma.ts  // export prisma client
  middlewares/
    auth.middleware.ts
    error.middleware.ts
    validate.middleware.ts  // Joi/Zod validations
  routes/
    tickpay.routes.ts
  jobs/
    tickpay.scheduler.ts    // cron runner
    tickpay.worker.ts       // for worker tasks
  utils/
    money.ts (formatting)
    lock.ts (redis locks)
  config/
    akoya.config.ts
    cardProvider.config.ts
  app.ts
  server.ts

```

**Validation placement**: create validation schemas in `src/validators/tickpay.*.ts` used by `validate.middleware` before controller.

---

## 16 — Example controller skeleton (Express + TypeScript)

`src/controllers/tickpay.controller.ts`

```tsx
import { Request, Response } from "express";
import TickPayService from "../services/tickpay.service";

export const createAccount = async (req: Request, res: Response) => {
  const { userId, initialCreditLimit } = req.body;
  const acct = await TickPayService.createAccount(userId, initialCreditLimit);
  return res.json(acct);
};

export const createPurchase = async (req: Request, res: Response) => {
  const { userId, amount, currency, merchant, meta } = req.body;
  const result = await TickPayService.createPurchase(userId, { amount, currency, merchant, meta });
  return res.json(result);
};

export const createRepayment = async (req: Request, res: Response) => {
  const { userId, amount, currency, source } = req.body;
  const result = await TickPayService.createRepayment(userId, { amount, currency, source });
  return res.json(result);
};

```

---

## 17 — Example scheduler (tickpay.scheduler.ts)

`src/jobs/tickpay.scheduler.ts`

```tsx
import prisma from "../models/prisma";
import cron from "node-cron";
import TickPayService from "../services/tickpay.service";
import NotificationService from "../services/tickpay.notification.service";

// daily job
export const runTickPayDailyJob = async () => {
  console.log("Running TickPay daily job...");
  // 1. Mark installments due
  await TickPayService.markDueInstallments();
  // 2. Notify users
  await TickPayService.notifyUpcomingDues();
  // 3. Try auto-collect for authorized accounts
  await TickPayService.runAutoCollection();
  // 4. Reconciliation (async)
  await TickPayService.reconcileWithSettlement();
  console.log("TickPay daily job done");
};

// hook into server startup
export const scheduleDailyJob = () => {
  cron.schedule("0 8 * * *", async () => {
    try {
      await runTickPayDailyJob();
    } catch (err) {
      console.error("TickPay daily job failed", err);
    }
  });
};

```

---

## 18 — Notifications & UX flows

Notification types:

- `PURCHASE_CONFIRMED`
- `FEE_INSTALLMENT_SCHEDULED`
- `FEE_INSTALLMENT_DUE`
- `FEE_INSTALLMENT_PAID`
- `REPAYMENT_RECEIVED`
- `ACCOUNT_SUSPENDED`
- `CARD_ISSUED`

Use templating engine for emails, mobile push, and in-app notifications.

---

## 19 — Testing & Postman collection items (outline)

Postman requests:

1. `POST /auth/seed` — create test user (dev only)
2. `POST /api/tickpay/accounts` — create account
3. `GET /api/tickpay/accounts/:userId` — get account
4. `POST /api/tickpay/purchases` — create purchase
5. `GET /api/tickpay/accounts/:userId/fees` — list fees
6. `POST /api/tickpay/repayments` — create repayment
7. `POST /api/tickpay/admin/adjust` — admin adjust

Include test environment variables and pre-seeded users in your repo.

---

## 20 — Accounting & ledger considerations

- Every balance change must create a ledger entry (transfer table or separate `AccountingEntry` model).
- Ledger must have: `id, accountId, type (principal/fee), amount, currency, txRef, balanceAfter, createdAt`.
- Daily aggregated reports for GAAP/statutory purposes.

---

## 21 — Example seed data (minimal)

Create a seed script: `prisma/seed.ts` to create:

- test User
- test TickPayAccount with balance 0
- sample fee schedule entries (for dev testing)

---

## 22 — Operational security checklist before go-live

- Penetration test (external provider)
- PCI-DSS assessment if handling cards
- SOC2 readiness for infrastructure
- Proper KYC/AML provider integration
- Backups & RTO (Recovery Time Objective) planning

---

## 23 — Sample metrics to track (KPIs)

- Purchase volume (daily/monthly)
- Number of active TickPay accounts
- Repayment rate (% of dues repaid on time)
- Delinquency rate (% of installments missed > X days)
- Average outstanding balance per account
- Fee revenue (gross & net)
- Fraud events & chargebacks

---

## 24 — Recommended primitives and utilities to implement early

- Redis locking util (prevent race conditions on balance updates)
- `withTransaction` helper for `prisma.$transaction` usage
- Centralized error types (e.g., `InsufficientCreditError`, `AccountNotFoundError`)
- Idempotency keys / dedupe for purchase endpoint (client passes `idempotencyKey`)

---

## 25 — Example README starter (for engineer)

**README (TickPay module)** — short excerpt:

```
# TickPay Module (Chronos backend)

## Overview
TickPay is the merchantless BNPL system. This module contains controllers, services, and schedulers.

## Run locally
1. Copy .env.example -> .env and fill DB/Redis keys
2. `pnpm install` (or npm)
3. `npx prisma migrate dev`
4. `npx prisma db seed`
5. `pnpm dev` (starts server)

## Tests
- `pnpm test` (unit)
- `pnpm test:integration`

## Jobs
- cron job: `src/jobs/tickpay.scheduler.ts` (run at server start)

```

---

## 26 — Example decision & policy notes (business rules)

- **Fee policy**: 0.5% of purchase; split equally into 3 installments monthly. If installment due date passes unpaid for 30 days -> MISSED and late fee policy may apply (decided by legal).
- **Dispute window**: user may dispute purchases within 30 days. Support must freeze account during investigation.
- **Auto-collection**: only run with explicit user consent; must log each attempt.
- **Refunds**: refund principal; service fees remain as policy (can be adjusted on admin).

---

### Final notes & next steps

1. **Share with backend engineer**: the Prisma models, folder structure, and the API contract above.
2. **Implement core services first**: `createAccount`, `createPurchase`, `createRepayment`, `issueTickPayCard`.
3. **Add locking & transactions**: use Redis locks + Prisma transactions for balance updates.
4. **Add scheduler & notifications**: ensure daily job runs to mark dues and notify users.
5. **Build scoring microservice**: simple rules engine at first, later replace with FinGPT-backed model; log all decisions.
6. **Test thoroughly**: unit & integration tests; run Postman collection.
7. **Prepare compliance**: KYC/AML, audit logging, encryption standards.
