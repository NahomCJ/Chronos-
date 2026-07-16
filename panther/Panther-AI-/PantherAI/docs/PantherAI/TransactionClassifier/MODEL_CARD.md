# Model Card — Tier 2 DistilBERT Classifier

## Overview
Semantic classification layer using fine-tuned **DistilBERT**. Second stage in the 3-tier waterfall pipeline. Handles transaction descriptions that Tier 1 Regex doesn't match.

## Files Created/Modified

| File | Type | Purpose |
|------|------|---------|
| [classifier/tier2_bert.py](../../PantherAI/TC-TransactionClassifier/classifier/tier2_bert.py) | [NEW] | Core implementation of the `BertClassifier` class. |
| [tests/test_tier2_bert.py](../../PantherAI/TC-TransactionClassifier/tests/test_tier2_bert.py) | [NEW] | Verification script for testing classification logic and performance. |
| [BACKLOG.md](./BACKLOG.md) | [MODIFY] | Updated task status to COMPLETED. |

## Implementation Logic

### 1. Text Normalization
To ensure high accuracy, the input text undergoes the exact same preprocessing used during model training:
- **Case Normalization**: Converted to `UPPERCASE`.
- **Noise Removal**:
    - Hashtags and following characters (e.g., `#1234`) are removed.
    - Transaction prefixes (e.g., `TXN...`) are removed.
- **Digit Stripping**: Sequences of digits are replaced with single spaces to force the model to focus on merchant names rather than transaction IDs.
- **Whitespace Cleaning**: Multiple spaces are collapsed into one.

### 2. Inference Pipeline
- **Tokenization**: Uses `DistilBertTokenizerFast` with a fixed `max_length` of 64 tokens.
- **Device Support**:
    - Automatically detects and uses **MacOS MPS (Metal Performance Shaders)** for GPU acceleration.
    - Falls back to **CUDA** or **CPU** if MPS is unavailable.
- **Confidence Scoring**: Applies `softmax` to the output logits to obtain a probability distribution. The top class is returned along with its probability as a confidence score (0.0 - 1.0).

### 3. Error Handling & Fallback
- **Empty Inputs**: Returns `sub_general_misc` with 0.0 confidence.
- **Runtime Errors**: Gracefully catches exceptions during inference and returns a "General" classification to prevent pipeline crashes.
- **Label Mapping**: Corrected a mapping issue where `id2label` expected integer keys instead of strings, ensuring accurate subcategory extraction.

## Model Loading

The model path is resolved in this order:
1. Explicit `model_path` argument passed to `BertClassifier()`
2. `PANTHER_MODEL_PATH` environment variable
3. Default: `models/distilbert_v1_colab/` (relative to `classifier/` directory)

## Rationale
- **Why DistilBERT over XGBoost/FastText?** Semantic context. XGBoost and FastText can't distinguish "Uber" (ride) from "Uber Eats" (food). DistilBERT can.
- **Why Tier 2, not Tier 1?** BERT is slower than Regex (~15-30ms vs ~1ms). By running it only on Regex misses, average latency stays low while coverage goes up.
