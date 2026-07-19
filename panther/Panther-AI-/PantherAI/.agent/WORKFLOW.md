# Chronos Dev Workflow

One file. Every skill. When to use each one.

---

## What Are Skills?

Skills are AI agent prompts stored in `.agent/skills/`. Invoke them by name when talking to Claude (e.g., `"Review file.py using CODE_REVIEW_SKILL"`). Each skill handles one phase of the dev pipeline.

---

## The Pipeline

```
IDEA
  ↓
TASK_DEFINER_SKILL       → crystal-clear task with contract, input/output, done-when
  ↓
[code it]
  ↓
DOC_SKILL                → docstrings on contract functions, micro-README if new module
  ↓
CODE_REVIEW_SKILL        → 4 lenses: contract / hardcoded values / error handling / maintainability
  ↓
INTEGRATION_TEST_SKILL   → only on Phase 1 → Phase 2 switch (replacing mocks with real APIs)
  ↓
OBSERVABILITY_SKILL      → @contract decorator on public functions, trace reader
  ↓
[open PR]
  ↓
SHIP
```

If something breaks at any point:
```
python scripts/trace.py --failures   →   DEBUG_SKILL
```

---

## Skill Index

| Skill | File | Invoke when |
|-------|------|-------------|
| `TASK_DEFINER_SKILL` | `.agent/skills/TASK-DEFINER_SKILL.md` | Starting a sprint, breaking down a feature, Monday backlog |
| `DOC_SKILL` | `.agent/skills/DOC_SKILL.md` | After writing a public function or new module |
| `CODE_REVIEW_SKILL` | `.agent/skills/CODE-REVIEW_SKILL.md` | Before every PR, always before INTEGRATION_TEST |
| `INTEGRATION_TEST_SKILL` | `.agent/skills/INTEGRATION_TEST_SKILL.md` | Phase 1 → Phase 2 switch only |
| `OBSERVABILITY_SKILL` | `.agent/skills/OBSERVABILITY_SKILL.md` | Adding a new service, Phase 2 switch, silent failures |
| `DEBUG_SKILL` | `.agent/skills/DEBUG_SKILL.md` | Traceback or wrong output, after reading trace logs |
| `ONBOARDING_SKILL` | `.agent/skills/ONBOARDING_SKILL.md` | New dev joining, environment broken |

---

## Invoke Syntax

```bash
# Task definition
"Define tasks for [feature] using TASK_DEFINER_SKILL"

# Documentation
"Document services/risk_assessment/risk_assessment.py using DOC_SKILL"

# Code review
"Review services/risk_assessment/risk_assessment.py using CODE_REVIEW_SKILL"

# Integration test (Phase 2 only)
"Run INTEGRATION_TEST_SKILL between services/banking/mock_api.py and services/risk_assessment/risk_assessment.py"

# Observability
"Run OBSERVABILITY_SKILL on services/risk_assessment/risk_assessment.py"

# Debug
"Debug this error using DEBUG_SKILL: [paste traceback]"
"DEBUG_SKILL: function_name(input) returns X but expected Y"

# Onboarding
"Run ONBOARDING_SKILL to prepare the repo for [name]"
```

---

## Severity Reference (shared across all skills)

| Level | Meaning | Action |
|-------|---------|--------|
| 🚫 BLOCKER | Another engineer's code breaks if this merges | Do not open PR |
| ⚠️ WARNING | Fragile, but doesn't break others today | Fix before merging |
| ✅ PASS | Explicitly verified — never "looks good" | Document what was checked |

---

## The Escalation Rule (universal)

> A silent interface change is always worse than the original bug.

If a fix requires changing a shared function signature, return shape, or DB schema:
1. Both owners agree on the new contract
2. Backlog definition is updated first
3. Both modules updated together
4. Never merge silently

---

## Skill Ownership

| Skill | Purpose scope |
|-------|--------------|
| TASK_DEFINER | Pre-code clarity |
| DOC_SKILL | Interface documentation |
| CODE_REVIEW | Pre-merge quality gate |
| INTEGRATION_TEST | Cross-module contract validation |
| OBSERVABILITY | Runtime legibility |
| DEBUG_SKILL | Unblock in < 10 minutes |
| ONBOARDING | Time To First Commit < 15 min |

---

*Last updated: Sprint 0 — February 2026*
