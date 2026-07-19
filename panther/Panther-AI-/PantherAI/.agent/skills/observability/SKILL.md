---
name: observability
description: Instruments contract boundaries between modules with structured logging. Generates logging setup, contract-boundary decorators, and a local trace reader. Use when the user asks to "add observability to", "instrument [file/module]", or "setup logging for".
---

# Observability Wizard

You are the engineer responsible for making the system legible. Your job is not to add logging everywhere — that's noise. Your job is to make **contract boundaries** between modules visible so that when something breaks, anyone on the team can read the trace and know exactly which module failed, what it received, and what it returned.

**Core philosophy:** You should never have to add a `print()` to debug. If you do, the system has failed you.

**MVP constraint:** No external services (no Datadog, no Sentry, no OpenTelemetry). Everything runs locally in structured JSON logs. Post-MVP, this plugs directly into any observability platform with zero code changes.

---

## What You Instrument

**Only instrument contract boundaries.** These are functions that:
- Are imported by another engineer's module
- Touch external data (Databases, APIs)
- Are the entry/exit point of a service

**Never instrument:**
- Internal helper functions
- Functions called only within the same module
- Pure utility functions (formatters, validators)

The signal-to-noise ratio is everything.

---

## The Three Instruments

### 1. Structured Logger Setup
One shared logger for the whole system. Every log line is a JSON object. Never use `print()` or unstructured `logging.info("something happened")`.

**Generate this as `core/logger.py`:**

```python
import logging
import json
import time
from datetime import datetime, timezone

class StructuredLogger:
    """
    Single structured logger for the system.
    All output is JSON — machine-readable and grep-able.

    Usage:
        from core.logger import log
        log.contract("process_request", id="item_123", params=200.0)
    """

    def __init__(self, name: str = "app"):
        self._logger = logging.getLogger(name)
        handler = logging.StreamHandler()
        handler.setFormatter(logging.Formatter("%(message)s"))
        self._logger.addHandler(handler)
        self._logger.setLevel(logging.DEBUG)

    def _emit(self, level: str, event: str, **kwargs):
        record = {
            "ts": datetime.now(timezone.utc).isoformat(),
            "level": level,
            "event": event,
            **kwargs
        }
        self._logger.info(json.dumps(record))

    def contract(self, fn_name: str, **kwargs):
        """Log a contract boundary call. Use at the start of every public function."""
        self._emit("CONTRACT", fn_name, **kwargs)

    def result(self, fn_name: str, duration_ms: float, **kwargs):
        """Log the result of a contract boundary call."""
        self._emit("RESULT", fn_name, duration_ms=round(duration_ms, 2), **kwargs)

    def failure(self, fn_name: str, error_type: str, message: str, **kwargs):
        """Log a contract failure — always includes who owns the function."""
        self._emit("FAILURE", fn_name, error_type=error_type, message=message, **kwargs)

    def phase(self, transition: str, module: str):
        """Log a Phase 1 → Phase 2 transition explicitly."""
        self._emit("PHASE_TRANSITION", transition, module=module)

log = StructuredLogger()
```

---

### 2. The `@contract` Decorator

Apply this to every public function at a module boundary. It logs input, output, duration, and any exception — automatically. The dev writes zero logging code.

**Generate this in `core/logger.py` (append to the file):**

```python
import functools

def contract(owner: str):
    """
    Decorator for contract boundary functions.

    Args:
        owner: Engineer who owns this function (use the person's name or team handle)

    Usage:
        @contract(owner="alice")
        def process_request(item_id: str, amount: float) -> dict:
            ...

    What it logs:
        - CONTRACT: function called with these args
        - RESULT: function returned this, took Xms
        - FAILURE: function raised this exception (owner identified)
    """
    def decorator(fn):
        @functools.wraps(fn)
        def wrapper(*args, **kwargs):
            fn_name = fn.__name__
            start = time.perf_counter()

            # Log the contract call
            log.contract(fn_name, owner=owner, args=str(args[:2]), kwargs=str(kwargs))

            try:
                result = fn(*args, **kwargs)
                duration_ms = (time.perf_counter() - start) * 1000

                # Log success — truncate large outputs
                result_preview = str(result)[:200] if result else None
                log.result(fn_name, duration_ms=duration_ms, owner=owner, result_preview=result_preview)

                return result

            except Exception as e:
                duration_ms = (time.perf_counter() - start) * 1000
                log.failure(
                    fn_name,
                    error_type=type(e).__name__,
                    message=str(e),
                    owner=owner,
                    duration_ms=duration_ms
                )
                raise  # Never swallow — always re-raise

        return wrapper
    return decorator
```

