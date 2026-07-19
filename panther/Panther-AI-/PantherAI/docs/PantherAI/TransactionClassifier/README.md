# Panther Transaction Classifier

> AI-powered transaction categorization for the Chronos fintech platform.
> 3-tier pipeline: Regex (fast) → DistilBERT (smart) → LLM fallback (planned).

---

## Documentation Index

| Document | What it covers |
|----------|----------------|
| **[ARCHITECTURE.md](./ARCHITECTURE.md)** | Pipeline design, tier details, threshold logic, file structure. |
| **[MODEL_CARD.md](./MODEL_CARD.md)** | DistilBERT model: training, inference, normalization, rationale. |
| **[BACKLOG.md](./BACKLOG.md)** | Active sprint and task roadmap. |
| **[reports/PHASE1_BUILD.md](./reports/PHASE1_BUILD.md)** | Phase 1 build history and validation results. |
| **[reports/regex_metrics.md](./reports/regex_metrics.md)** | Tier 1 Regex performance on ground truth dataset. |

---

## Overview

The Transaction Classifier is a core component of **Panther AI**. It categorizes bank transactions into a structured taxonomy using a hybrid approach:

1. **Tier 1 — Regex** (700+ patterns): Deterministic. Handles ~80-85% of transactions at ~1ms.
2. **Tier 2 — DistilBERT**: Semantic classifier for everything Regex misses. 99.97% accuracy on balanced test set.
3. **Tier 3 — LLM batch** (planned): Async queue for rare transactions that neither tier can confidently classify.

### Key Numbers
- **14 categories**, **44 subcategories** (43 active in dataset v3; `sub_general_misc` has no records by design)
- **1,002,440 labeled transactions** (ground truth dataset)
- **700+ merchant patterns** in the regex dictionary
- Designed for **USA bank transaction formats**

---

## Quick Start

### Load the Dataset
```python
import pandas as pd

df = pd.read_parquet('datasets/processed/panther_ground_truth_v3.parquet')
print(f"Records: {len(df):,}")
print(f"Subcategories: {df['subcategory'].nunique()}")
# Output: Records: 1,002,440 | Subcategories: 43
```

### Classify a Transaction
```python
from classifier.pipeline import TransactionClassifierPipeline

pipeline = TransactionClassifierPipeline()
result = pipeline.predict("DOORDASH #1234 NEW YORK NY")
# {"subcategory": "sub_delivery", "confidence": 1.0, "source": "Regex"}
```

---

## Taxonomy

| Category | Subcategories |
|----------|---------------|
| **Food & Drink** | Groceries, Restaurants & Bars, Delivery Services |
| **Transport** | Public Transport, Fuel & Tolls, Taxi & Ride-sharing |
| **Travel** | Flights, Hotels & Accommodation, Travel & Holidays |
| **Health & Wellbeing** | Medical & Pharmacy, Fitness & Gym, Wellness & Beauty, Supplementation |
| **Shopping** | Fashion, Electronics, Home & General |
| **Home & Utilities** | Rent & Mortgage, Utility Bills, Internet & Phone, Maintenance & Decor |
| **Entertainment & Leisure** | Subscriptions, Events & Culture, Hobbies & Gaming |
| **Personal** | Education, Gifts & Donations |
| **Family** | Family & Kids |
| **Pets** | Pets |
| **Financial Services** | Insurance, Taxes & Fees, Investments, Crypto, NFTs, Debt & Loans, Savings, Cash & Transfers |
| **Cash** | ATM Withdrawals |
| **Income** | Salary, Dividends, Cashback, Interest, Refunds, Side Hustle, Other Income |
| **Uncategorized** | General / Miscellaneous |

> `sub_general_misc` is the catch-all for unclassified transactions. Intentionally empty in the ground truth dataset.

Full definition: [classifier/taxonomy.py](../../PantherAI/TC-TransactionClassifier/classifier/taxonomy.py)

---

## Folder Structure

```
CHRONOS/
├── datasets/
│   └── processed/
│       ├── panther_ground_truth_v3.parquet           # Ground truth (1M+)
│       └── panther_ground_truth_v3_balanced.parquet   # Balanced (~800K)
├── PantherAI/TC-TransactionClassifier/
│   ├── classifier/
│   │   ├── taxonomy.py            # Category definitions (v1.2.0)
│   │   ├── regex_dictionary.py    # Tier 1: merchant dict + keyword rules
│   │   ├── pipeline.py            # Orchestrator: Tier 1 → Tier 2 → fallback
│   │   ├── tier1_regex.py         # Mega-Regex compiler
│   │   └── tier2_bert.py          # DistilBERT inference
│   ├── models/
│   │   └── distilbert_v1_colab/   # Trained model artifacts
│   ├── scripts/                   # Training, balancing, evaluation
│   ├── tests/                     # Unit + integration tests
│   ├── notebooks/                 # Colab training notebook
│   └── audit/                     # Per-class metrics, failure cases
└── docs/PantherAI/TransactionClassifier/
    ├── README.md                  # This file
    ├── ARCHITECTURE.md            # Technical design
    ├── MODEL_CARD.md              # Model details
    ├── BACKLOG.md                 # Sprint tracker
    └── reports/                   # Static reports
```

---

## How to Add New Categories

### 1. Update Taxonomy
Edit `classifier/taxonomy.py` — add a new entry inside the parent category's `subcategories` list:
```python
{
    "id": "sub_new_thing",
    "name": "New Thing",
    "description": "What this category covers."
}
```

### 2. Add Merchant Patterns
Edit `classifier/regex_dictionary.py` — add entries to `MERCHANT_DICTIONARY` (it's a `dict`, not a list):
```python
MERCHANT_DICTIONARY = {
    # ... existing patterns ...
    "NEW MERCHANT NAME": "sub_new_thing",
}
```

For regex-based keyword rules, add to `KEYWORD_RULES` instead:
```python
KEYWORD_RULES = {
    "parent_category": {
        "sub_new_thing": [r"PATTERN.*", r"ANOTHER PATTERN"],
    }
}
```

### 3. Retrain (if needed)
If the new category needs semantic coverage beyond regex, retrain DistilBERT with updated labels. See `scripts/train_distilbert.py`.

---

## Related Documentation

- [Panther AI Engine Rules](../../../.agent/rules/CLAUDE.md)
