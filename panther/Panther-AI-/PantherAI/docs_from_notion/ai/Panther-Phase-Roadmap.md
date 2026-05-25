# Panther – Phase Roadmap

---

# **🔵 PHASE 1 — Financial Intelligence (No Investing Yet)**

### **Core Features**

- Transaction categorization
- Spending analysis
- Cashflow prediction
- BNPL risk scoring
- Budget recommendations
- Subscription detection
- Price comparison + BNPL eligibility
- Kevin financial chat assistant
- Marketplace search
- Vendor product catalog browsing
- Financial coaching (non-investment)

### **Important:**

🚫 **No auto-investing in Phase 1**

🚫 **No automatic portfolio management**

🚫 **No trade execution**

Only *advice*, *analysis*, and *prediction*, not execution.

### **Why?**

- Investment systems require strict regulatory compliance.
- Risk scoring needs long user history to be accurate.
- You need trained models, not LLM heuristics.

Phase 1 is safe, stable, and what fintechs like Revolut, Monzo, and N26 start with.

---

# **🟣 PHASE 2 — Hybrid Investment Insights (Still No Auto-Investing)**

**Timeline: After You Have ~10K+ Users**

This phase introduces **investment recommendations**, not automatic buying.

### **What Panther does in Phase 2**

- Reads user risk profile
- Suggests investment strategies
- Provides recommended asset allocation
- Recommends crypto or stock percentages
- Gives financial coaching (e.g., “Invest 5% of income monthly”)
- Explains why certain assets are good

### **Still NOT included in Phase 2**

🚫 Auto executing trades

🚫 Real-time portfolio rebalancing

🚫 Automated risk hedging

### **Why?**

You need more:

- User behavior data
- Market data provider integrations
- Regulatory approvals
- Multi-country legal compliance

Panther is still *advice-only*.

---

# **🔴 PHASE 3 — Auto-Investor (Full Autopilot Investing System)**

**Timeline: Only After Chronos Is Mature + Licensed**

This is the future version that makes Chronos special but must NOT be rushed.

### **Panther Auto-Investor Features**

✔ Automatically invests a fixed percentage of income

✔ Automatically rebalances user portfolio

✔ Automatically sells risky or failing assets

✔ Automatically hedges downside

✔ Auto-saves extra funds

✔ Market anomaly detection

✔ Uses ML models trained on Chronos user data

### **Risk & Requirements**

Auto-investing requires:

- Formal regulatory approval (by country)
- Rock-solid risk engines
- Auditable algorithms
- Fail-safe compliance
- Strong historical dataset
- Partner brokerage APIs
- Legal disclaimers and user agreements

**This is the final phase.**

---

# **FINAL SUMMARY — WHAT TO TELL YOUR AI ENGINEER**

> “Panther is being developed in 3 phases.
>
>
> Your job now is to focus ONLY on Phase 1: financial intelligence, spending analysis, predictions, BNPL risk scoring, marketplace search, and chat assistant.
>
> Auto-investing will come in later phases because it requires very strong risk management, a large dataset, and regulatory approvals.”
>

---

# 🔥 **PANTHER – FULL AI SYSTEM DOCUMENTATION (FINAL VERSION)**

# **EXECUTIVE SUMMARY**

**Panther** is ChronosBank’s AI engine.

Its mission is to become the world’s first **fully autonomous financial intelligence & investment management system**.

Panther evolves in **three phases**:

### **PHASE 1 – Financial Intelligence**

✔ Spending analysis

✔ Cashflow prediction

✔ BNPL risk scoring

✔ Budget recommendations

✔ Subscription management

✔ Marketplace product search + price comparison

✔ Kevin chat assistant (financial coaching only)

❌ *No investing functions yet*

### **PHASE 2 – Investment Advisory (3–12 months)**

✔ Risk scoring for investments

✔ Investment recommendations (advice only)

✔ Simulated portfolios

✔ Macro analysis

❌ *Still no automatic investing*

### **PHASE 3 – Auto-Investor (Year 2+)**

✔ Full auto-investing engine

✔ Auto-rebalancing

✔ Auto-hedging

✔ Smart saving

✔ Market anomaly detection

*This requires large datasets + regulatory approvals.*

---

# **1. PRODUCT PURPOSE**

Panther solves three problems in financial apps:

### **1. Users don’t understand their money.**

Panther explains spending, habits, waste, risk, and projected future income.

### **2. Financial advisors are expensive and slow.**

Panther replaces human advisors with AI-guided financial coaching.

### **3. Investment advice is risky if done with LLMs alone.**

Panther combines LLMs + Machine Learning + historical datasets, making it safe.

---

# **2. SYSTEM ARCHITECTURE**

## **Panther Architecture Layers**

### **Layer 1 — Data Collection**

- User transactions (ChronosBank backend)
- Income history
- Spending categories
- Subscriptions
- BNPL usage
- User demographic & KYC
- Behavior signals
- Marketplace partner product catalogs
- Market data feeds

### **Layer 2 — ML Pipelines**

- Transaction classification model
- Cashflow forecasting model
- BNPL eligibility model
- Fraud detection model
- Price comparison engine
- Recommendation engines
- Risk profiling system
- In Phase 3 → investment optimization models

### **Layer 3 — AI Agents**

- **Panther Advisor (GPT wrapper)**
- **Kevin Purchase Agent (searches products)**
- **BNPL Risk Agent**
- **Budget & Spending Advisor**
- **Investment Advisor (Phase 2)**
- **Auto-Investor (Phase 3)**

