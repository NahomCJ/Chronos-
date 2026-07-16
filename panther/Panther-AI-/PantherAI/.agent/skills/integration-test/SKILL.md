---
name: integration-test
description: >
  Generates integration tests and contract compliance reports between two modules
  during the Phase 1 → Phase 2 switch (replacing mocks with real APIs). Use when
  user says "INTEGRATION_TEST_SKILL", "Phase 1 to Phase 2", "test the integration
  between [module A] and [module B]". Always run after CODE_REVIEW_SKILL.
---

# Integration Test Skill

You are the senior engineer responsible for making sure the team's contracts hold in reality, not just on paper.

**Core philosophy:** A broken interface is always worse than a broken implementation. Implementations affect one person. Interfaces affect the whole team.

---

## When to Invoke

Manually, when a dev makes the **Phase 1 → Phase 2 switch** — replacing local mocks with the real producer interface. Run this **before opening the PR**, after `code-review`.

---

## Input You Need

1. **The producer module** — who exposes the interface (e.g., `path/to/<producer>.py`)
2. **The consumer module** — who imports it (e.g., `path/to/<consumer>.py`)
3. **The contract** — function signature, input shape, output shape from `backlog.md` or docstring
4. **The owner of each module** — who wrote the producer, who wrote the consumer (from backlog task assignments)

If ownership isn't explicit, infer it from the backlog task assignments.

---

## Responsible Layer Classification

Before writing a single test, classify the relationship:

| Layer | Definition | Who Fixes It |
|-------|-----------|--------------|
| **Producer bug** | The function exposing the interface returns wrong shape or throws unexpected errors | Producer owner |
| **Consumer bug** | The caller is using the interface incorrectly (wrong args, ignoring Raises) | Consumer owner |
| **Contract mismatch** | The interface evolved and both sides diverged from the backlog definition | Both owners must coordinate before any fix |
| **Environment bug** | Missing dependency, env var, or database connection | Dev with the failing env |

**A contract mismatch is always the most dangerous.** It means the backlog definition is stale and both parties are working from different assumptions. Flag immediately and block the PR.

---

## Test Plan (Always Generate This First)

Before writing code, produce an explicit plan:

```markdown
## Test Plan: [ProducerModule] → [ConsumerModule]

### Contract Under Test
Function: `function_name(arg1: type, arg2: type) -> ReturnShape`
Source of truth: [backlog.md task N | docstring in file.py]

### Cases to Cover

**Happy Path (must all pass)**
- [ ] Scenario A (Nominal) — tests typical flow end-to-end
- [ ] Scenario B (Alternate) — tests the other extreme
- [ ] Scenario C (Edge) — tests a valid but rare state

**Boundary Values (the cases that reveal wrong thresholds)**
- [ ] Input that lands exactly at the Boundary A/B threshold
- [ ] Input that lands exactly at the Boundary B/C threshold
- [ ] Zero or empty edge case

**Producer Failure Cases (what happens when the producer misbehaves)**
- [ ] Producer returns unexpected shape (missing key)
- [ ] Producer raises an exception
- [ ] Producer returns None or empty

**Consumer Misuse Cases (what happens when the consumer breaks the contract)**
- [ ] Consumer passes wrong type for an argument
- [ ] Consumer passes a user_id that doesn't exist
- [ ] Consumer ignores documented Raises and doesn't catch
```

---

## Test File Generation

Generate `tests/integration/test_integration_[producer]_[consumer].py` with this structure:

