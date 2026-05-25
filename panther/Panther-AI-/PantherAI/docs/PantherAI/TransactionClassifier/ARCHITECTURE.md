# Transaction Classifier — Pipeline Architecture

**Version**: 1.1
**Date**: 2026-02-06
**Status**: Phase 1 Complete | Phase 2 (API) In Progress

---

## Overview

3-tier cascading pipeline. Each tier is faster and cheaper than the next. A transaction only falls through if the current tier can't handle it.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    TRANSACTION INPUT                                    │
│                 "DOORDASH #1234 NEW YORK NY"                           │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  TIER 0: CACHE  [PLANNED]                  Latency: ~0.1ms            │
│  LRU cache of recently classified transactions                         │
│  Hit → Return immediately                                              │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ▼ Miss
┌─────────────────────────────────────────────────────────────────────────┐
│  TIER 1: REGEX CLASSIFIER  [LIVE]          Latency: ~1ms              │
│  classifier/regex_dictionary.py (700+ patterns)                        │
│  Match → Return with 100% confidence                                   │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ▼ No Match
┌─────────────────────────────────────────────────────────────────────────┐
│  TIER 2: DISTILBERT  [LIVE]                Latency: ~15-30ms          │
│  Fine-tuned on panther_ground_truth_v3                                 │
│  Confidence threshold: conf >= 0.6                                     │
│  High confidence → Return prediction                                   │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ▼ Low Confidence
┌─────────────────────────────────────────────────────────────────────────┐
│  TIER 3: RARE QUEUE + GEMMA3:4B  [PLANNED] Async Batch Processing     │
│  Queue accumulates until N=100 rare transactions                       │
│  Gemma analyzes patterns → Human reviews → New regex patterns          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Tier Details

### Tier 0: Cache Layer [PLANNED]

| Property | Value |
|----------|-------|
| Type | LRU Cache (in-memory) |
| Size | 10,000 entries |
| Key | MD5 hash of normalized description |
| TTL | 24 hours |
| Expected Hit Rate | 30-40% (users repeat merchants) |

> Not yet implemented. Will be added as a wrapper around `pipeline.predict()`.

### Tier 1: Regex Classifier [LIVE]

| Property | Value |
|----------|-------|
| Source | `classifier/regex_dictionary.py` |
| Patterns | 700+ merchant patterns (dict) + keyword rules |
| Strategy | Mega-Regex compilation — all patterns compiled into a single regex per type. First match wins via `re.search()`. |
| Priority | Merchant dict (exact) > Keyword rules (generic) |
| Confidence | 100% (deterministic) |
| Expected Coverage | 80-85% of real-world transactions |

**How Mega-Regex works**: Contiguous patterns mapping to the same subcategory are grouped into a single capture group. The entire dictionary becomes one compiled `re.compile()` call. This gives O(1) lookup relative to dictionary size.

### Tier 2: DistilBERT [LIVE]

| Property | Value |
|----------|-------|
| Model | `distilbert-base-uncased` |
| Fine-tuning | On balanced dataset (~895K records) |
| Training Env | Google Colab (T4 GPU) |
| Output | 44 class probabilities (softmax) |
| Performance | **99.97% Accuracy** on balanced test set |
| Metrics | [Evaluation Report](../../PantherAI/TC-TransactionClassifier/audit/per_class_metrics.csv) |
| Threshold | `conf >= 0.6` (simple threshold on top-1 softmax probability) |
| Expected Coverage | 12-17% of transactions (after Tier 1) |
| Fallback | Returns prediction with source `"Low Confidence"` if below threshold |
| Model Path | Resolved via `PANTHER_MODEL_PATH` env var or default `models/distilbert_v1_colab/` |

### Evaluation Protocol
- **Split**: Train/validation/test from balanced v3 dataset
- **Test Set**: Held-out portion of balanced data
- **Metric Context**: 99.97% reflects balanced test data, not real-world class distribution
- **Last Eval**: 2026-02-05

### Tier 3: Gemma3:4B Batch Processor [PLANNED]

| Property | Value |
|----------|-------|
| Model | `gemma3:4b` via Ollama (local) |
| Trigger | When queue reaches 100 transactions |
| Mode | Async batch (not real-time) |
| Output | Proposed new regex patterns |
| Human Review | Required before merging |

> Not yet implemented. Currently, low-confidence predictions are returned with `source: "Low Confidence"` — no queue exists yet.

---

## Dataset Balancing Strategy

### Ground Truth (v3)
- Total: 1,002,440 records
- Largest class: `sub_restaurants_bars` (113K)
- Smallest class: `sub_education` (2.9K)
- Imbalance ratio: 39:1

