# Core Banking

### 📘 Overview

The **Chronos Core Banking System** is the foundation of the entire Chronos ecosystem.

It handles **user accounts**, **transfers**, **FX orders**, **cards**, **auditing**, and **compliance**.

This layer connects seamlessly with:

- **TickPay (BNPL)** for deferred payments,
- **BlockHub** for digital assets,
- **PDIM (Biometric Authentication)** for identity,
- **LifeX** for cross-service financial features.

---

## ⚙️ **1. Tech Stack**

| Layer | Technology | Description |
| --- | --- | --- |
| Backend Framework | **Node.js (NestJS / Express)** | API layer for all banking services |
| Database | **PostgreSQL + Prisma ORM** | Core data layer |
| Caching | **Redis** | Used for OTPs, sessions, rate limits |
| Authentication | **JWT + Biometric (via PDIM)** | Hybrid auth |
| Hosting | **AWS (ECS or Lambda)** | Scalable containerized setup |
| Logging | **Winston + AWS CloudWatch** | Activity & error tracking |
| Security | **AES-256, HTTPS, Helmet.js** | Data encryption & secure headers |

---

## 🏦 **2. Core Modules & Responsibilities**

| Module | Description | Key Tables |
| --- | --- | --- |
| **User Management** | Signup, KYC, biometric link, profile updates | `User` |
| **Accounts** | Create, manage, and monitor user bank accounts | `Account` |
| **Transfers** | Internal, P2P, and external transfers | `Transfer`, `TransferTransaction`, `TransferAudit` |
| **FX Orders** | Foreign exchange trading and currency conversion | `FxOrder` |
| **Cards** | Link, manage, and issue debit/credit cards | `Card`, `TickPayCard` |
| **Audit & Compliance** | Record all actions for transparency | `TransferAudit` |
| **Notifications** | Email, SMS, and push notifications | External service integration (Twilio, SendGrid) |

---

## 🧩 **3. API Route Structure**

### 📂 **Base URL:** `/api/v1/core`

| Endpoint | Method | Description |
| --- | --- | --- |
| `/auth/signup` | POST | Register user with email, password, and OTP |
| `/auth/login` | POST | Authenticate and generate JWT token |
| `/auth/biometric/link` | POST | Link biometric ID (via PDIM) |
| `/accounts/create` | POST | Create a new account |
| `/accounts/:id` | GET | Fetch account details |
| `/accounts/balance` | GET | Get all user balances |
| `/transfer/initiate` | POST | Initiate a transfer |
| `/transfer/confirm` | POST | Confirm transfer (with OTP or biometric) |
| `/transfer/history` | GET | Fetch user transfer history |
| `/fx/quote` | POST | Request FX conversion quote |
| `/fx/execute` | POST | Execute FX order |
| `/card/issue` | POST | Issue new virtual or physical card |
| `/card/list` | GET | Fetch all user cards |
| `/audit/logs` | GET | Fetch user or system audit logs |

---

## 🧱 **4. Database Models (via Prisma)**

> Already well-structured in your Prisma schema.
>
>
> But for quick reference, here’s the simplified model relationship map:
>

```
User ─┬─< Account ─┬─< Transfer (Sender)
      │             └─< Transfer (Receiver)
      │
      ├─< FxOrder
      └─< Card ─┬─< TickPayCard

```

---

## 🔒 **5. Security & Authentication**

- **Primary Auth**: JWT tokens
- **Secondary Auth (optional)**: Biometric via PDIM service
- **KYC Flow**: User submits ID + selfie → Verified via 3rd-party KYC API (e.g., Sumsub or Onfido)
- **2FA**: Optional OTP sent by Twilio

All transactions (transfer, card issue, FX) require **biometric confirmation or OTP**.

---

## 💸 **6. Transactions Flow**

**Example: Internal Transfer**

1. User initiates `/transfer/initiate`
2. Server validates balances
3. If valid → create pending transfer + notify user
4. User confirms via OTP or biometric
5. Debit + Credit operations recorded in `TransferTransaction`
6. `TransferAudit` entry logged
7. Notifications sent (email/SMS/push)

---

## 🌍 **7. Integrations**

| Type | Provider | Purpose |
| --- | --- | --- |
| **KYC/AML** | Sumsub, Alloy | User verification |
| **Biometric Auth** | PDIM (Chronos internal wrapper) | Identity confirmation |
| **Card Issuing** | Marqeta, Stripe Issuing | Virtual/physical cards |
| **FX Rates** | OpenExchangeRates, CurrencyLayer | Live FX quotes |
| **Notifications** | SendGrid, Twilio | Email + SMS |
| **Payments** | Stripe, Payoneer | External transfers and loads |

---

## 🧠 **8. AI Insights (Connected Later)**

Once the AI investment system is active, Chronos Core will send:

- Spending patterns,
- Account balances,
- FX activity

    to the AI module for **predictive analytics and smart budgeting**.


---

## 🧰 **9. Developer Setup**

### Prerequisites:

- Node.js ≥ 18
- PostgreSQL ≥ 14
- Redis (for sessions)
- `.env` file with:

    ```
    DATABASE_URL="postgresql://user:pass@localhost:5432/chronos"
    JWT_SECRET="your_secret_key"
    REDIS_URL="redis://localhost:6379"

    ```


### Commands:

```
npm install
npx prisma migrate dev
npm run dev

```

---

## 📋 **10. TODOs for Engineer**

| Task | Description | Status |
| --- | --- | --- |
| Create all user/account routes | Basic CRUD setup | ✅ Schema ready |
| Add Redis caching for OTPs | For secure verification | ⏳ |
| Integrate PDIM biometric routes | Use external API link | ⏳ |
| Test all transfer + FX logic | Core transaction handling | ⏳ |
| Connect card issuing API | Use sandbox from Stripe | 🔜 |
| Add audit + logging middleware | Ensure transparency | 🔜 |