```python
"""
Integration tests: [ProducerModule] → [ConsumerModule]
Contract source: [backlog.md task N | file.py docstring]
Producer owner: [name]
Consumer owner: [name]
"""
import pytest
from [producer_path] import [function_name]
from [consumer_path] import [consumer_function]


# ─── Fixtures ────────────────────────────────────────────────────────────────

@pytest.fixture
def scenario_a_input():
    """Scenario A input. Typical nominal flow."""
    return "input_a"  # Provide values that trigger Scenario A

@pytest.fixture
def scenario_b_input():
    """Scenario B input. The other extreme."""
    return "input_b"   # Provide values that trigger Scenario B

@pytest.fixture
def scenario_c_input():
    """Scenario C input. Tight but manageable state."""
    return "input_c"   # Provide values that trigger Scenario C


# ─── Happy Path ──────────────────────────────────────────────────────────────

def test_scenario_a_contract_holds(scenario_a_input):
    """Producer returns expected shape for Scenario A."""
    result = consumer_function(scenario_a_input, 200.00)
    assert "status" in result
    assert "message" in result
    assert result["status"] == "SCENARIO_A"

def test_scenario_b_contract_holds(scenario_b_input):
    """Alternate margin should yield Scenario B."""
    result = consumer_function(scenario_b_input, 200.00)
    assert result["status"] == "SCENARIO_B"

def test_scenario_c_contract_holds(scenario_c_input):
    """Lands in Scenario C."""
    result = consumer_function(scenario_c_input, 200.00)
    assert result["status"] == "SCENARIO_C"


# ─── Boundary Values ─────────────────────────────────────────────────────────

def test_threshold_ab_boundary():
    """Exactly at the Boundary A/B threshold. Verify which side it falls on."""
    result = consumer_function("input_c", [BOUNDARY_THRESHOLD])
    assert result["status"] in ("SCENARIO_A", "SCENARIO_B")  # Clarify exact value with spec

def test_zero_edge_case(scenario_b_input):
    """Zero input should not crash and should return safe default."""
    result = consumer_function(scenario_b_input, 0.00)
    assert result is not None
    assert "status" in result


# ─── Producer Failure Cases ───────────────────────────────────────────────────

def test_consumer_handles_unknown_entity():
    """What happens when producer is asked for an entity that doesn't exist."""
    with pytest.raises((KeyError, ValueError)):
        consumer_function("entity_nonexistent", 100.00)

def test_consumer_handles_producer_missing_key(monkeypatch):
    """Producer returns incomplete shape — consumer must not silently fail."""
    def broken_producer(entity_id):
        return {}  # Missing all expected keys

    monkeypatch.setattr("[producer_module]", "[producer_function]", broken_producer)
    with pytest.raises((KeyError, TypeError)):
        consumer_function("entity_high", 100.00)


# ─── Run Command ─────────────────────────────────────────────────────────────
# pytest tests/integration/test_integration_[producer]_[consumer].py -v
```

---

## Severity Definitions

**BLOCKER** — Merge this and another engineer's work breaks today.
- Contract mismatch between backlog definition and actual implementation
- Producer raises undocumented exceptions the consumer doesn't catch
- Consumer passes wrong type/shape to producer
- Import that will fail at runtime (wrong path, missing module)

**WARNING** — Merge this and we accumulate integration debt.
- Boundary values not covered by tests
- Producer failure cases not handled gracefully
- Dead mock code from Phase 1 still present alongside Phase 2 code
- Threshold values hardcoded in both producer and consumer independently

**PASS** — Confirm explicitly what was verified. Never say "looks good."

---

## Output Format

Always produce the report using exactly this structure:

```markdown
## Integration Report: [ProducerModule] → [ConsumerModule]

**Verdict:** ✅ CONTRACT HOLDS | ⚠️ WARNINGS | 🚫 CONTRACT BROKEN

**Producer owner:** [name]
**Consumer owner:** [name]
**Contract source:** [backlog.md task N | docstring in file.py]

---

### 🚫 BLOCKERS (coordinate before merging)

[For each blocker:]
- **Location:** [file.py, line N]
- **Responsible layer:** [producer bug | consumer bug | contract mismatch | environment]
- **Who acts:** [name] must [specific action]
- **Coordination needed:** yes/no — contract mismatch always requires yes

### ⚠️ WARNINGS (fix before Phase 2 PR)

[For each warning:]
- **Location:** [file.py, line N]
- **Issue:** [what's fragile]
- **Who acts:** [name]
- **Suggested fix:** [concrete action]

### ✅ PASSED

[List explicitly what was verified]

---

### Test Coverage vs Contract

| Test Case | Expected | Got | Status | Owner if failing |
|-----------|----------|-----|--------|-----------------|
| Scenario A Input | status: SCENARIO_A | ... | ✅/❌ | [name] |
| Scenario B Input | status: SCENARIO_B | ... | ✅/❌ | [name] |
| Scenario C Input | status: SCENARIO_C | ... | ✅/❌ | [name] |
| Boundary A/B | defined by spec | ... | ✅/❌ | [name] |
| Unknown entity | raises ValueError | ... | ✅/❌ | [name] |
| Producer missing key | raises cleanly | ... | ✅/❌ | [name] |

---

### �� Phase 2 Readiness

**Can [ConsumerOwner] merge their Phase 2 PR?**
- [ ] All happy path tests pass
- [ ] All producer failure cases handled with documented exceptions
- [ ] No contract mismatches between backlog definition and current implementation
- [ ] Phase 1 mock code fully removed (no dead code)

**Next action:** [one sentence — who does what before this PR is ready]
```

---

## Escalation Rule

**TL;DR:** If any test reveals a contract mismatch, neither owner merges until both agree on the correct contract and the backlog definition is updated. A silent interface change is always worse than the original failure.

---

## Relationship to Other Skills

| Moment | Skill |
|--------|-------|
| Defining tasks | `task-definer` |
| Writing contracts + docstrings | `doc` |
| Pre-PR review | `code-review` |
| **Phase 1 → 2 integration** | **`integration-test` ← you are here** |
| Runtime legibility | `observability` |
| Something breaks | `debug` |

`integration-test` runs after `code-review`. Do not test integration if the contracts aren't clean.
