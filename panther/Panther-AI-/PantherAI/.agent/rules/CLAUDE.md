---
trigger: always_on
---

# CLAUDE.md — Session Context for CHRONOS

## Vision

CHRONOS is a fintech AI platform built around **Panther**, a unified AI engine that turns banking data into autonomous financial intelligence. The MVP targets the San Francisco investor demo — transaction categorization, spending analysis, BNPL risk scoring, and Kevin chat assistant.

---

## Documentation Style: "Hormozi Rules"

Every doc in this project follows brutal clarity. When writing or editing documentation:

- **Short sentences.** If it takes two reads to understand, rewrite it.
- **No filler.** Cut "basically", "essentially", "in order to", "it should be noted that".
- **Lead with the what, then the why.** A new dev should know what something does in the first line. The reasoning comes second.
- **Separate fact from plan.** If something is not implemented, label it `[PLANNED]`. If it's live, label it `[LIVE]`. Never let a reader confuse a design doc with reality.
- **Code examples must compile.** Every snippet in docs must match the actual codebase. No pseudocode unless explicitly labeled.
- **One source of truth.** No duplicate files. If two docs say the same thing, one links to the other.

---

## Stack & Architecture

### Why These Technologies

| Technology | Role | Why this one |
|------------|------|-------------|
| **Python 3.12** | Primary language | ML ecosystem (PyTorch, HuggingFace, pandas). No contest for NLP pipelines. |
| **DistilBERT** | Tier 2 classifier | Semantic understanding that XGBoost/FastText can't do (e.g. "Uber" vs "Uber Eats"). 6x faster than full BERT, good enough for 44-class transaction classification. |
| **Regex Mega-Regex** | Tier 1 classifier | 700+ merchant patterns compiled into a single `re.compile()` call. O(1) lookup, ~1ms, 100% precision on known merchants. Handles 80-85% of real-world traffic before BERT ever loads. |
| **FastAPI** | API layer | Async, fast, Python-native. `lifespan` handler loads the model once at startup. |
| **PyTorch** | ML framework | HuggingFace Transformers runs on it. MPS (Apple Silicon) + CUDA support out of the box. |
| **Parquet** | Dataset format | Columnar, compressed, fast reads. 1M+ records in 16MB. |
| **venv** | Virtual environment | Local `.venv/` at project root. Activate with `source .venv/bin/activate`. All dependencies installed here. |
| **Focal Loss** | Training loss function | Handles class imbalance (39:1 ratio) by down-weighting easy examples. Better than weighted cross-entropy for long-tail distributions. |

### Pipeline Architecture (3-Tier Waterfall)

```
Transaction → Cache [PLANNED] → Regex [LIVE] → DistilBERT [LIVE] → LLM Queue [PLANNED]
```

Each tier is faster and cheaper than the next. A transaction only falls through if the current tier can't handle it. Full details: `docs/PantherAI/TransactionClassifier/ARCHITECTURE.md`.

### Key Design Decisions

1. **Waterfall over ensemble.** We don't run all tiers and vote. We run the cheapest first and stop as soon as one is confident. This keeps average latency under 5ms for 80%+ of traffic.

2. **Simple threshold (conf >= 0.6) over margin-based.** The margin approach (`top1 - top2 > 0.3`) is better in theory for 44-class problems but is NOT yet implemented. Current code uses a simple softmax threshold. See `ARCHITECTURE.md > Confidence Threshold Strategy` for the planned upgrade.

3. **Regex labels the ground truth.** The 1M-record dataset was labeled using the same regex dictionary that powers Tier 1. This means regex metrics on ground truth are circular (99.99%) and do NOT reflect real-world performance. Real-world target: 80-85%.

4. **Balanced dataset for training, not for production.** The 39:1 imbalance was corrected via under/oversampling for training only. The 99.97% accuracy reflects balanced test data. Real-world accuracy will differ.

---

## Golden Rules

### Code
- **Python** for all ML, AI, and backend logic. No exceptions.
- **FastAPI** for all microservice endpoints.
- All model inference must support **MPS (Apple Silicon) → CUDA → CPU** fallback chain.
- Environment variables for all paths and config. Never hardcode model paths.
- Every classifier tier must return `(subcategory_id: str, confidence: float)`.

