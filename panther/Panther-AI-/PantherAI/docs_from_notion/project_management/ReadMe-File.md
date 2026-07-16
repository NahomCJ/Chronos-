# ReadMe File

### 🏦 **Chronos Core – TickPay Module**

> BNPL (Buy Now, Pay Later) + Instant Micro-Credit Service for Chronos Core Banking
>

---

### 📘 Overview

TickPay is Chronos’ in-house **BNPL (Buy Now, Pay Later)** and **micro-credit** system that allows users to:

- Buy items and split payments into installments
- Use a virtual or physical Card for purchases
- Track repayments, view credit limits, and manage outstanding balances

TickPay connects seamlessly with **Accounts**, **Transactions**, and **Card services** inside Chronos Core.

This module is built for scalability, allowing AI-based credit scoring, merchant APIs, and dynamic interest management in future phases.

---

### ⚙️ Core Folder Structure

```
src/
 └── core/
     └── tickpay/
         ├── tickpay.controller.ts
         ├── tickpay.service.ts
         ├── tickpay.routes.ts
         ├── tickpay.types.ts
         ├── tickpay.utils.ts
         ├── tickpay.scheduler.ts
         ├── tickpay.validation.ts
         ├── __tests__/
         │    ├── tickpay.unit.test.ts
         │    └── tickpay.integration.test.ts
         └── README.md

```

---

### 🧠 Data Models (Prisma)

TickPay uses these main tables in the database:

| Model | Description |
| --- | --- |
| `TickPayAccount` | Each user’s BNPL account, including balance, limit, and status |
| `TickPayTransaction` | Every BNPL purchase, repayment, or charge event |
| `TickPayFeeInstallment` | Installment breakdowns for each BNPL transaction |
| `TickPayCard` | Links TickPay accounts with Chronos Cards for seamless usage |

---

### 🚀 API Endpoints

| Endpoint | Method | Description |
| --- | --- | --- |
| `/tickpay/account/create` | `POST` | Create a TickPay account for a user |
| `/tickpay/account/:id` | `GET` | Get TickPay account details |
| `/tickpay/purchase` | `POST` | Make a BNPL purchase |
| `/tickpay/repayment` | `POST` | Process repayment for an installment |
| `/tickpay/fees/upcoming` | `GET` | Fetch upcoming fees or installments |
| `/tickpay/transactions/:id` | `GET` | View transaction history for a user |
| `/tickpay/card/link` | `POST` | Link TickPay account with Chronos Card |
| `/tickpay/scheduler/run` | `POST` | Trigger scheduled repayment or fee recalculation |

---

### 🧩 Key Features

| Feature | Description |
| --- | --- |
| **BNPL Purchases** | Splits large purchases into 3–6 installments |
| **Credit Limit Management** | Default $500, dynamically upgradable |
| **Interest Fee Scheduling** | Fee calculation handled by scheduler service |
| **TickPay Card Link** | Users can use the card for direct purchases |
| **Automated Repayments** | Scheduler auto-deducts funds on due dates |
| **Penalty Handling** | Overdue payments generate late fees |
| **AI Credit Score (Phase 2)** | Risk analysis and dynamic credit scoring |

---

### 🧮 Business Logic Flow

1. **Create Account** → User signs up or activates TickPay inside app
2. **Purchase** → TickPay checks credit limit and creates transaction
3. **Split Fees** → Transaction auto-generates installments (3–6)
4. **Repayment** → User repays via wallet or linked account
5. **Scheduler** → Checks overdue or upcoming installments daily
6. **AI Score (Future)** → Adjusts user’s credit score dynamically

---

### 🔐 Dependencies & Integrations

| Dependency | Purpose |
| --- | --- |
| `Prisma ORM` | Database modeling and query abstraction |
| `BullMQ` or `Agenda.js` | Scheduler for repayments |
| `Node-Cron` | Backup job scheduling |
| `AWS SES / Twilio` | Payment reminders and notifications |
| `AI Credit Scoring (Future)` | Dynamic limit and fee adjustment |
| `Core Banking API` | Sync with user wallet and transactions |
| `3rd Party Auth` | Biometric or token-based authentication |

---

### 🧰 Developer Setup

1. Run database migrations:

    ```bash
    npx prisma migrate dev --name init_tickpay

    ```

2. Seed TickPay default data (optional):

    ```bash
    npx tsx prisma/seed/tickpay.seed.ts

    ```

3. Run module tests:

    ```bash
    npm run test tickpay

    ```

4. Start dev server:

    ```bash
    npm run dev

    ```


---

### 📊 Future Enhancements (Phase 2)

| Feature | Description |
| --- | --- |
| AI Credit Scoring | Adjust limits based on repayment behavior |
| Merchant API | Partner merchants for integrated BNPL checkout |
| TickPay+ | Premium plan with higher limits |
| Cross-border BNPL | Support for multi-currency payments |
| Analytics Dashboard | Admin insights on repayment trends |

---
