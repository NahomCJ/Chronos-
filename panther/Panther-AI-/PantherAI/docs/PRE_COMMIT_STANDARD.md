# Panther Engine
# Engineering Quality Standard [EQS-01]: Pre-commit Enforcer
## Status: [LIVE] | Scope: Pan-Repo

> "Quality is not an act, it is a habit enforced by an automated pipeline."

## 1. Abstract
As the Panther AI processing engine demands tier-1 reliability, human code reviews must focus on architecture and algorithmic correctness—not linting, formatting, or trivial bugs.

This document defines the automated **Pre-commit Enforcer** architecture deployed across the Chronos repository. This system establishes a hermetic seal against sub-standard code reaching the main tree.

## 2. Pipeline Architecture (The "Lean MVP" Philosophy)

The enforcement pipeline consists of 2 ultra-fast defensive layers.
**Zero-Friction Rule**: If a developer feels the need to use `--no-verify` because the pipeline is too slow, the system is misconfigured. Hooks must execute in milliseconds. Heavy checks (Tests, MyPy, Bandit) are strictly relegated to the CI/CD pipeline (e.g., GitHub Actions) to run asynchronously on Pull Requests.

### Layer 1: Repository Hygiene
- **`trailing-whitespace`**: Strips invisible trailing whitespace to compress diffs.
- **`end-of-file-fixer`**: Ensures all files end with a POSIX-compliant trailing newline.
- **`check-added-large-files`**: Blocks any file > 500KB to prevent repository bloating (e.g., datasets).
- **`detect-private-key`**: Scans for AWS keys, JWT secrets, and SSL certificates. Any match triggers a fatal block.

### Layer 2: Ultra-Fast Linting & Formatting (Ruff)
- **`ruff-format`**: Sub-millisecond formatting engine. Replaces Black.
- **`ruff`**: Rust-based linter that validates PEP8 compliance, flags unused imports, and enforces Python best practices instantly. Auto-fixes where possible.



## 3. Operations Manual

### 3.1 Setup (For New Engineers)
After cloning the repository, developers must initialize the enforcer:
```bash
pip install pre-commit
pre-commit install
```

### 3.2 Bypassing the Enforcer
> ⚠️ **WARNING: Bypassing the enforcer is strictly prohibited for main/production branches.**

If emergency circumstances require a bypass (e.g., mid-development WIP save on a personal branch):
```bash
git commit --no-verify -m "WIP: ..."
```

### 3.3 Manual Execution
To retroactively enforce standards on the entire repository (e.g., after an architectural rewrite):
```bash
pre-commit run --all-files
```

## 4. Troubleshooting
- **Ruff complains about an impossible line:** Add `# ruff: noqa` to the specific line.