### Balanced Dataset
```
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: Undersample (classes >50K → ~30K)                 │
│  - Stratified sampling to preserve diversity                │
│  - Applied to: restaurants, internet_phone, medical_pharmacy│
└─────────────────────────────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: Oversample (classes <10K → ~15K)                  │
│  - Synthetic data via templates + synonyms                  │
│  - Applied to: education, holidays_trips, insurance, etc.  │
└─────────────────────────────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  RESULT: ~15-30K per class                                 │
│  Total: ~800K balanced records                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Confidence Threshold Strategy

### Current Implementation (conf >= 0.6)

The pipeline uses a simple softmax threshold. If the top-1 probability is >= 0.6, the prediction is accepted. Otherwise it's returned with a `"Low Confidence"` flag.

```python
# pipeline.py — actual logic
if model_conf >= self.confidence_threshold:  # default: 0.6
    return {"subcategory": model_sub, "confidence": model_conf, "source": "Model"}
else:
    return {"subcategory": model_sub, "confidence": model_conf, "source": "Low Confidence"}
```

### Future Improvement: Margin-Based Confidence

> **NOTE**: This is NOT yet implemented. Documented here as a planned upgrade.

Instead of a fixed threshold, use the **margin** between the top-2 predictions:

```python
def is_confident(probabilities):
    sorted_probs = sorted(probabilities, reverse=True)
    margin = sorted_probs[0] - sorted_probs[1]  # top1 - top2
    return margin > 0.3
```

**Why margin is better for 44-class multiclass:**
- 60% vs 30% (margin=0.3) = confident. The model clearly prefers one class.
- 35% vs 33% vs 32% (margin=0.02) = uncertain. The model is guessing.
- A fixed threshold misses this nuance.

---

## Feedback Loop (Tier 3) [PLANNED]

```
┌─────────────────────────────────────────────────────────────┐
│  RARE_TRANSACTIONS_QUEUE                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {                                                   │   │
│  │    "id": "txn_abc123",                              │   │
│  │    "description": "UNKNOWN MERCHANT XYZ",           │   │
│  │    "bert_top3": [                                   │   │
│  │      {"subcat": "sub_shopping", "conf": 0.25},     │   │
│  │      {"subcat": "sub_groceries", "conf": 0.22},    │   │
│  │      {"subcat": "sub_home_general", "conf": 0.18}  │   │
│  │    ],                                               │   │
│  │    "timestamp": "2026-02-03T10:30:00Z"             │   │
│  │  }                                                   │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────────────┬──────────────────────────────┘
                               ▼ When queue.size >= 100
┌─────────────────────────────────────────────────────────────┐
│  GEMMA3:4B BATCH ANALYSIS                                   │
│  Prompt:                                                    │
│  "Analyze these 100 unclassified transactions.             │
│   Identify common merchant patterns and suggest regex      │
│   patterns for classifier/regex_dictionary.py"             │
└──────────────────────────────┬──────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  HUMAN REVIEW                                               │
│  - Validate proposed patterns                               │
│  - Merge approved patterns to regex_dictionary.py          │
│  - Retrain DistilBERT periodically                         │
└─────────────────────────────────────────────────────────────┘
```

---

## File Structure (Actual)

```
PantherAI/TC-TransactionClassifier/
├── classifier/
│   ├── __init__.py
│   ├── taxonomy.py             # 14 categories, 44 subcategories (v1.2.0)
│   ├── regex_dictionary.py     # Tier 1: 700+ merchant patterns + keyword rules
│   ├── pipeline.py             # Orchestrator: Tier 1 → Tier 2 → fallback
│   ├── tier1_regex.py          # Mega-Regex compiler and matcher
│   └── tier2_bert.py           # DistilBERT inference + text normalization
├── models/
│   └── distilbert_v1_colab/    # Trained model + tokenizer artifacts
├── scripts/
│   ├── train_distilbert.py
│   ├── evaluate_distilbert.py
│   ├── balance_dataset.py
│   ├── generate_synthetic_transactions.py
│   ├── measure_regex_coverage.py
│   └── relabel_with_regex_dictionary.py
├── tests/
│   ├── test_pipeline_integration.py
│   └── test_tier2_bert.py
├── notebooks/
│   └── Train_DistilBERT_Colab.ipynb
└── audit/
    ├── per_class_metrics.csv
    └── failure_cases_v1.csv
```

**Not yet created** (planned for Tier 0 and Tier 3):
- `tier0_cache.py` — LRU cache wrapper
- `tier3_queue.py` — Rare transaction queue
- `batch_analyze_rare.py` — Gemma batch processor

---

## Metrics to Track

| Metric | Target | Status |
|--------|--------|--------|
| Tier 1 Hit Rate | >80% on unseen data | Validated on ground truth |
| Tier 2 Accuracy | >90% (on confident predictions) | 99.97% on balanced test |
| Tier 3 Queue Rate | <5% | Not yet measured |
| End-to-end Latency (P95) | <50ms | Not yet benchmarked |
| Feedback Loop Cycle | Weekly | Not yet active |

---

**Next Steps**: See [BACKLOG.md](./BACKLOG.md) for implementation tasks.
