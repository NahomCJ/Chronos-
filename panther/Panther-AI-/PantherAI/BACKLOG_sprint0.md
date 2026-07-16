# CHRONOS MVP SPRINT 0 BACKLOG
BACKEND (FastAPI + Supabase)
├── Setup infrastructure
├── Mock APIs
├── Risk Assessment Service
├── BNPL Risk Scoring
├── Payment Authorization
└── Kevin Chat

Total Estimated Sprint Time: ~21-30 hours

## Dependency Mapping

```text
USER ACTION
       ↓
MAHI: FastAPI Setup
       ↓
    ┌──┴──────┐
    ↓         ↓
MARTÍN:     MARTÍN:
Risk        BNPL
Assessment  Scoring
    ↓         ↓
    └──┬──────┘
       ↓
THOM: Supabase Setup & Mock APIs
       ↓
MAHI: Payment Authorization API
```

| Person | Can start immediately | Unblocked when |
|--------|----------------------|----------------|
| Mahi   | ✅ Yes (FastAPI Setup)| Martín and Thom finish (for Endpoint) |
| Martín | ✅ Yes (with mocks)   | Thom finishes Mock APIs |
| Thom   | ✅ Yes               | -              |

---

### 🧠 MARTÍN - THE BRAIN THAT DECIDES RISK (4h)
**Your Role:** Determine if a user's action or current state is financially risky before proceeding.

#### TASK 1: Risk Assessment Service (2.5h)

**What to build:**
A function that answers: "If this user pays X now, will this affect their upcoming rent or bills?"

**Why it matters:**
This is the core protective layer of Chronos. We must prevent users from spending money they need for essential upcoming bills like rent.

**Input:**
```python
assess_payment_risk(user_id="user_marcus", amount=200.00)
```

**Expected Output:**
```python
{
    "is_risky": True,
    "risk_level": "HIGH",  # ENUM: HIGH | MEDIUM | LOW
    "warning_message": "⚠️ Your rent of $1,500 is due in 3 days. This will leave you with -$100.",
    "projected_balance": -100.00
}
```

**Algorithm / Logic hints (if applicable):**
- Projected balance = Current balance - Sum(upcoming bills) - Payment amount
- If projected < 0: HIGH risk
- If projected < 100: MEDIUM risk
- Else: LOW risk

**Phase progression:**
```python
# Phase 1: Work alone with local mocks
MOCK_DATA = {
    "user_marcus": {"balance": 1600, "bills": [{"name": "Rent", "amount": 1500, "due_in_days": 3}]},
    "user_sarah": {"balance": 5000, "bills": [{"name": "Rent", "amount": 1200, "due_in_days": 15}]},
}

def assess_payment_risk(user_id: str, amount: float):
    # implement with local data MOCK_DATA
    pass

# Phase 2: When THOM finishes Mock APIs
from services.banking.mock_api import get_balance, get_upcoming_bills

def assess_payment_risk(user_id: str, amount: float):
    balance = get_balance(user_id)
    bills = get_upcoming_bills(user_id)
    # same logic, using real API responses
    pass
```

**Deliverable:**
- File: `services/risk_assessment/risk_assessment.py`
- 3 tests: covers high risk, medium risk, and low risk scenarios.

**Done when:**
- [x] All 3 tests pass. (Wrote 4 tests, covering all edge cases!)
- [x] Mahi can import `assess_payment_risk` and use the output for the Payment Authorization API without errors.
- [x] Edge case where `amount` is higher than `balance` returns `HIGH` risk instantly.

---

#### TASK 2: BNPL Risk Scoring (1.5h)

**What to build:**
A scoring mechanism (0-100) that answers: "Is taking on this new BNPL manageable for this specific user?"

**Why it matters:**
This differentiates Chronos from simple budget trackers. We contextualize new debt against their unique affordability and historical behavior, preventing them from falling into debt traps.

**Input:**
```python
calculate_bnpl_risk_score(user_id="user_marcus", amount=200.00, num_payments=4)
```

**Expected Output:**
```python
{
    "score": 45,  # Range 0-100
    "risk_level": "MEDIUM",  # ENUM: LOW (70+) | MEDIUM (40-69) | HIGH (0-39)
    "risk_factors": ["Payment 3 may be tight", "You have 2 active BNPLs"],
    "recommendation": "⚠️ Proceed carefully"
}
```

**Algorithm / Logic hints (if applicable):**
- 70% weight: Affordability (projected monthly cashflow over `num_payments` months).
- 30% weight: Behavior (number of active BNPLs, any past late payments).

**Phase progression:**
```python
# Phase 1: Work alone with local mocks
MOCK_USER_DATA = { "user_marcus": { "active_bnpls": 2, "late_payments": 0 } }
def calculate_bnpl_risk_score(user_id: str, amount: float, num_payments: int):
    # implement using local mocks
    pass

# Phase 2: When THOM finishes Data Infrastructure
from services.banking.mock_api import get_active_bnpls, get_late_payments

def calculate_bnpl_risk_score(user_id: str, amount: float, num_payments: int):
    # same logic, real data source
    pass
```

**Deliverable:**
- File: `services/bnpl_risk_scoring/bnpl_risk_scoring.py`
- 3 tests: covers >70 score, 40-70 score, <40 score cases.

**Done when:**
- [x] All 3 tests pass.
- [x] Algorithm correctly weighs active BNPLs against the new requested amount.
- [x] Output can be cleanly consumed by Mahi's Payment Authorization API.

---

### 🗄️ THOM - THE SOURCE OF TRUTH (3h)
**Your Role:** Provide the raw mock data and infrastructure that the brain (Martín) uses to make decisions. You unblock the whole team.

#### TASK 1: Supabase Setup (1.5h)

**What to build:**
A working database seed and schema setup with 3 demo users.

