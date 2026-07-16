# CHRONOS — Panther AI Engine

## Folder Structure

```
CHRONOS/
├── main.py                   # FastAPI application entry point
├── core/                     # Observability (structured logger, @contract decorator)
├── routers/                  # API routing (payment authorization)
├── services/                 # Panther core services
│   ├── banking/              # Mock banking API (Phase 1 → Supabase Phase 2)
│   ├── risk_assessment/      # Cash-flow risk assessment
│   ├── bnpl_risk_scoring/    # BNPL affordability scoring (0-100)
│   ├── TC-TransactionClassifier/  # 3-tier transaction classifier
│   └── conversational_ai/    # Kevin chat assistant [PLANNED]
├── scripts/                  # Training, evaluation, trace reader, validation
├── tests/                    # Unit and integration tests
├── datasets/                 # Transaction databases and taxonomy
├── docs/                     # Detailed technical documentation
├── .agent/                   # AI agent rules, skills, and workflows
├── tasks/                    # Dev task tracking (todo, lessons)
├── requirements.txt          # Python dependencies
├── CONTRIBUTING.md           # Onboarding guide for new devs
└── CLAUDE.md                 # Project context and golden rules
```

---

## Quick Start

### 1. Replicate Environment
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Run the Server
```bash
uvicorn main:app --reload
# Health check: http://localhost:8000/health
# Swagger UI:   http://localhost:8000/docs
```

---

## Documentation

| Area | Doc |
|------|-----|
| **API Gateway** | [docs/api_gateway/README.md](./docs/api_gateway/README.md) |
| **Payment Authorization** | [docs/PantherAI/payment_authorization/README.md](./docs/PantherAI/payment_authorization/README.md) |
| **Risk Assessment** | [docs/PantherAI/risk_assessment/README.md](./docs/PantherAI/risk_assessment/README.md) |
| **BNPL Risk Scoring** | [docs/PantherAI/bnpl_risk_scoring/README.md](./docs/PantherAI/bnpl_risk_scoring/README.md) |
| **Observability** | [docs/PantherAI/observability/README.md](./docs/PantherAI/observability/README.md) |
| **E2E Validation** | [docs/PantherAI/e2e_validation/README.md](./docs/PantherAI/e2e_validation/README.md) |
| **Transaction Classifier** | [docs/PantherAI/TransactionClassifier/README.md](./docs/PantherAI/TransactionClassifier/README.md) |
| TC Architecture | [docs/PantherAI/TransactionClassifier/ARCHITECTURE.md](./docs/PantherAI/TransactionClassifier/ARCHITECTURE.md) |
| TC Model Card | [docs/PantherAI/TransactionClassifier/MODEL_CARD.md](./docs/PantherAI/TransactionClassifier/MODEL_CARD.md) |
| **Pre-commit Standard** | [docs/PRE_COMMIT_STANDARD.md](./docs/PRE_COMMIT_STANDARD.md) |
| **Platform Overview** | [docs/High-level.md](./docs/High-level.md) |
| **Contributing** | [CONTRIBUTING.md](./CONTRIBUTING.md) |

---

# Panther v1.0 | MVP Build | San Francisco 2026
