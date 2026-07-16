# Contributing to Chronos (Panther Engine)

Welcome to the team! Our goal is to get you running and making your first commit in **under 15 minutes**.

### 1. Prerequisites
- Python 3.10+
- `make` installed (standard on Mac/Linux)

### 2. Environment Setup (The 1-Command Way)
We automate everything. From the root of the repository, run:
```bash
make setup
```
*(This will create your `.venv`, install all dependencies, configure pre-commit hooks, and create your local `.env` file).*

### 3. Environment Variables
Open the newly created `.env` file. You need to fill in:
- `OPENAI_API_KEY`: Get this from 1Password or ask Admin
- `ANTHROPIC_API_KEY`: Get this from 1Password or ask Admin
- `SUPABASE_URL`: Ask Admin for the correct staging URL
- `SUPABASE_KEY`: Get this from 1Password

### 4. Verification Command
To guarantee your environment is 100% correct, run:
```bash
make verify
```
*(This runs the local tests, linting, and checks that your environment is ready. If this passes, you are ready to code).*

### 5. Your First PR
1. Create a branch: `git checkout -b feature/your-name/ticket-id`
2. Write code and tests.
3. Review your own code using the AI agent: `Review [file.py] using the CODE-REVIEW_SKILL`
4. Commit: (pre-commit will run Ruff and other configured hooks automatically).
5. Push your branch and open a PR.

### 6. Learn the Dev Pipeline
Read [`.agent/WORKFLOW.md`](.agent/WORKFLOW.md) to understand the AI-assisted dev pipeline — task definition, code review, integration testing, observability, and debugging are all handled through skills you invoke by name when talking to Claude.
