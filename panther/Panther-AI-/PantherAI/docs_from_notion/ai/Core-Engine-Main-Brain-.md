# Core Engine (Main Brain)

## **1. Overview**

**Panther**  the **central AI engine** powering the Chronos ecosystem. to transform Chronos from a traditional fintech into a **smart, adaptive, autonomous financial operating system**.

**Purpose:**

- Analyze user financial behavior
- Detect risks & opportunities
- Provide intelligent recommendations
- Power Kevin (AI Chat Assistant)
- Enable TickPay, BlockHub, and LifeX AI modules

---

## **2. Core Architecture**

```
          ┌───────────────────────────┐
          │      Chronos Apps         │
          │ (Mobile, Web, BlockHub)  │
          └─────────────┬────────────┘
                        │
                        ▼
          ┌───────────────────────────┐
          │       API Gateway         │
          └─────────────┬────────────┘
                        │
                        ▼
          ┌───────────────────────────┐
          │   Panther Agent Layer     │
          │ ─ Routing Agent           │
          │ ─ Finance Expert Agent    │
          │ ─ Behavioral Analyst     │
          │ ─ Execution Agent        │
          └─────────────┬────────────┘
                        │
                        ▼
          ┌───────────────────────────┐
          │     AI Model Layer        │
          │ - LLM (GPT-5, Claude, etc)│
          │ - Prompt Compiler         │
          │ - Memory & Context Store  │
          └─────────────┬────────────┘
                        │
                        ▼
          ┌───────────────────────────┐
          │     Data Layer (via API)  │
          │ - Transactions           │
          │ - Accounts               │
          │ - TickPay BNPL           │
          │ - Wallets / BlockHub     │
          │ - LifeX                  │
          └───────────────────────────┘

```

---

## **3. Panther Pillars**

| Pillar | Description |
| --- | --- |
| **Financial Intelligence Engine** | Categorizes expenses, predicts cash flow, detects risk, recommends actions |
| **Agent Layer** | Multi-agent system: Routing, Finance, Behavioral, Execution |
| **ML Prediction Suite** | Future ML models: credit scoring, subscription detection, fraud detection, BNPL risk, investment prediction |

---

## **4. Panther Agents**

| Agent | Responsibility | Key Notes |
| --- | --- | --- |
| Routing Agent | Classifies incoming queries | Directs request to correct specialized agent |
| Finance Expert Agent | Financial analysis, cashflow predictions | Uses LLM templates + rules |
| Behavioral Analyst Agent | Detects user patterns & spending habits | Generates insights for recommendations |
| Execution Agent | Fetches data, runs computation, returns result | Connects securely to backend & APIs |

---

## **5. Data Access & Security**

- Panther **does not store raw user data**.
- Access is **API-based**, tokenized via JWT, encrypted in transit.

**Allowed Data Sources:**

| Source | Usage |
| --- | --- |
| User profile | Personalization |
| Transactions | Categorization, cashflow |
| Accounts | Risk, balances |
| BNPL history | Risk analysis |
| Wallets (BlockHub) | Portfolio insights |
| Vendor catalog (TickPay / LifeX) | Recommendations, price comparison |

---

## **6. Model Strategy**

### **Phase 1 — LLM Wrapper**

- GPT/Claude for financial reasoning
- System prompts, templates, rules
- Fast deployment, reliable insights
- Limited ML training required

### **Phase 2 — Custom Trained Models**

- After 50k+ users / 1M+ transactions
- Modules:
    - Cashflow predictor
    - Subscription detector
    - BNPL risk scoring
    - Fraud detection
    - Spending pattern recognition

---

## **7. Core Functionalities**

1. **Personalized financial insights**
    - Overspending alerts
    - Savings recommendations
    - Budget notifications
2. **Cashflow prediction**
    - Future balance forecasts
    - Salary reminders
    - Overdraft alerts
3. **Risk & BNPL analysis**
    - Debt level checks
    - BNPL repayment prediction
    - Spending volatility detection
4. **Recommendation engine**
    - Cheaper vendor suggestions
    - Optimized BNPL usage
    - Personalized financial tips
5. **Product search & marketplace support**
    - TickPay vendor product search
    - LifeX partner suggestions
    - Budget-aligned recommendations

---

## **8. Integration Points**

- Backend APIs for all user data
- LLM / AI model endpoints
- Kevin chat interface
- Third-party APIs (TickPay, LifeX, BlockHub)

---

## **9. Deliverables for AI Engineer**

- Panther multi-agent skeleton
- System prompts & templates
- Data connectors
- Financial reasoning engine
- BNPL / Risk scoring logic
- Marketplace search integration
- Kevin chat integration

---
