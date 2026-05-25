# QUICK RECAP

## BACKEND CORE INTELLIGENCE

├── ✅ **Risk Assessment Service**
│   └── `assess_payment_risk(user_id, amount) → warning`
│
├── ✅ **BNPL Risk Scoring Service**
│   └── `calculate_bnpl_risk_score(user_id, amount, num_payments) → score 0-100`
│
├── ✅ **Transaction Categorization (Classifier)**
│   ├── Tier 1: Regex (700+ patterns)
│   ├── Tier 2: DistilBERT (99.97% accuracy)
│   └── Tier 3: LLM queue (planned)
│
├── ✅ **Kevin Chat (Conversational AI)**
│   ├── Claude/Qwen API wrapper
│   ├── `POST /api/kevin/chat` endpoint
│   └── Affordability intent detection
│
└── ✅ **Plaid Sandbox Integration**
    ├── `POST /api/plaid/create-link-token`
    ├── `POST /api/plaid/exchange-token`
    ├── `get_balance() → Plaid API`
    └── `get_transactions() → Plaid API`

❌ **BLOCKED**
**Payment Authorization Service**
└── Cannot be completed without BaaS (Banking-as-a-Service)
    ├── Reason: We currently have no way to intercept real payments
    └── Temporary Solution: Mock flow for Demo

---

# THIS SPRINT 2

## Thom

└── **Transaction Categorization Integration**
    │
    ├── 1. Backend Integration
    │   └── Connect classifier to the transactions endpoint
    │
    ├── 2. Plaid Webhook Handler
    │   └── Auto-categorize when Plaid sends a new transaction
    │
    └── 3. Transactions API
        ├── `GET /api/transactions?user_id=X`
        ├── `GET /api/transactions/:id`
        └── `PATCH /api/transactions/:id` (user corrections)

### DELIVERABLES GUIDE:

- [ ] `services/transaction_categorization/categorizer.py` integrated
- [ ] `POST /webhooks/plaid/transactions` endpoint
  - Receives Plaid webhook
  - Auto-categorizes the transaction
  - Saves to DB
- [ ] `GET /api/transactions` endpoint
  - Returns transactions with categories
  - Filters: date range, category, merchant
- [ ] `PATCH /api/transactions/:id` endpoint
  - User can correct the category
  - Feedback loop to improve classifier
- [ ] Script: `scripts/backfill_categories.py`
  - Categorizes existing transactions
- [ ] Tests for webhook + endpoints

**Definition of Done (DoD):**
- [ ] I can call `GET /api/transactions` and see categorized transactions.
- [ ] Plaid webhook receives new transactions and categorizes them automatically.
- [ ] I can correct a category via `PATCH /api/transactions/:id`.
- [ ] Script `scripts/backfill_categories.py` categorizes existing transactions successfully.

---

## Martín

└── **Dashboard Insights API**
    ├── `GET /api/insights/spending-summary`
    │   └── Total spending + breakdown by category
    │
    ├── `GET /api/insights/top-categories`
    │   └── Top 5 categories from the last 30 days
    │
    └── `GET /api/insights/warnings-history`
        └── History of displayed warnings

### DELIVERABLES:
- [ ] `routers/insights.py`
- [ ] `GET /api/insights/spending-summary?user_id=X&month=2&year=2025`
- [ ] `GET /api/insights/top-categories?user_id=X&days=30`
- [ ] `GET /api/insights/warnings-history?user_id=X&limit=10`
- [ ] Tests for each endpoint (minimum 3 test cases each)

└── **Kevin Chat Improvements**
    └── Comprehensive testing with Promptfoo
        ├── Test affordability questions
        ├── Test warning explanations
        └── Test edge cases (no amount detected, ambiguous)

### DELIVERABLES:
- [ ] Promptfoo test suite configured
- [ ] 10+ test cases covering:
  - Affordability checks ("Can I afford $500?")
  - Warning explanations ("Why did you warn me?")
  - Balance questions ("How much do I have?")
  - Edge cases (ambiguous amounts, unclear intent)
- [ ] Documentation: How to run Kevin tests