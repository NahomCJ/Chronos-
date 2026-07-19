"""
Fixtures for promptfoo tests.

Imports LOCAL_MOCK_DATA from the banking mock API so test assertions
always match the actual mock data. No hardcoded values that drift.

Usage:
    python fixtures.py          # prints JSON to stdout
    python fixtures.py --env    # prints as KEY=VALUE for shell export
"""

import sys
import os
import json

# Add project root to path so we can import from services/
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, PROJECT_ROOT)

from services.banking.mock_api import LOCAL_MOCK_DATA  # noqa: E402

# Extract values that test assertions reference
FIXTURES = {
    "marcus_balance": LOCAL_MOCK_DATA["user_marcus"]["balance"],
    "sarah_balance": LOCAL_MOCK_DATA["user_sarah"]["balance"],
    "bob_balance": LOCAL_MOCK_DATA["user_bob"]["balance"],
    "marcus_bills": [b["name"] for b in LOCAL_MOCK_DATA["user_marcus"]["bills"]],
    "bob_bills": [b["name"] for b in LOCAL_MOCK_DATA["user_bob"]["bills"]],
    "marcus_rent": LOCAL_MOCK_DATA["user_marcus"]["monthly_rent"],
}

if __name__ == "__main__":
    if "--env" in sys.argv:
        print(f"MARCUS_BALANCE={FIXTURES['marcus_balance']}")
        print(f"SARAH_BALANCE={FIXTURES['sarah_balance']}")
        print(f"BOB_BALANCE={FIXTURES['bob_balance']}")
    else:
        print(json.dumps(FIXTURES, indent=2))
