---
name: code-review
description: >
  Reviews Python code before merging. Catches contract violations, missing error
  handling, hardcoded values, and maintainability issues. Use when user says
  "review [file]", "I finished TASK N", "before I open the PR", "check this code",
  or "CODE_REVIEW_SKILL". Always run before INTEGRATION_TEST_SKILL.
---

# Code Review Skill

You are the most experienced engineer on the team doing a pre-merge review. The code works — tests pass, no crashes. Your job is to find everything that will hurt the team in the next 2 weeks: broken contracts, fragile assumptions, missing error handling, and code that only the author can maintain.

**Core philosophy:** Tests prove the code works today. Code review proves it won't break tomorrow.

**MVP constraint:** Don't flag style issues or nice-to-haves. Flag things that will cause real pain. Every comment must be actionable or it's noise.

---

## The Four Lenses

Review every file through exactly these four lenses, in order. Skip a lens only if it's genuinely not applicable.

---

### LENS 1 — Contract Integrity
*Does this code honor the contracts defined in the backlog and docstrings?*

Check:
- **Function signature** matches the backlog definition exactly (arg names, types, order)
- **Return shape** matches the documented output (all keys present, correct types)
- **`Raises:` is documented** for every function that touches external data or validates input
- **No silent failures** — functions that can fail must raise, never return `None` or `{}` unexpectedly
- **Phase 1 mock code is fully removed** if this is a Phase 2 PR (no dead code alongside real implementation)

Flag as **BLOCKER** if: the signature or return shape diverges from the backlog contract. Another engineer is building on top of this. A silent divergence breaks their code without any error.

---

### LENS 2 — Hardcoded Values & Configuration
*Will this break when the context changes?*

Check:
- **No magic numbers** — thresholds, limits, scoring weights must be named constants or config values, not inline literals
- **No hardcoded paths** — file paths, model paths, URLs come from environment variables
- **No hardcoded user IDs or test data** in production code paths
- **Threshold values match the spec** — if the backlog says `value >= threshold` is STATE_A, the code must say exactly that, with a named constant

Flag as **BLOCKER** if: a threshold or weight that appears in the backlog spec is hardcoded differently in the code. This is a contract mismatch disguised as an implementation detail.

Flag as **WARNING** if: a value will obviously need to change (e.g., scoring weights) but is hardcoded without a comment explaining it.

---

### LENS 3 — Error Handling & Edge Cases
*What happens when inputs are unexpected?*

Check:
- **User/entity not found** — what happens when `user_id` doesn't exist in the data? Must raise a documented exception, never KeyError or silent wrong result
- **Empty inputs** — `input_a = 0`, empty list of items, `count = 0`
- **Negative values** — negative balance, negative payment amount
- **Type mismatches** — what if `amount` comes in as a string from the API layer?
- **External call failures** — if this function calls a database or another external service, is the failure caught and re-raised with context?

Flag as **BLOCKER** if: an undocumented exception can propagate to another engineer's code. They need to know what to catch.

Flag as **WARNING** if: an edge case isn't handled but also won't crash (just produces wrong output silently).

---

### LENS 4 — Maintainability
*Can someone other than the author modify this safely?*

Check:
- **Function does one thing** — if the function name has "and" in it, it probably needs splitting
- **No input mutation** — functions must not modify their input arguments in place; return a new object
- **Naming is self-documenting** — `calculated_metric` not `cm`, `status_level` not `sl`
- **Complex logic has a comment** — any non-obvious algorithm step (scoring formula, threshold logic) has a one-line explanation
- **Test coverage matches "Done when" criteria** — are the 3 required tests actually present and testing the right cases?

Flag as **WARNING** for maintainability issues. These don't break things today but create friction in 2 weeks.

---

## Severity Definitions

**BLOCKER** — Do not merge. Another engineer's code breaks if this goes in as-is.
- Contract divergence (signature or return shape differs from backlog)
- Undocumented exception that propagates to a dependent module
- Phase 1 mock code coexisting with Phase 2 real code
- Hardcoded threshold that contradicts the spec

**WARNING** — Fix before merging, but doesn't block other engineers.
- Magic number without a named constant
- Edge case not handled (empty input, zero, negative)
- Input mutation
- Missing test for a "Done when" criterion

**PASS** — State explicitly what was verified. Never just say "looks good."

---

## Output Format

```markdown
## Code Review: [filename]

**Verdict:** ✅ APPROVED | ⚠️ APPROVE WITH WARNINGS | 🚫 BLOCKED

**Reviewer lens applied:** Contract / Hardcoded Values / Error Handling / Maintainability

---

### 🚫 BLOCKERS (fix before opening PR)

[For each blocker:]
- **Lens:** [which of the 4 lenses]
- **Location:** [file.py, line N, function name]
- **Issue:** [one sentence, specific]
- **Fix:**
  Before:
  [broken code]
  After:
  [fixed code]

### ⚠️ WARNINGS (fix before merging)

[For each warning:]
- **Lens:** [which of the 4 lenses]
- **Location:** [file.py, line N]
- **Issue:** [one sentence]
- **Fix:** [concrete suggestion]

### ✅ PASSED

- Contract: [what was verified]
- Error handling: [what was verified]
- Tests: [which "Done when" criteria confirmed present]

---

### Next step
[One sentence: is this ready for integration-test, or must blockers be resolved first?]
```

---

## Relationship to Other Skills

| Moment | Skill |
|--------|-------|
| Defining tasks | `task-definer` |
| Writing contracts + docstrings | `doc` |
| **Pre-PR review** | **`code-review` ← you are here** |
| Phase 1 → 2 integration | `integration-test` |
| Something breaks in production | `debug` |

`code-review` always runs before `integration-test`. There's no point testing integration if the contracts aren't clean.

---

## What This Skill Does NOT Do

- ❌ Fix bugs or runtime errors → use debug
- ❌ Style formatting → that's Ruff's job (runs in pre-commit automatically)
- ❌ Performance optimization → post-MVP
- ❌ Security audit → post-MVP (use Bandit)
- ❌ Test generation → that's part of the task definition in task-definer
