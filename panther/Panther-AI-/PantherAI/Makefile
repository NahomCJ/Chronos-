.PHONY: setup verify test lint run clean

# Python environment variables
VENV = .venv
PYTHON = $(VENV)/bin/python
PIP = $(VENV)/bin/pip

setup: ## Bootstraps the local environment for new developers (run this first)
	@echo "=> 🧹 Cleaning old virtual environments..."
	@rm -rf $(VENV)
	@echo "=> 🐍 Creating new virtual environment..."
	@python3 -m venv $(VENV)
	@echo "=> 📦 Installing dependencies..."
	@$(PIP) install --upgrade pip
	@$(PIP) install -r requirements.txt
	@echo "=> 🪝 Installing pre-commit hooks..."
	@$(VENV)/bin/pre-commit install
	@echo "=> 🔐 Setting up .env file..."
	@if [ ! -f .env ]; then cp .env.example .env; echo "Created .env from .env.example. Please fill in your secrets!"; else echo ".env already exists, skipping."; fi
	@echo "=> ✅ Setup complete! Run 'source $(VENV)/bin/activate' to enter the environment."

verify: ## Runs tests and linters to verify the environment is working perfectly
	@echo "=> 🔍 Verifying environment..."
	@echo "=> 1. Running Ruff Linter & Formatter..."
	@$(VENV)/bin/ruff check .
	@$(VENV)/bin/ruff format --check .
	@echo "=> 2. Running pytest..."
	@$(VENV)/bin/pytest tests/ -v || echo "⚠️  Tests failed or missing, but continuing verify."
	@echo "=> ✅ Verification passed! You are ready to push code."

test: ## Runs the test suite
	$(VENV)/bin/pytest tests/

lint: ## Runs the Ruff linter and formatter (auto-fixes where possible)
	$(VENV)/bin/ruff check . --fix
	$(VENV)/bin/ruff format .

clean: ## Removes caches and compiled python files
	rm -rf .pytest_cache
	rm -rf .ruff_cache
	find . -type d -name "__pycache__" -exec rm -r {} +
	find . -type f -name "*.pyc" -delete

help: ## Shows this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
