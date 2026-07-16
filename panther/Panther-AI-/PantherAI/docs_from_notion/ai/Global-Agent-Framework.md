# Global Agent Framework

### *Master Architecture of the Chronos Intelligence System*

---

# **1. Purpose of This Framework**

The **Panther Global Agent Framework** is the centralized AI architecture powering:

- Chronos Banking
- TickPay BNPL
- BlockHub (crypto)
- Marketplace AI
- LifeX
- Kevin (chat assistant)
- Notifications + financial summaries
- Risk scoring and safety systems
- Auto-planning and automated tasks

It turns Chronos from a static fintech into a **dynamic intelligent OS** where every service is AI-augmented.

---

# **2. High-Level Architecture**

```
                             ┌───────────────────────────┐
                             │      Chronos Client        │
                             │  (App, Web, BlockHub)      │
                             └──────────────┬────────────┘
                                            │
                                            ▼
                           ┌────────────────────────────────┐
                           │   Panther Global Agent Hub     │
                           └──────────────┬─────────────────┘
                                          │
   ┌──────────────────────────────────────┼──────────────────────────────────────┐
   ▼                                      ▼                                      ▼
┌──────────────────┐            ┌──────────────────┐                   ┌──────────────────┐
│  Domain Agents   │            │  Orchestration   │                   │   Utility Agents │
└───────┬──────────┘            └───────┬──────────┘                   └────────┬────────┘
        │                                │                                   │
        ▼                                ▼                                   ▼
BANKING | TICKPAY | BLOCKHUB | MARKETPLACE | LIFEX | SECURITY | SYSTEM | MEMORY | TOOLS

```

---

# **3. Agent Types (The Full List)**

The Panther Framework uses **three classes of agents**:

---

# **A. Domain Agents (Service Brains)**

These are the experts for each Chronos subsystem.

| Agent | Role | Subsystems |
| --- | --- | --- |
| **Banking Analyst Agent** | Spending + budgeting | Chronos Bank |
| **Predictive Finance Agent** | Cashflow, salary, forecasting | Bank |
| **Risk & Fraud Agent** | Anomaly detection | Bank, TickPay |
| **TickPay Affordability Agent** | BNPL risk scoring | TickPay |
| **TickPay Marketplace Search Agent** | Vendor search and alternatives | TickPay |
| **BlockHub Market Agent** | Price tracking, alerts, crypto insights | BlockHub |
| **Web3 Transaction Agent** | View wallets, analyze transactions | BlockHub |
| **LifeX Lifestyle Mapping Agent** | Health, stress, habits | LifeX |
| **Life Goals Agent** | Plans → fitness, savings, personal | LifeX |

These agents contain **expert prompts**, **domain knowledge**, and **strict guardrails**.

---

# **B. Orchestration Agents (Intelligence Routing Layer)**

These agents control how AI flows internally.

| Agent | Role |
| --- | --- |
| **Routing Agent** | Decides which agent(s) should answer a query |
| **Task Planning Agent** | Breaks big tasks into steps (multi-step reasoning) |
| **Data Retrieval Agent** | Pulls backend data via APIs |
| **Computation Agent** | Performs calculations, scoring, forecasts |
| **Compliance Guard Agent** | Ensures regulations (financial, BNPL, crypto) are followed |
| **Response Compiler** | Merges outputs from multiple agents into a single answer |

These are the true “brainstem” of Panther.

---

# **C. Utility Agents (Supporting Tools)**

| Agent | Usage |
| --- | --- |
| **Memory & Context Agent** | Stores short-term session context |
| **Notification Writer Agent** | Generates summary messages |
| **Insight Generator Agent** | Converts raw numbers into readable insights |
| **Product Search Agent** | Fetch catalog data from APIs |
| **Summarization Agent** | Converts long data → readable brief |
| **Document Generation Agent** | Creates reports, budget docs, summaries |
| **Fallback Safety Agent** | Handles unrecognized or dangerous queries |

---

# **4. The Universal Agent Workflow**

Every request follows this flow:

```
User Query
    │
    ▼
Routing Agent → “Which domain is this?”
    │
    ▼
Correct Domain Agent Activated
    │
    ▼
Data Retrieval Agent → pulls user data (securely)
    │
    ▼
Domain Agent Processes Data
    │
    ▼
Computation Agent → numbers → insights
    │
    ▼
Compliance Agent → checks rules
    │
    ▼
Response Compiler → formats message
    │
    ▼
Kevin / App UI → final output

```

This pipeline ensures:

✔ precision

✔ safety