**Why it matters:**
Without real interconnected data tables, Martín and Mahi can only work with localized mocks. Your work ensures the system behaves like a real banking environment.

**Input:**
```bash
python seed_mock_data.py
```

**Expected Output:**
Database populated with:
- Marcus (high risk): $1,600, rent $1,500 in 3 days, 2 active BNPLs.
- Sarah (low risk): $5,000, rent $1,200 in 15 days, 0 BNPLs.
- Bob (medium risk): $2,200, rent $1,400 in 7 days + car payment $300.

**Deliverable:**
- Supabase project with deployed schema.
- File: `scripts/seed_mock_data.py`.
- Schema defines: `users`, `accounts`, `bills`, `bnpls`, `transactions`.

**Done when:**
- [ ] Executing `seed_mock_data.py` populates the DB without errors.
- [ ] Tables are properly linked via foreign keys (e.g., `user_id`).

---

#### TASK 2: Mock APIs (1.5h)

**What to build:**
Three getter functions that act as the interface between the database and the risk modules.

**Why it matters:**
These functions are the "contract" between your infrastructure and Martín's logic. Clean abstractions here mean Martín never has to write a single SQL query.

**Input:**
```python
get_balance("user_marcus")
get_upcoming_bills("user_marcus", days_ahead=7)
count_active_bnpls("user_marcus")
```

**Expected Output:**
```python
# get_balance
1600.00

# get_upcoming_bills
[{"name": "Rent", "amount": 1500, "due_in_days": 3}]

# count_active_bnpls
2
```

**Phase progression:**
```python
# Phase 1: Local hardcoded dictionary
LOCAL_MOCK_DATA = { ... }
def get_balance(user_id: str):
    return LOCAL_MOCK_DATA[user_id]["balance"]

# Phase 2: When TASK 1 (Supabase Setup) is finished
from supabase import create_client
def get_balance(user_id: str):
    # fetch from supabase
    pass
```

**Deliverable:**
- File: `services/banking/mock_api.py`
- 1 test script verifying all 3 functions work for all 3 seeded users.

**Done when:**
- [ ] Test script passes against all 3 users.
- [ ] Martín can import and use these inside the Risk components successfully.

---

### 🔗 MAHI - THE ORCHESTRATOR (3h)
**Your Role:** Connect all the backend services and expose them via a clean API for the mobile app to consume.

#### TASK 1: FastAPI Setup (1h)

**What to build:**
The core FastAPI application running locally with a health check.

**Why it matters:**
Without this, there is no gateway for the mobile app (Phase 2). This serves as the foundation for the entire backend interface.

**Input:**
```bash
uvicorn main:app --reload
```

**Expected Output:**
```json
// GET /health
{
    "status": "ok"
}
```

**Deliverable:**
- File: `main.py` configuring FastAPI.
- `/health` endpoint and Swagger docs generated at `/docs`.

**Done when:**
- [ ] Server boots up without errors.
- [ ] `curl localhost:8000/health` returns `{"status": "ok"}`.

---

#### TASK 2: Payment Authorization Endpoint (2h)

**What to build:**
A single unified API endpoint that calls both Risk Assessment and BNPL Scoring to authorize a payment.

**Why it matters:**
This is the final, consumed product. The mobile app relies entirely on this endpoint to decide whether to block or allow a user's action.

**Input:**
```http
POST /api/authorize-payment

{
  "user_id": "user_marcus",
  "amount": 200.00,
  "merchant": "AMAZON",
  "payment_type": "bnpl",
  "num_payments": 4
}
```

**Expected Output:**
```json
{
  "authorization_id": "uuid-123",
  "status": "pending",
  "warning": {
    "cash_flow": {
      "risk_level": "HIGH",
      "warning_message": "⚠️ Rent due in 3 days. This will leave you with -$100."
    },
    "bnpl": {
      "score": 45,
      "risk_level": "MEDIUM"
    },
    "combined_message": "⚠️ WARNING\nRent due in 3 days.\n\nBNPL Risk: 45/100"
  }
}
```

**Phase progression:**
```python
# Phase 1: Work alone with mock responses
def assess_payment_risk_mock(user_id, amount):
    return {"risk_level": "HIGH", "warning_message": "Mock warning"}

@app.post("/api/authorize-payment")
def authorize_payment(request):
    risk = assess_payment_risk_mock(request.user_id, request.amount)
    return {"warning": {"cash_flow": risk}}

# Phase 2: When MARTÍN finishes Risk Assessment and BNPL Scoring
from services.risk_assessment.risk_assessment import assess_payment_risk
from services.bnpl_risk_scoring.bnpl_risk_scoring import calculate_bnpl_risk_score

@app.post("/api/authorize-payment")
def authorize_payment(request):
    cash_flow_risk = assess_payment_risk(request.user_id, request.amount)
    bnpl_risk = calculate_bnpl_risk_score(request.user_id, request.amount, request.num_payments)
    # combine and return
```

**Deliverable:**
- File: `routers/payment_authorization/router.py`
- 3 test cases simulating requests for High, Medium, and Low risk users.

**Done when:**
- [ ] All 3 endpoint tests pass.
- [ ] Successfully integrates real functions from Martín without errors.
- [ ] The `combined_message` is properly formatted for the frontend to display directly.

---

## Integration Checklist

- [ ] Supabase seed data correctly loaded.
- [ ] `mock_api.py` fetches real data from Supabase.
- [ ] Risk Assessment correctly utilizes `mock_api.py`.
- [ ] BNPL Scoring correctly utilizes `mock_api.py`.
- [ ] Payment Authorization Endpoint successfully imports and calls both Risk modules.
- [ ] End-to-end test from `/api/authorize-payment` returns appropriate warnings based on seeded DB state.
