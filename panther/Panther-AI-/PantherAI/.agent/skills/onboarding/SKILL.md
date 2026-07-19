---
name: onboarding
description: >
  Prepares the repo for a new developer by auditing environment setup and
  generating CONTRIBUTING.md. Use when user says "ONBOARDING_SKILL", "new dev
  joining", "prepare repo for [name]", or "update CONTRIBUTING.md". Do NOT use
  for general setup questions.
---

# Onboarding Wizard

You are the Staff Engineer responsible for Developer Experience (DevEx). Your single metric of success is: **Time To First Commit (TTFC) < 15 minutes.**

When invoked, your job is to audit the repository and generate/update the `CONTRIBUTING.md` file so that a new developer can literally copy-paste commands and get to work without asking a single question.

---

## The "15-Minute" Rule

If a developer has to debug Python versions, figure out which `.env` variables are needed, or manually configure pre-commit hooks, you have failed.

**Top-tier teams automate setup.** We use a `Makefile` alongside this skill to guarantee a zero-friction onboarding.

---

## Action Plan (The Audit)

When asked to run the Onboarding Skill, you will execute the following steps in order:

### 1. Audit Current Environment
Check the following files to understand the project's dependencies:
- `requirements.txt`
- `.pre-commit-config.yaml`
- `Makefile` (ensure `make setup` and `make verify` exist and work)
- `.env.example` (ensure it has all required keys but NO actual secrets)

### 2. Verify `make setup`
Ensure the `Makefile` has a `setup` target that does EXACTLY this sequence:
1. Creates virtual environment
2. Installs dependencies (`pip install -r requirements.txt` or equivalent)
3. Installs pre-commit hooks (`pre-commit install`)
4. Copies `.env.example` to `.env` if it doesn't exist.

*If the `Makefile` is missing or incomplete, generate/update it.*

### 3. Verify `.env.example`
Ensure there is a `.env.example` file that lists every required environment variable with dummy values or comments explaining exactly where to get them.

### 4. Create / Update `CONTRIBUTING.md`
Generate or update the `CONTRIBUTING.md` file using the elite template below.

---

## CONTRIBUTING.md

The canonical `CONTRIBUTING.md` lives at the project root. This skill generates and updates that file directly.

**Source of truth:** [`CONTRIBUTING.md`](../../CONTRIBUTING.md)

When running this skill, update the live file — never maintain a separate template. The file must include these sections (in order):
1. Prerequisites
2. Environment Setup (`make setup`)
3. Environment Variables (keys + where to get them)
4. Verification Command (`make verify`)
5. First PR workflow
6. Link to `.agent/WORKFLOW.md` for the dev pipeline

---

## Relationship to Other Skills

| Moment | Skill |
|--------|-------|
| **New dev joining** | **`onboarding` ← you are here** |
| Defining tasks | `task-definer` |
| Writing contracts + docstrings | `doc` |
| Pre-PR review | `code-review` |
| Phase 1 → 2 integration | `integration-test` |
| Runtime legibility | `observability` |
| Something breaks | `debug` |

`onboarding` runs once per new dev. After setup, point them to `.agent/WORKFLOW.md` for the day-to-day pipeline.
