# TickPay & Marketplace AI

## **1. Overview**

Panther’s integration with **TickPay BNPL** and partner marketplaces transforms Chronos into a **smart, proactive financial assistant** for purchasing, lending, and product discovery.

**Purpose:**

- Analyze BNPL repayment capacity and risk
- Suggest products that fit user budget and BNPL eligibility
- Compare prices across partners
- Provide intelligent recommendations on spending and installment plans
- Power Kevin, the AI assistant, for marketplace insights

---

## **2. Architecture**

```
           ┌───────────────────────────┐
           │     Chronos Web/Mobile    │
           └─────────────┬────────────┘
                         │
                         ▼
           ┌───────────────────────────┐
           │       API Gateway         │
           └─────────────┬────────────┘
                         │
                         ▼
       ┌─────────────────────────────────┐
       │     Panther Marketplace Agents  │
       │ ─ BNPL Risk Evaluator           │
       │ ─ Product Search Agent          │
       │ ─ Recommendation Engine        │
       │ ─ Execution & Data Fetch Agent │
       └─────────────┬──────────────────┘
                         │
                         ▼
       ┌─────────────────────────────────┐
       │   Marketplace Data Layer (API)  │
       │ - TickPay BNPL                  │
       │ - Vendor Catalogs (Nike, Amazon, etc.) │
       │ - Pricing & stock availability  │
       └─────────────────────────────────┘

```

---

## **3. Panther Marketplace Agents**

| Agent | Responsibility | Description |
| --- | --- | --- |
| **BNPL Risk Evaluator** | Determines installment eligibility | Uses user income, spending history, and TickPay data |
| **Product Search Agent** | Searches vendor catalogs | Finds items within user budget and BNPL eligibility |
| **Recommendation Engine** | Suggests optimized purchases | Chooses cheaper vendors or better installment plans |
| **Execution & Data Fetch Agent** | Connects to APIs and aggregates data | Pulls product, price, stock, and BNPL info |

---

## **4. Key Features**

### **4.1 BNPL Risk Analysis**

- Reads user’s banking and TickPay data
- Determines safe BNPL limit per transaction
- Flags high-risk BNPL decisions
- Calculates repayment timelines

### **4.2 Product Search & Comparison**

- Query partner marketplaces: Nike, Amazon, BestBuy, etc.
- Compare prices for similar products
- Filter by BNPL eligibility
- Suggest alternative vendors if cheaper

### **4.3 Intelligent Recommendations**

- “Buy this sneaker from Vendor A — cheaper + fits BNPL”
- “Your budget allows 3-month installment, but 6-month spreads risk”
- “Avoid electronics BNPL this month due to high debt ratio”

### **4.4 Personalized Marketplace AI (Kevin Integration)**

- Handles user queries like:
    - “Find laptops under $1,200 eligible for BNPL”
    - “Suggest best installment plan for Nike Air purchase”
    - “Which subscription box can I afford this month?”

### **4.5 Data Security**

- Panther **does not store sensitive financial or product data**
- Uses encrypted API calls for all marketplace and BNPL data
- Maintains user privacy & GDPR compliance

---

## **5. Data Sources**

| Source | Data Access | Purpose |
| --- | --- | --- |
| TickPay API | BNPL eligibility, repayment history | Risk scoring, safe installment |
| Vendor APIs (Nike, Amazon, BestBuy, etc.) | Product catalog, price, stock | Product search & recommendation |
| User Banking API | Balance, income, transactions | BNPL risk, personalized suggestion |

---

## **6. Agent Workflows**

### **6.1 Product Search Flow**

1. Kevin receives query from user
2. Panther interprets user intent
3. Product Search Agent queries partner marketplaces
4. Execution Agent filters items by BNPL eligibility
5. Recommendation Engine ranks items by price, brand, and repayment safety
6. Results sent back to user via Kevin

### **6.2 BNPL Risk Flow**

1. Retrieve user’s transaction and account data
2. Compute debt-to-income ratio and installment capacity
3. Determine max safe BNPL amount
4. Feed into product search recommendations
5. Provide alert if user risk is high

---

## **7. Deliverables for AI Engineer (Marketplace Focus)**

| Month | Task |
| --- | --- |
| Month 1 | Build BNPL risk evaluator, TickPay API integration |
| Month 2 | Product search agent, multi-marketplace API connectors |
| Month 3 | Recommendation engine, Kevin integration |
| Month 4 | Testing, optimization, Phase 1 MVP launch |

---

## **8. Prompts & Templates**

### **BNPL Risk Prompt**

```
You are Panther — BNPL Risk Evaluator.
- Analyze user's income, balance, debt, spending.
- Return max safe BNPL amount.
- Include repayment schedule.
- Provide risk explanation.

```

### **Product Search Prompt**

```
You are Panther — Marketplace Product Agent.
- Search partner vendors for items under user's budget.
- Filter by BNPL eligibility.
- Sort by price, brand preference, installment options.
- Return JSON: item name, vendor, price, BNPL eligibility, link

```

### **Recommendation Prompt**

```
You are Panther — Marketplace Recommendation Engine.
- Suggest safest BNPL option.
- Recommend cheaper alternatives if available.
- Highlight repayment risk.

```

---

## **9. Summary**

Panther x TickPay & Marketplace is the **smart purchasing brain** of Chronos:

- Helps users buy safely using BNPL
- Suggests cost-effective vendors
- Predicts repayment risk
- Provides personalized marketplace advice through Kevin

This document serves as a **modular guide** for engineers handling TickPay & Marketplace AI features.

---