✔ personalization

✔ speed

✔ auditability

---

# **5. Domain-by-Domain Breakdown**

---

# **A. Banking Domain**

Agents:

- Banking Analyst Agent
- Predictive Finance Agent
- Fraud Agent

Capabilities Include:

- balance forecasts
- budgeting
- fee detection
- overspending alerts
- salary prediction
- merchant pattern recognition
- financial health scoring

---

# **B. TickPay (BNPL Domain)**

Agents:

- Affordability Risk Agent
- BNPL Planner Agent
- Marketplace Search Agent

Capabilities:

- max purchase allowed
- repayment schedule
- stress budget test
- vendor price comparison
- cheaper alternative search
- BNPL eligibility scoring

---

# **C. BlockHub (Crypto Domain)**

Agents:

- Market Analyst Agent
- Wallet Analysis Agent

Capabilities:

- asset summary
- portfolio insights
- volatility warnings
- real-time market info
- price triggers
- risk flags
- exchange routing

---

# **D. Marketplace Domain**

Agents:

- Product Search Agent
- Product Recommendation Agent

Capabilities:

- product lookup
- price comparison
- BNPL compatibility check
- “affordable options” search
- Amazon/Shopify vendor API integration

---

# **E. LifeX Domain**

Agents:

- Lifestyle Mapping Agent
- Personal Goals Agent

Capabilities:

- mood + behavior mapping
- spending vs lifestyle correlation
- financial wellness scoring
- personal habit insights
- life plans (fitness, savings, personal growth)

---

# **6. ICT Integration (Internal Chronos Tools)**

Panther agents interact with:

### ✔ Chronos Banking APIs

### ✔ TickPay APIs

### ✔ BlockHub APIs

### ✔ Market APIs

### ✔ LifeX APIs

### ✔ Notifications backend

### ✔ User profile

### ✔ Ledger + card system

### ✔ Transaction system

This gives Panther **full intelligence context** across the whole OS.

---

# **7. Panther’s Data Flow (Security-Focused)**

1. Panther requests only data that backend provides
2. Backend verifies permissions
3. Backend returns tokenized + structured payload
4. Panther processes data in memory (no storage)
5. Outputs recommendation → compiled → UI

Panther **never stores**:

- account numbers
- wallet private keys
- card numbers
- sensitive PII
- login credentials

Everything is ephemeral.

---

# **8. “Kevin” — The Unified AI Interface**

Panther powers Kevin, making him able to:

- analyze finances
- analyze crypto assets
- search markets for products
- recommend BNPL eligibility
- break down lifestyle patterns
- suggest budget adjustments
- explain risks
- warn of issues
- deliver automatic daily/weekly summaries
- give smart suggestions relative to user's situation

Kevin is the **interface**

Panther is the **brain**

Chronos backend is the **memory & data**

---

# **9. End-to-End Example Flow**

**User:** “Can I afford the new iPhone 15 on BNPL?”

### Step 1 — Routing Agent

→ Classifies intent: *TickPay BNPL affordability + product search*

### Step 2 — Marketplace Search Agent

→ Fetches price

→ Finds vendor options

### Step 3 — Data Retrieval Agent

→ Fetches: income, balance, BNPL history, obligations

### Step 4 — Risk Agent

→ Computes BNPL risk score

### Step 5 — Computation Agent

→ Determines affordability

→ Predicts next 3 months balance

### Step 6 — Compliance Guard

→ Ensures advice follows BNPL regulations

### Step 7 — Response Compiler

→ Generates clear final message

### Step 8 — Kevin responds

---

# **10. What the AI Engineer Must Build**

### **Milestone 1 — Full Agent Framework**

- Routing agent
- Domain agent scaffolding
- API adapters
- Compliance guard
- Response compiler

### **Milestone 2 — Banking Agents**

- Analyst
- Predictor
- Fraud detection heuristics

### **Milestone 3 — TickPay AI**

- affordability engine
- product search agent
- BNPL scoring

### **Milestone 4 — BlockHub AI**

- portfolio AI
- market insights
- risk flags

### **Milestone 5 — LifeX**

- lifestyle classifier
- personal plans AI

### **Milestone 6 — Kevin Integration**

- unified chat
- multi-agent reasoning
- message-level routing

---

# **11. Summary**

The Panther Global Agent Framework is the **central nervous system** of Chronos.

It:

- orchestrates all AI decision-making
- powers every subsystem
- maintains safety + compliance
- pulls correct data from backend
- transforms raw data → intelligent personalized insights
- powers Kevin and all automation features