**Example usage:**
```python
from core.logger import contract

@contract(owner="alice")
def process_request(item_id: str, amount: float) -> dict:
    ...

@contract(owner="alice")
def calculate_metrics(item_id: str, value: float, count: int) -> dict:
    ...
```

---

### 3. Local Trace Reader

A simple script that reads the JSON logs and displays a human-readable trace of a request. This is what you run when something breaks and you want to see the full call chain in one view.

**Generate this as `scripts/trace.py`:**

```python
#!/usr/bin/env python3
"""
Read the structured logs and display a human-readable trace.

Usage:
    python scripts/trace.py                    # last 20 events
    python scripts/trace.py --id item_123   # filter by entity_id
    python scripts/trace.py --failures          # only show failures
    python scripts/trace.py --owner <name>      # filter by module owner
"""

import json
import sys
import argparse
from pathlib import Path

COLORS = {
    "CONTRACT": "\033[94m",   # blue
    "RESULT": "\033[92m",     # green
    "FAILURE": "\033[91m",    # red
    "PHASE_TRANSITION": "\033[93m",  # yellow
    "RESET": "\033[0m"
}

def format_event(event: dict) -> str:
    level = event.get("level", "")
    color = COLORS.get(level, "")
    reset = COLORS["RESET"]

    ts = event.get("ts", "")[-12:-7]  # just HH:MM:SS
    fn = event.get("event", "")
    owner = event.get("owner", "?")

    if level == "CONTRACT":
        return f"{color}→ [{ts}] {fn}() called  [owner: {owner}]{reset}"
    elif level == "RESULT":
        ms = event.get("duration_ms", "?")
        preview = event.get("result_preview", "")[:80]
        return f"{color}✓ [{ts}] {fn}() → {preview}  ({ms}ms){reset}"
    elif level == "FAILURE":
        err = event.get("error_type", "")
        msg = event.get("message", "")
        return f"{color}✗ [{ts}] {fn}() FAILED: {err}: {msg}  [owner: {owner}]{reset}"
    elif level == "PHASE_TRANSITION":
        return f"{color}⚡ [{ts}] PHASE TRANSITION: {fn} in {event.get('module', '')}{reset}"

    return json.dumps(event)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--user", help="Filter by user_id")
    parser.add_argument("--failures", action="store_true", help="Only show failures")
    parser.add_argument("--owner", help="Filter by module owner")
    parser.add_argument("--n", type=int, default=20, help="Last N events")
    args = parser.parse_args()

    log_file = Path("app.log")
    if not log_file.exists():
        print("No log file found. Run the app first.")
        sys.exit(1)

    events = []
    with open(log_file) as f:
        for line in f:
            try:
                events.append(json.loads(line.strip()))
            except json.JSONDecodeError:
                continue

    # Apply filters
    if args.user:
        events = [e for e in events if args.user in str(e)]
    if args.failures:
        events = [e for e in events if e.get("level") == "FAILURE"]
    if args.owner:
        events = [e for e in events if e.get("owner") == args.owner]

    # Show last N
    for event in events[-args.n:]:
        print(format_event(event))

if __name__ == "__main__":
    main()
```

---

## Output Format

Always produce:

```markdown
## Observability Report: [module_name]

**Functions instrumented:** N
**Owner assigned:** [name]
**External calls detected:** [yes/no — list them]

### Instrumented code:
[full updated file]

### To read traces:
`python scripts/trace.py --owner [name]`        # see your module's calls
`python scripts/trace.py --failures`            # see what's broken
`python scripts/trace.py --id item_123`     # trace a specific item
```

---

## Integration with the Skill Stack

| Moment | Skill to use |
|--------|-------------|
| Defining tasks | `task-definer` |
| Writing code | `doc` for contracts |
| Before PR | `code-review` |
| Phase 1 → 2 switch | `integration-test` → `observability` |
| Something breaks | `python scripts/trace.py --failures` → `debug` |
