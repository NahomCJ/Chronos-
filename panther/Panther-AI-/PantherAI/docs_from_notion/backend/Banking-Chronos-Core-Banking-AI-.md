# Banking (Chronos Core Banking AI)

### *Panther Subsystem Documentation*

---

# **1. Overview**

**Chronos Banking AI** is Panther’s dedicated intelligence layer for the banking system.

It enhances the Chronos Core Banking Engine by providing:

- Smart account insights
- Automated budgeting
- Spending supervision
- Savings optimization
- Banking safety checks
- Fraud & anomaly detection (Phase 2)
- Personalized banking recommendations
- Transactional intelligence (categorization + predictions)
- Banking chat assistant for all services

This module is the **brain controlling all smart banking behavior**.

---

# **2. Core Responsibilities**

### **A. Banking Analytics**

Panther computes banking intelligence such as:

- Daily/weekly/monthly spending patterns
- Category-level insights
- Predictive balance estimation
- Savings projection
- Risk of overdraft
- Income fluctuation patterns

---

### **B. Smart Budgeting**

Automatically creates:

- Realistic monthly budgets
- Category limits
- Spending guardrails
- Savings plans (short-term + long-term)

---

### **C. Banking Fraud Signals (Soft AI – Phase 1)**

Panther identifies:

- Unusual transactions
- Rapid withdrawals
- Duplicate charges
- Strange merchant patterns
- High-risk locations

Phase 2 → integrates with anomaly detection ML model.

---

### **D. Fee Optimization**

Identifies:

- Hidden bank fees
- Subscription drains
- Unnecessary charges
- Late payment risks

And tells the user how to avoid them.

---

### **E. Cashflow & Salary Predictions**

Panther predicts:

- Next salary drop
- End-of-month balance
- Safe-to-spend amount
- Overspending risk

---

### **F. Banking Chat Assistant**

Kevin uses Chronos Banking AI to answer:

- “How much can I spend today?”
- “Am I overspending this month?”
- “What’s my financial health score?”
- “Can I afford £200 for shopping this weekend?”
- “Break down my spending this week.”

---

# **3. Architecture Overview**

```
                         ┌───────────────────────┐
                         │     Chronos App       │
                         │ (Banking, TickPay)    │
                         └───────────┬───────────┘
                                     │
                                     ▼
                         ┌───────────────────────┐
                         │  Panther Agent Hub    │
                         └───────────┬───────────┘
                                     │
           ┌─────────────────────────┼────────────────────────┐
           ▼                         ▼                        ▼
  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
  │ Banking Analyst  │     │ Predictive Agent │     │ Safety & Risk AI │
  └───────┬──────────┘     └─────────┬────────┘     └─────────┬────────┘
          │                          │                          │
          ▼                          ▼                          ▼
  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
  │ Spending Engine  │     │ ML Forecasting   │     │ Fraud Heuristics │
  └──────────┬───────┘     └─────────┬────────┘     └─────────┬────────┘
             │                        │                        │
             ▼                        ▼                        ▼
        ┌───────────────────────────────────────────────────────────────┐
        │                Chronos Banking Backend (Core APIs)            │
        └───────────────────────────────────────────────────────────────┘

```

---

# **4. Input Data Sources**

Chronos Banking AI pulls data **only from the backend**, never directly from banks.

| Data Type | Data Pulled | Usage |
| --- | --- | --- |
| Accounts | balances, account type | balance forecasting |
| Transactions | category, amount, merchant | patterns, insights |
| Income | salary history | predictions |
| Transfers | internal/external | risk monitoring |
| Savings | goals, progress | optimization |
| Fees | monthly fees | fee minimization |
| Cards | card payments | fraud signals |
| BNPL | repayment schedule | repayment risk |

---

# **5. Agent Breakdown**

### **1. Banking Analyst Agent**

Responsible for:

- spending summaries
- daily/weekly insights
- categorization
- fee analysis
- budgeting suggestions
- savings recommendations

This is the “classic banking intelligence.”

---

### **2. Predictive Banking Agent**

Uses:

- rule-based forecasting
- LLM temporal understanding
- upcoming bills sum
- salary behavior

Outputs: we

- end-of-month balance
- next salary date guess
- “safe-to-spend” calculation
- overdraft risk signal

---

### **3. Safety & Risk Agent**

Detects:

- suspicious spending
- new merchant anomalies
- foreign location risk
- duplicate transactions
- card misuse signals

This agent powers our **fraud alerts**.

---

### **4. Banking Chat Agent (Kevin Layer)**

Acts as the user-facing interface.

Everything the user asks related to:

- bills
- spending
- budgets
- savings
- risk
- financial health

…is routed through this agent.

---

# **6. System Prompts (Internal-Level)**

### **Banking Analyst Prompt**

```
You are Panther Banking AI.
You analyze banking transactions, detect patterns, classify spending, and generate insights.
Be precise, data-driven, and conservative.
Never hallucinate missing data.

```

### **Predictive Agent Prompt**

```
Forecast future balance, cashflow, and salary arrivals.
Base all calculations strictly on the numerical data provided.
Return clear numbers and confidence levels.

```

### **Risk Agent Prompt**

```
Identify anomalies in transactions.
Flag suspicious patterns.
Never classify normal behavior as fraud without clear justification.

```

### **Banking Assistant Prompt**

```
Explain financial insights in simple language.
Be helpful, actionable, and safe.
Never provide investment advice.

```

---

# **7. Banking Intelligence Features (Deep Detail)**

## **7.1 Transaction Categorization**

Version 1: LLM classification with merchant-name heuristics

Version 2: ML model trained on Chronos data

---

## **7.2 Budgeting & Guardrails**

AI builds:

- monthly budgets
- daily spending caps
- category limits

Panther monitors and warns:

- “You’re 60% over your coffee budget.”
- “At this pace you will overspend by £200 this month.”

---

## **7.3 Savings Optimization**

Panther generates:

- save X/month
- save to reach goal by date
- dynamic adjustments based on income change

---

## **7.4 Financial Health Score**

Score based on:

- spending consistency
- income stability
- saving rate
- debt exposure
- lifestyle quality (LifeX integration)

Ranges from **0–100**.

---

## **7.5 Account Safety Monitoring**

Soft real-time:

- new merchant patterns
- location mismatch
- repeated transactions
- unusual high spending

---

## **7.6 Banking Summaries**

Daily, weekly, monthly summaries automatically generated:

- total spent
- changes from last period
- top categories
- risky trends
- savings updates

---

# **8. Integration Points**

Chronos Banking AI connects to:

### **A. Chronos Banking Core**

- Accounts
- Transactions
- Savings
- Cards
- Transfers

### **B. TickPay**

For:

- affordability checking
- BNPL risk scoring

### **C. LifeX**

For:

- lifestyle patterns
- habit mapping
- stress detection

---

# **9. Endpoints Needed**

- `/banking/analyze`
- `/banking/predict`
- `/banking/budget`
- `/banking/savings`
- `/banking/risks`
- `/banking/fraud-check`
- `/banking/summary/daily`
- `/banking/summary/monthly`

---

# **10. Timeline for AI Engineer**

### **Month 1**

- Categorization system
- Banking insights generator
- Summary generator

### **Month 2**

- Prediction engine
- Budget system
- Savings engine

### **Month 3**

- Safety & risk
- Fraud heuristics
- Chat integration

---

# **11. Simple Showcase Summary**

Chronos Banking AI makes Chronos a **smart intelligent bank**, not just a digital banking app.

It:

- understands user behavior
- predicts financial outcomes
- builds smart budgets
- protects users from risk
- optimizes savings
- supports all banking tasks in chat

---
