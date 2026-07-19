# BNPL Module (TickPay)

The BNPL module provides the **TickPay** service, allowing users to make purchases and pay for them in installments.

---

## 🏛️ Module Overview

TickPay integrates credit assessment, installment scheduling, and automated repayment flows. It is integrated into the Express backend and uses background jobs for interest and penalty calculations.

---

## 📂 Key Features

### 1. Credit Assessment
Uses user financial data (from Akoya/Plaid) to determine credit limits.
*   **Risk Scoring**: Automated logic to approve or deny BNPL requests.
*   **Limit Management**: Dynamic adjustments to borrowing capacity.

### 2. Installment Scheduling
Breaks down a purchase into a series of future payments.
*   **Fixed Schedules**: Bi-weekly or monthly payment plans.
*   **Transparency**: Clear breakdown of principal, interest, and fees.

### 3. Automated Repayments
Background jobs handle the collection of funds on the due dates.
*   **Auto-Debit**: Integrated with the Core Banking wallet system.
*   **Grace Periods**: Handling failed payments with automated retry logic.

### 4. Penalties & Interest
Logic for calculating late fees and accrued interest on outstanding balances.

---

## 🛠️ Components

*   **Controllers**: REST endpoints for the mobile app to request plans.
*   **Services**: Core logic for credit and repayment calculations.
*   **Jobs (`/jobs`)**: Cron jobs for monitoring due dates and processing auto-debits.

---

## 🧪 Testing

The BNPL module includes unit tests for the repayment math and credit decisioning services.

**Example: Run Repayment Service tests**
```bash
npm test src/modules/bnpl/services/repayment.service.spec.ts
```

---
*Chronos TickPay — Financial Flexibility Redefined*