### Documentation
- **Never delete technical decision explanations.** If a "why" is documented, preserve it. Refactor the wording, not the reasoning.
- **Every doc update must be verified against code.** If the code says `conf >= 0.6`, the doc cannot say `margin > 0.3`.
- Label implementation status: `[LIVE]` / `[PLANNED]` / `[DEPRECATED]`.
- File references in docs must use actual paths. Run a quick check before committing.

### Data & Security
- **Never store PII** in prompts, logs, or intermediate files.
- All API communication: TLS 1.3, JWT tokens.
- Phase 1 = advice only. No auto-investing, no trade execution.
- Banking module has final authority over all financial decisions. No other module can override it.

### Git & Process
- Commit messages: imperative mood, explain the "why" not the "what".
- No force-pushes to main.
- Tests must pass before merge.

---

## Onboarding Status

**Two new team members are joining the project.** Every piece of documentation, every code comment, and every commit message should be written with the assumption that someone unfamiliar with CHRONOS will read it.

Priorities for onboarding clarity:
- `docs/PantherAI/TransactionClassifier/README.md` — start here for the classifier.
- `docs/PantherAI/TransactionClassifier/ARCHITECTURE.md` — pipeline design and current vs. planned features.
- `.agent/rules/CLAUDE.md` — project vision, golden rules, and agent behavior.

When writing new code or docs, ask: **"Would a new dev understand this without asking me?"** If not, add context.

---

## Project Map (Quick Reference)

| What | Where |
|------|-------|
| **API Gateway** | `main.py` |
| **Payment Authorization** | `routers/payment_authorization/router.py` |
| **Risk Assessment** | `services/risk_assessment/risk_assesment.py` ⚠️ *typo in filename — single 's'* |
| **BNPL Risk Scoring** | `services/bnpl_risk_scoring/bnpl_risk_scoring.py` |
| **Banking Mock API** | `services/banking/mock_api.py` |
| **Observability** | `core/logger.py` |
| Classifier pipeline | `services/TC-TransactionClassifier/classifier/pipeline.py` |
| Regex dictionary | `services/TC-TransactionClassifier/classifier/regex_dictionary.py` |
| DistilBERT inference | `services/TC-TransactionClassifier/classifier/tier2_bert.py` |
| Taxonomy (14 cat, 44 subcat) | `services/TC-TransactionClassifier/classifier/taxonomy.py` |
| Trained model artifacts | `services/TC-TransactionClassifier/models/distilbert_v1_colab/` |
| Ground truth dataset | `datasets/processed/panther_ground_truth_v3.parquet` |
| Architecture doc | `docs/PantherAI/TransactionClassifier/ARCHITECTURE.md` |
| Agent rules | `.agent/rules/CLAUDE.md` |
| Environment config | `.env` |

## Agent Skills — Auto-Routing

When any of these situations arise, invoke the corresponding skill automatically
without waiting for the dev to name it explicitly.

- `task-definer` -> Converts feature ideas into crystal-clear task definitions with input/output contracts, phase progression, and "Done when" criteria.
- `code-review` -> Reviews Python code before merging. Catches contract violations, missing error handling, hardcoded values, and maintainability issues.
- `doc` -> Generates pragmatic MVP documentation: elite docstrings for contract functions, micro-READMEs, and inline ADRs.
- `integration-test` -> Generates integration tests and contract compliance reports between two modules during the Phase 1 → Phase 2 switch.
- `observability` -> Instruments contract boundaries with `@contract` decorator and structured JSON logging.
- `onboarding` -> Prepares the repo for a new developer by auditing environment setup and generating CONTRIBUTING.md.

Skills live in `.agent/skills/`. Full pipeline and invoke syntax: `.agent/WORKFLOW.md`

## Agent Behavior

### Self-Improvement Loop
- After ANY correction: update `tasks/lessons.md` with the pattern
- Review lessons.md at the start of each session

### Verification Before Done
- Never mark a task complete without proving it works
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### Track Progress
- When `task-definer` creates tasks, it writes a checklist to `tasks/todo.md`
- As work progresses: `[ ]` → `[/]` (in progress) → `[x]` (done)
- Update `tasks/todo.md` after every completed step — no silent progress
