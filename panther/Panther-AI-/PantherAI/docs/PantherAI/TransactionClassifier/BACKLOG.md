# Panther AI - Transaction Classifier Backlog

> **Productivity tracker for the Transaction Classifier project**

---

## 📚 Archive & History
**Phase 1 (Pipeline Logic) is COMPLETE.**
For detailed build history, decisions, and architecture of Tasks 1-4, see:
👉 **[Phase 1 Build Report](./reports/PHASE1_BUILD.md)**

---

## 🎯 Current Sprint: Server Integration & API (Task 5)

**Start Date**: 2026-02-05
**Goal**: Wrap the completed Classifier Pipeline in a high-performance **FastAPI** microservice.

### Key Specifications
- **Service Name**: `panther-transaction-classifier`
- **Port**: `8002`
- **Architecture**: Async FastAPI
- **Model Loading**: Once per startup (using `lifespan`)

| # | Task | Description | Est. Time |
|---|------|-------------|-----------|
| 5.1 | **Setup Server Skeleton** | Create `api/server.py`. Define `/health` and `/ready` endpoints for K8s probes. Setup CORS and Logging. | 30 min |
| 5.2 | **Model Lifespan Manager** | Implement FastAPI `lifespan` handler to load the BERT model **ONCE** at startup, not per request. Store in `app.state`. | 45 min |
| 5.3 | **Implement `/classify`** | **POST** endpoint taking `{ "description": "str", "amount": float, "date": "str" }`. Returns classification result. (Amount/Date are pass-throughs for future logic). | 1 hour |
| 5.4 | **Batch Classification** | **POST** `/classify/batch` for processing history (e.g. 100 txns at once). Use `asyncio` to potentially parallelize if CPU bound, or batch infer in BERT. | 1.5 hours |
| 5.5 | **Dockerization** | Create `Dockerfile.classifier`. Multi-stage build. Install `torch` CPU-only version for production image size (unless GPU node available). | 45 min |

---

## Project Resources

| File | Purpose |
|------|---------|
| [reports/PHASE1_BUILD.md](./reports/PHASE1_BUILD.md) | **History of Tasks 1-4 (Regex, Model, Pipeline)** |
| [classifier/pipeline.py](../../PantherAI/TC-TransactionClassifier/classifier/pipeline.py) | **The Core Logic to be wrapped** |
| [classifier/taxonomy.py](../../PantherAI/TC-TransactionClassifier/classifier/taxonomy.py) | JSON Taxonomy |
| [classifier/tier1_regex.py](../../PantherAI/TC-TransactionClassifier/classifier/tier1_regex.py) | Tier 1 (Regex) |
| [classifier/tier2_bert.py](../../PantherAI/TC-TransactionClassifier/classifier/tier2_bert.py) | Tier 2 (BERT) |

---

**Last Updated**: 2026-02-05 13:45
