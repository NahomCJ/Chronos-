#!/usr/bin/env python3
"""
Read the structured logs and display a human-readable trace.

Usage:
    python scripts/trace.py                    # last 20 events
    python scripts/trace.py --failures          # only show failures
    python scripts/trace.py --n 50             # last 50 events
"""

import json
import sys
import argparse
from pathlib import Path

COLORS = {
    "CONTRACT": "\033[94m",        # blue
    "RESULT": "\033[92m",          # green
    "FAILURE": "\033[91m",         # red
    "PHASE_TRANSITION": "\033[93m",  # yellow
    "RESET": "\033[0m",
}


def format_event(event: dict) -> str:
    level = event.get("level", "")
    color = COLORS.get(level, "")
    reset = COLORS["RESET"]

    ts = event.get("ts", "")[-12:-7]  # HH:MM
    fn = event.get("event", "")

    if level == "CONTRACT":
        return f"{color}→ [{ts}] {fn}() called{reset}"
    elif level == "RESULT":
        ms = event.get("duration_ms", "?")
        preview = event.get("result_preview", "")[:80]
        return f"{color}✓ [{ts}] {fn}() → {preview}  ({ms}ms){reset}"
    elif level == "FAILURE":
        err = event.get("error_type", "")
        msg = event.get("message", "")
        return f"{color}✗ [{ts}] {fn}() FAILED: {err}: {msg}{reset}"
    elif level == "PHASE_TRANSITION":
        module = event.get("module", "")
        return f"{color}⚡ [{ts}] PHASE TRANSITION: {fn} in {module}{reset}"

    return json.dumps(event)


def main():
    parser = argparse.ArgumentParser(description="CHRONOS trace reader")
    parser.add_argument("--failures", action="store_true", help="Only show failures")
    parser.add_argument("--n", type=int, default=20, help="Last N events")
    parser.add_argument("--file", default="app.log", help="Log file path")
    args = parser.parse_args()

    log_file = Path(args.file)
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
    if args.failures:
        events = [e for e in events if e.get("level") == "FAILURE"]

    # Show last N
    for event in events[-args.n:]:
        print(format_event(event))


if __name__ == "__main__":
    main()
