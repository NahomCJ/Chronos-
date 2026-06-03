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
│  TIER 0: CACHE  [LIVE]                     Latency: ~0.1ms            │
│  LRU+TTL cache of normalized merchant strings                          │
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
│  Confidence threshold: top1 - top2 > 0.3                               │
│  High confidence → Return prediction                                   │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ▼ Low Confidence
┌─────────────────────────────────────────────────────────────────────────┐
│  TIER 3: CLAUDE QUEUE  [LIVE]             Async Batch Processing      │
│  Low-confidence transactions queue after DB write                      │
│  Claude classifies sanitized text → DB record updated                  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Tier Details

### Tier 0: Cache Layer [LIVE]

| Property | Value |
|----------|-------|
| Type | LRU Cache (in-memory) |
| Size | 10,000 entries |
| Key | Normalized merchant string |
| TTL | 24 hours |
| Expected Hit Rate | 30-40% (users repeat merchants) |

Implemented in `services/TC-TransactionClassifier/classifier/tier0_cache.py`.
Cache hits return before regex or DistilBERT and emit a `tier0_cache_hit`
log line; misses emit `tier0_cache_miss`.

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
| Threshold | `top1 - top2 > 0.3` (margin between the two highest softmax probabilities) |
| Expected Coverage | 12-17% of transactions (after Tier 1) |
| Fallback | Returns prediction with source `"Low Confidence"` if below threshold |
| Model Path | Resolved via `PANTHER_MODEL_PATH` env var or default `models/distilbert_v1_colab/` |

### Evaluation Protocol
- **Split**: Train/validation/test from balanced v3 dataset
- **Test Set**: Held-out portion of balanced data
- **Metric Context**: 99.97% reflects balanced test data, not real-world class distribution
- **Last Eval**: 2026-02-05

### Tier 3: Claude Batch Processor [LIVE]

| Property | Value |
|----------|-------|
| Model | `claude-opus-4-6` via Anthropic SDK |
| Trigger | DistilBERT result fails the margin threshold |
| Mode | Async batch; main classifier path does not block |
| Output | Final subcategory label written back to `transactions` |
| Prompt safety | Sanitized transaction text + `user_id` only; no balances, account numbers, names, or confidence internals |
| Prompt caching | System prompt uses `cache_control: {"type": "ephemeral"}` |

Implemented in `services/TC-TransactionClassifier/classifier/tier3_queue.py`.
The prompt sends only `index`, `user_id`, and sanitized `description`; local
transaction IDs are never sent to Claude and are used only for DB updates.

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

### Current Implementation (Margin > 0.3)

The pipeline accepts a DistilBERT prediction only when the top-1 softmax
probability beats the top-2 probability by more than 0.3. Otherwise it returns
a `"Low Confidence"` source and queues the persisted transaction for Tier 3
when `transaction_id` and `user_id` are provided.

```python
# pipeline.py — actual logic
if is_confident(raw_probabilities):  # top1 - top2 > 0.3
    return {"subcategory": model_sub, "confidence": model_conf, "source": "Model"}
else:
    return {"subcategory": model_sub, "confidence": model_conf, "source": "Low Confidence"}
```

**Why margin is better for 44-class multiclass:**
- 60% vs 30% (margin=0.3) = confident. The model clearly prefers one class.
- 35% vs 33% vs 32% (margin=0.02) = uncertain. The model is guessing.
- A fixed threshold misses this nuance.

---

## Feedback Loop (Tier 3)

```
┌─────────────────────────────────────────────────────────────┐
│  LOW_CONFIDENCE_TRANSACTIONS_QUEUE                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {                                                   │   │
│  │    "id": "txn_abc123",                              │   │
│  │    "description": "UNKNOWN MERCHANT XYZ",           │   │
│  │    "user_id": "user_123"                            │   │
│  │    "timestamp": "2026-02-03T10:30:00Z"             │   │
│  │  }                                                   │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────────────┬──────────────────────────────┘
                               ▼ Async batch
┌─────────────────────────────────────────────────────────────┐
│  CLAUDE CLASSIFICATION                                      │
│  Prompt cache: taxonomy + instructions in cached system msg │
│  User msg: [{index, user_id, sanitized description}, ...]   │
└──────────────────────────────┬──────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  DB UPDATE                                                  │
│  - transactions.subcategory = final Claude label            │
│  - transactions.category_source = "Claude"                  │
│  - no confidence internals exposed for Tier 3               │
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
│   ├── tier0_cache.py          # Tier 0: normalized merchant LRU+TTL cache
│   ├── pipeline.py             # Orchestrator: Tier 0 → Tier 1 → Tier 2 → Tier 3
│   ├── tier1_regex.py          # Mega-Regex compiler and matcher
│   ├── tier2_bert.py           # DistilBERT inference + probabilities
│   └── tier3_queue.py          # Claude async fallback queue
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
