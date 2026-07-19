# Financial

# **LifeX – Financial Life Domain Documentation**

## **1. Overview**

The Financial Life module helps users manage their **personal finances**, track spending, optimize savings, handle loans, monitor credit scores, and receive **AI-driven investment recommendations**. It integrates with Chronos Core Banking and TickPay for money management.

**Key Goals:**

- Automate financial insights for users.
- Enable smart saving, budgeting, and investment suggestions.
- Provide a centralized view of loans, mortgages, and credit scores.

---

## **2. Features**

| Feature | Description | Backend Requirements | Notes |
| --- | --- | --- | --- |
| Smart Budgeting & Spending Insights | Track income and expenses, categorize spending, show trends | Database tables for transactions, categories, user budget, analytics jobs | Pull from core banking account & TickPay |
| Automatic Saving Plans | Users can set goals & auto-save from accounts | Create savings plan table, scheduled jobs to transfer money | Integrates with TickPay or user accounts |
| Personalized Investment Advice | AI-driven investment recommendations | Investment table, recommendation service, AI endpoints | Needs user risk profile and transaction history |
| Credit Score Monitoring | Display and track credit score | Connect with credit bureau API, user credit table | Optional: push alerts on changes |
| Loan & Mortgage Management | Track active loans, upcoming payments, interest, history | Loan table, repayment table, scheduler for due dates | Integration with core banking system |
| Tax Filing Assistance | Summarize transactions for tax purposes | Generate reports from user transaction history | Optional: export to CSV/PDF |
| Financial Life Planning | Overall view of user’s net worth, assets, liabilities | Aggregate data from accounts, TickPay, investments | Analytics endpoint for dashboards |

---

## **3. Database Structure**

**Tables & Models:**

1. **financial_plan**
    - id: uuid
    - user_id: fk User.id
    - goal_name: string
    - target_amount: decimal
    - saved_amount: decimal
    - frequency: enum (daily, weekly, monthly)
    - status: enum (active, completed, paused)
    - created_at, updated_at
2. **transaction** *(linked to core banking / TickPay accounts)*
    - id: uuid
    - user_id: fk User.id
    - account_id: fk Account.id
    - type: enum (income, expense)
    - category: string
    - amount: decimal
    - currency: string
    - metadata: json
    - created_at
3. **investment_advice**
    - id: uuid
    - user_id: fk User.id
    - risk_profile: string
    - recommended_assets: json
    - created_at
4. **loan**
    - id: uuid
    - user_id: fk User.id
    - principal_amount: decimal
    - outstanding_amount: decimal
    - interest_rate: decimal
    - due_date: date
    - status: enum (active, paid, overdue)

---

## **4. Backend Responsibilities**

- **API Endpoints**:
    - `GET /financial/overview` – return aggregated financial dashboard
    - `POST /financial/budget` – create/update user budgets
    - `GET /financial/budget` – list budgets
    - `POST /financial/savings` – create automatic saving plan
    - `GET /financial/savings` – list active saving plans
    - `GET /financial/investments/advice` – fetch AI-driven recommendations
    - `GET /financial/loans` – list user loans
    - `POST /financial/loans/pay` – make a repayment
    - `GET /financial/credit-score` – fetch credit score from API
    - `GET /financial/tax-report` – generate transaction summary report
- **Scheduled Jobs / Cron Tasks**:
    - Auto-save scheduled transfers (daily/weekly/monthly)
    - Credit score polling from API
    - Investment advice refresh daily
    - Loan due date reminders
- **Security & Compliance**:
    - Ensure PCI DSS compliance for financial data
    - Encrypt sensitive fields (e.g., account info, loan IDs)
    - Log all user actions for auditing
- **AI Integration**:
    - Consume investment recommendation AI (can be internal or external GPT-based engine)
    - Feed historical transaction and risk-profile data

---

## **5. Integration Points**

- **Core Banking**: For account balances, transactions, and payment transfers.
- **TickPay**: For BNPL or saving plan auto-transfers.
- **AI Services**: Personalized investment advice.
- **External APIs**: Credit bureau APIs for credit score updates.

---

## **6. Folder & Module Structure**

```
src/
 ├─ lifex/
 │   ├─ financial/
 │   │   ├─ financial.controller.ts
 │   │   ├─ financial.service.ts
 │   │   ├─ financial.routes.ts
 │   │   ├─ financial.module.ts
 │   │   ├─ dto/
 │   │   │    ├─ createBudget.dto.ts
 │   │   │    ├─ createSavings.dto.ts
 │   │   │    └─ ...
 │   │   ├─ entities/
 │   │   │    ├─ FinancialPlan.entity.ts
 │   │   │    ├─ Transaction.entity.ts
 │   │   │    ├─ Loan.entity.ts
 │   │   │    └─ ...
 │   │   └─ utils/
 │   │        ├─ scheduler.ts
 │   │        └─ aiIntegration.ts

```

---

## **7. Recommended Pages for Mobile App (LifeX – Financial)**

1. Financial Home Dashboard
2. Smart Budgeting Page
3. Budget Details / Edit Page
4. Savings Plan Overview
5. Create Savings Plan Page
6. Investment Advice Page
7. Loan & Mortgage Overview
8. Loan Payment Page
9. Credit Score Page
10. Tax Report Page

Each page should fetch data via backend API and allow interactive actions like adding a budget, scheduling a transfer, or marking a loan payment as completed.

---
