MARTÍN (AI + Conversational)
└── Kevin Chat
    ├── Qwen/Qwen3.5-397B-A17B API wrapper: https://huggingface.co/Qwen/Qwen3.5-397B-A17B
    ├── POST /api/kevin/chat endpoint
    ├──      (balance, bills, warnings)
    └── Intent detection (affordability checks)

Guide DELIVERABLES:
services/conversational_ai/kevin.py (main chat function)
services/conversational_ai/nlp_utils.py (amount extraction, intent detection)
POST /api/kevin/chat endpoint
Tests para affordability questions, warning explanations, general chat
Conversation history storage ??

---
THOM (Banking Integration)
└── Plaid Sandbox Integration
    ├── Setup Plaid credentials - [text](https://dashboard.plaid.com/signup)
    ├── POST /api/plaid/create-link-token
    ├── POST /api/plaid/exchange-token
    ├── Replace get_balance() mock → Plaid API
    └── Replace get_transactions() mock → Plaid API

DELIVERABLES GUIDE (do it as you feel):
Plaid account setup + credentials in .env
services/banking/plaid_client.py (Plaid SDK setup)
POST /api/plaid/create-link-token endpoint
POST /api/plaid/exchange-token endpoint
get_balance() using Plaid API (replace mock)
get_transactions() using Plaid API (replace mock)
scripts/sync_plaid_transactions.py (sync script)
Schema update: add plaid_tokens table ??? or whatever

---
FUTURE (Backend + Data)
├── Transaction Categorization Integration
│   ├── Conectar tu classifier al backend
│   ├── Webhook de Plaid para nuevas transacciones
│   └── Endpoint GET /transactions con categorías
│
└── Dashboard Insights Backend
    ├── GET /api/insights/spending-summary
    ├── GET /api/insights/warnings-history
    └── GET /api/insights/top-categories