### **Layer 4 — API Gateway**

Panther exposes endpoints like:

- `/panther/analyze-spending`
- `/panther/predict-cashflow`
- `/panther/risk/bnpl-score`
- `/panther/marketplace/search`
- `/panther/coach`
- `/panther/invest/recommend` (Phase 2)
- `/panther/invest/auto` (Phase 3)

### **Layer 5 — UI Layer (App + Web)**

- Dashboard insights
- Charts
- Product suggestions
- BNPL score meter
- Kevin chat
- Investing advisor screens

---

# **3. FEATURE SPECIFICATION (PHASE 1)**

THIS IS WHAT YOUR AI ENGINEER BUILDS NOW.

## **3.1 Spending Categorization Engine**

### Inputs:

- Raw transactions
- Merchant info
- User history

### Outputs:

- Category (Food, Transport, Shopping, etc.)
- Confidence score
- Category insights

### Model:

- Gradient boosting or BERT transaction classifier
-
    - Heuristics for unknown merchants

---

## **3.2 Cashflow Prediction**

### Inputs:

- Salary
- Recurring payments
- Daily habits

### Outputs:

- Projected account balance 7/30/90 days
- Risk of overdraft
- Income spike prediction

### Model:

- Time-series forecasting (Prophet, LSTM, XGBoost)

---

## **3.3 Subscription Detection**

- Detect recurring payments
- Identify hidden or forgotten ones
- Suggest cancellations
- Predict upcoming charges

### Model:

- Pattern matching + clustering

---

## **3.4 BNPL Risk Scoring (TickPay Integration)**

Panther scores the user BEFORE approving BNPL.

### Score Factors:

- Income stability
- Spending volatility
- Loan history
- Risk index
- Cashflow projection

### Output:

- Approval Yes/No
- Maximum BNPL amount allowed
- Repayment schedule
- Dynamic interest rate

---

## **3.5 Financial Coaching (Chat Assistant)**

### Powered by:

- GPT-5 (wrapper)
- Finetuned financial prompts
- Approved advice rules

### Capabilities:

- Spending explanations
- Advice on budgeting
- Personalized goals
- Savings tips
- Alerts

---

## **3.6 Marketplace Search + Product Recommendations**

(For TickPay Buy-Now-Pay-Later shopping)

### Agent: **KEVIN**

Capabilities:

- Search partner marketplaces (Amazon, Nike, Zara, HP. etc.)
- Find products matching:
    - User price range
    - Category
    - Product type
    - Brand preference
- Rank by:
    - Price
    - Warranty
    - Delivery time
    - BNPL eligibility

### Data Sources:

- Partner APIs (if allowed)
- Product feeds
- Scrapers (if approved by partners)

---

## **3.7 Price Comparison Engine**

- For each product → compare across marketplaces
- Show cheapest vendor
- Show BNPL eligibility
- Show alternative safer options within budget

---

# **4. FEATURE SPECIFICATION (PHASE 2)**

Not being built yet — but document the plan.

## **4.1 Risk Profiling**

- Risk tolerance scoring
- Behavioural finance profiling
- Volatility comfort

---

## **4.2 Investment Recommendation**

Given risk score:

- Recommend index funds
- Crypto allocation suggestion
- Cash cushion levels
- Time horizon modelling

Outputs:

- Suggested portfolio but **not executed**
- With explanation + educational notes

---

## **4.3 Macro Analysis Insight**

- Automated news summarisation
- Economic cycles detection

---

# **5. FEATURE SPECIFICATION (PHASE 3 – AUTO INVESTOR)**

*(Included for completeness but NOT part of engineering now.)*

## **5.1 Auto-Investment Engine**

- Automatically invests fixed monthly %
- Automatically adjusts risk after life events
- Runs 24/7
- Uses reinforcement learning models

---

## **5.2 Auto-Rebalancing**

E.g. If portfolio deviates from target 60/40 → Panther rebalances automatically.

---

## **5.3 Auto-Hedging**

Detects risk spikes → hedges automatically.

---

# **6. DATA SOURCES**

## Free Data:

- Yahoo Finance historical prices
- Federal Reserve datasets
- Kaggle financial datasets
- Crypto APIs with free tiers
- Open banking transaction logs
- Merchant databases

## Paid Data (Later)

- Bloomberg
- Refinitiv
- Morningstar
- Paid crypto tick data

---

# **7. SYSTEM LIMITATIONS**

Phase 1 cannot:

- Give investment advice
- Execute trades
- Offer portfolio returns
- Predict markets
- Replace licensed advisors (legally)

---

# **8. COMPLIANCE & SAFETY**

- Panther must NOT recommend specific assets until Phase 2
- Advice must be educational only
- Must include disclaimers
- Must use a rule-based guardrail system
- All predictions must include uncertainty estimates

---

# **9. TASKS FOR THE AI ENGINEER (FIRST 5 weeks )**

## week 1-2 — Foundation

- Build transaction classifier
- Build subscription detector
- Build spending insights pipeline
- Implement Kevin basic search agent
- Integrate partner product APIs

## week 3-4 — Predictions

- Build cashflow forecasting model
- Build BNPL risk scoring model
- Build price comparison engine

## week 5 — Chat Layer

- Build financial coach using GPT APIs
- Implement guardrails
- Connect all insights to chat

---
