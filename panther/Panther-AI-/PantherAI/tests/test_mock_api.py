"""
test_mock_api.py
================
Verifies that mock_api.py returns correct data for all 3 demo users.
Works in both LOCAL mode (no .env) and SUPABASE mode (with .env).

Run:
    python test_mock_api.py
"""

import sys
import os

# Allow running from project root or services/ folder
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mock_api import (
    get_balance,
    get_upcoming_bills,
    count_active_bnpls,
    count_late_bnpl_payments,
    _using_supabase,
)

# ---------------------------------------------------------------------------
PASS = "PASS"
FAIL = "FAIL"


def check(label: str, actual, expected, operator="=="):
    if operator == "==" and actual == expected:
        print(f"  {PASS}  {label}: {actual}")
        return True
    elif operator == ">=" and actual >= expected:
        print(f"  {PASS}  {label}: {actual} (>= {expected})")
        return True
    else:
        print(f"  {FAIL}  {label}: got {actual!r}, expected {expected!r}")
        return False


# ---------------------------------------------------------------------------
def run_tests():
    mode = "SUPABASE" if _using_supabase() else "LOCAL MOCK"
    print(f"\n🧪 CHRONOS — Mock API Tests  [{mode} mode]")
    print("=" * 55)

    failures = 0

    # --- MARCUS (HIGH RISK) ---
    print("\n👤 user_marcus (HIGH RISK)")
    failures += not check("balance", get_balance("user_marcus"), 1600.0)
    failures += not check("active BNPLs", count_active_bnpls("user_marcus"), 2)
    failures += not check(
        "late BNPL payments", count_late_bnpl_payments("user_marcus"), 0
    )

    bills_marcus = get_upcoming_bills("user_marcus", days_ahead=7)
    failures += not check("bills returned", len(bills_marcus), 3, ">=")
    rent = next((b for b in bills_marcus if b["name"] == "Rent"), None)
    if rent:
        failures += not check("rent amount", rent["amount"], 1500.0)
        failures += not check("rent due_in_days", rent["due_in_days"], 3)
    else:
        print(f"  {FAIL}  Rent not found in upcoming bills for Marcus")
        failures += 1

    # --- SARAH (LOW RISK) ---
    print("\n👤 user_sarah (LOW RISK)")
    failures += not check("balance", get_balance("user_sarah"), 5000.0)
    failures += not check("active BNPLs", count_active_bnpls("user_sarah"), 0)
    failures += not check(
        "late BNPL payments", count_late_bnpl_payments("user_sarah"), 0
    )

    bills_sarah_7 = get_upcoming_bills("user_sarah", days_ahead=7)
    bills_sarah_15 = get_upcoming_bills("user_sarah", days_ahead=15)
    failures += not check("bills in 7 days", len(bills_sarah_7), 0)
    failures += not check("bills in 15 days", len(bills_sarah_15), 1)

    # --- BOB (MEDIUM RISK) ---
    print("\n👤 user_bob (MEDIUM RISK)")
    failures += not check("balance", get_balance("user_bob"), 2200.0)
    failures += not check("active BNPLs", count_active_bnpls("user_bob"), 1)
    failures += not check("late BNPL payments", count_late_bnpl_payments("user_bob"), 1)

    bills_bob = get_upcoming_bills("user_bob", days_ahead=7)
    failures += not check("bills returned", len(bills_bob), 2)
    car = next((b for b in bills_bob if b["name"] == "Car Payment"), None)
    if car:
        failures += not check("car payment amount", car["amount"], 300.0)
    else:
        print(f"  {FAIL}  Car Payment not found in Bob's upcoming bills")
        failures += 1

    # --- SUMMARY ---
    print("\n" + "=" * 55)
    if failures == 0:
        print(f" All tests passed! [{mode} mode]")
    else:
        print(f"⚠  {failures} test(s) failed. Check output above.")
    return failures == 0


if __name__ == "__main__":
    ok = run_tests()
    sys.exit(0 if ok else 1)
