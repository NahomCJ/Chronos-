"""
services/banking/mock_api.py
============================
Public API contract for banking data.
Martín and Mahi import ONLY these functions — they don't care where the data comes from.

DATA SOURCE PRIORITY (auto-detected per user):
  1. Plaid API    — if user has a plaid_token in Supabase (real bank connected)
  2. Supabase     — if SUPABASE_URL + SUPABASE_KEY are in .env (demo users)
  3. Local mocks  — fallback for offline dev

This means:
  - Demo users (Marcus, Sarah, Bob) → Supabase
  - Real users who connected their bank → Plaid
  - Offline / no .env → local dict
"""

from __future__ import annotations

import calendar
import os
from datetime import date, timedelta
from typing import Any, Dict, List

from dotenv import load_dotenv

from core.logger import log

load_dotenv()

# ---------------------------------------------------------------------------
# LOCAL FALLBACK DATA
# Dates are computed relative to today so the demo never shows stale data.
# _d(offset, day) → ISO date in month (0=current, -1=previous, -2=two ago).
# _ts(offset, day, h, m) → ISO timestamp for warnings.
# ---------------------------------------------------------------------------
_TODAY = date.today()
_MONTH_STARTS: Dict[int, date] = {}
_m = _TODAY.replace(day=1)
for _i in range(3):
    _MONTH_STARTS[-_i] = _m
    _m = (_m - timedelta(days=1)).replace(day=1)


def _d(month_offset: int, day: int) -> str:
    """ISO date string in a month relative to today. Clamps day to valid range and to today for current month."""
    ms = _MONTH_STARTS[month_offset]
    max_day = calendar.monthrange(ms.year, ms.month)[1]
    clamped = min(day, max_day)
    if month_offset == 0:
        clamped = min(clamped, _TODAY.day)
    return date(ms.year, ms.month, clamped).isoformat()


def _ts(month_offset: int, day: int, hour: int, minute: int) -> str:
    """ISO timestamp string for warning records."""
    return f"{_d(month_offset, day)}T{hour:02d}:{minute:02d}:00Z"


LOCAL_MOCK_DATA: Dict[str, Any] = {
    "user_marcus": {
        "balance": 1600.00,
        "monthly_rent": 1500.00,
        "bills": [
            {"name": "Rent", "amount": 1500, "due_in_days": 3},
            {"name": "Netflix", "amount": 15.99, "due_in_days": 7},
            {"name": "Utilities", "amount": 120, "due_in_days": 5},
        ],
        "active_bnpls": 2,
        "active_bnpl_amount": 350.00,
        "late_bnpl_payments": 0,
        "transactions": [
            # --- Current month ---
            {
                "merchant": "STARBUCKS",
                "amount": -4.50,
                "date": _d(0, 17),
                "category": "Restaurants & Bars",
            },
            {
                "merchant": "UBER",
                "amount": -12.30,
                "date": _d(0, 17),
                "category": "Taxi & Ride-sharing",
            },
            {
                "merchant": "WHOLE FOODS",
                "amount": -87.40,
                "date": _d(0, 16),
                "category": "Groceries",
            },
            {
                "merchant": "SHELL",
                "amount": -52.00,
                "date": _d(0, 15),
                "category": "Fuel & Tolls",
            },
            {
                "merchant": "NETFLIX",
                "amount": -15.99,
                "date": _d(0, 15),
                "category": "Subscriptions",
            },
            {
                "merchant": "DOORDASH",
                "amount": -34.20,
                "date": _d(0, 14),
                "category": "Delivery Services",
            },
            {
                "merchant": "TRADER JOES",
                "amount": -62.80,
                "date": _d(0, 13),
                "category": "Groceries",
            },
            {
                "merchant": "LYFT",
                "amount": -18.50,
                "date": _d(0, 13),
                "category": "Taxi & Ride-sharing",
            },
            {
                "merchant": "SPOTIFY",
                "amount": -10.99,
                "date": _d(0, 12),
                "category": "Subscriptions",
            },
            {
                "merchant": "AMAZON",
                "amount": -129.99,
                "date": _d(0, 11),
                "category": "Electronics",
            },
            {
                "merchant": "CHIPOTLE",
                "amount": -11.25,
                "date": _d(0, 10),
                "category": "Restaurants & Bars",
            },
            {
                "merchant": "PG&E",
                "amount": -120.00,
                "date": _d(0, 10),
                "category": "Utility Bills",
            },
            {
                "merchant": "CVS PHARMACY",
                "amount": -23.50,
                "date": _d(0, 9),
                "category": "Medical & Pharmacy",
            },
            {
                "merchant": "SAFEWAY",
                "amount": -54.30,
                "date": _d(0, 8),
                "category": "Groceries",
            },
            {
                "merchant": "UBER EATS",
                "amount": -28.90,
                "date": _d(0, 7),
                "category": "Delivery Services",
            },
            {
                "merchant": "BEST BUY",
                "amount": -249.99,
                "date": _d(0, 6),
                "category": "Electronics",
            },
            {
                "merchant": "STARBUCKS",
                "amount": -5.75,
                "date": _d(0, 6),
                "category": "Restaurants & Bars",
            },
            {
                "merchant": "BART",
                "amount": -5.60,
                "date": _d(0, 5),
                "category": "Public Transport",
            },
            {
                "merchant": "WHOLE FOODS",
                "amount": -95.20,
                "date": _d(0, 4),
                "category": "Groceries",
            },
            {
                "merchant": "LANDLORD PMT",
                "amount": -1500.00,
                "date": _d(0, 1),
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "COMCAST",
                "amount": -79.99,
                "date": _d(0, 1),
                "category": "Internet & Phone",
            },
            {
                "merchant": "EQUINOX",
                "amount": -89.00,
                "date": _d(0, 1),
                "category": "Fitness & Gym",
            },
            {
                "merchant": "EMPLOYER DIRECT",
                "amount": 5200.00,
                "date": _d(0, 1),
                "category": "Salary",
            },
            {
                "merchant": "STARBUCKS",
                "amount": -4.25,
                "date": _d(0, 3),
                "category": "Restaurants & Bars",
            },
            {
                "merchant": "MUNI",
                "amount": -3.00,
                "date": _d(0, 2),
                "category": "Public Transport",
            },
            # --- Previous month (for comparisons) ---
            {
                "merchant": "LANDLORD PMT",
                "amount": -1500.00,
                "date": _d(-1, 1),
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "EMPLOYER DIRECT",
                "amount": 5200.00,
                "date": _d(-1, 1),
                "category": "Salary",
            },
            {
                "merchant": "WHOLE FOODS",
                "amount": -78.30,
                "date": _d(-1, 28),
                "category": "Groceries",
            },
            {
                "merchant": "SAFEWAY",
                "amount": -43.10,
                "date": _d(-1, 25),
                "category": "Groceries",
            },
            {
                "merchant": "TRADER JOES",
                "amount": -55.40,
                "date": _d(-1, 20),
                "category": "Groceries",
            },
            {
                "merchant": "STARBUCKS",
                "amount": -4.50,
                "date": _d(-1, 22),
                "category": "Restaurants & Bars",
            },
            {
                "merchant": "CHIPOTLE",
                "amount": -12.50,
                "date": _d(-1, 18),
                "category": "Restaurants & Bars",
            },
            {
                "merchant": "DOORDASH",
                "amount": -22.80,
                "date": _d(-1, 15),
                "category": "Delivery Services",
            },
            {
                "merchant": "UBER",
                "amount": -15.00,
                "date": _d(-1, 14),
                "category": "Taxi & Ride-sharing",
            },
            {
                "merchant": "SHELL",
                "amount": -48.00,
                "date": _d(-1, 12),
                "category": "Fuel & Tolls",
            },
            {
                "merchant": "NETFLIX",
                "amount": -15.99,
                "date": _d(-1, 15),
                "category": "Subscriptions",
            },
            {
                "merchant": "SPOTIFY",
                "amount": -10.99,
                "date": _d(-1, 12),
                "category": "Subscriptions",
            },
            {
                "merchant": "PG&E",
                "amount": -110.00,
                "date": _d(-1, 10),
                "category": "Utility Bills",
            },
            {
                "merchant": "COMCAST",
                "amount": -79.99,
                "date": _d(-1, 1),
                "category": "Internet & Phone",
            },
            {
                "merchant": "EQUINOX",
                "amount": -89.00,
                "date": _d(-1, 1),
                "category": "Fitness & Gym",
            },
            {
                "merchant": "CVS PHARMACY",
                "amount": -18.90,
                "date": _d(-1, 8),
                "category": "Medical & Pharmacy",
            },
            {
                "merchant": "BART",
                "amount": -8.40,
                "date": _d(-1, 6),
                "category": "Public Transport",
            },
            # --- Two months ago (for 3-month sparklines) ---
            {
                "merchant": "LANDLORD PMT",
                "amount": -1500.00,
                "date": _d(-2, 1),
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "EMPLOYER DIRECT",
                "amount": 5200.00,
                "date": _d(-2, 1),
                "category": "Salary",
            },
            {
                "merchant": "WHOLE FOODS",
                "amount": -72.60,
                "date": _d(-2, 28),
                "category": "Groceries",
            },
            {
                "merchant": "SAFEWAY",
                "amount": -38.90,
                "date": _d(-2, 22),
                "category": "Groceries",
            },
            {
                "merchant": "STARBUCKS",
                "amount": -5.00,
                "date": _d(-2, 20),
                "category": "Restaurants & Bars",
            },
            {
                "merchant": "UBER",
                "amount": -22.00,
                "date": _d(-2, 18),
                "category": "Taxi & Ride-sharing",
            },
            {
                "merchant": "NETFLIX",
                "amount": -15.99,
                "date": _d(-2, 15),
                "category": "Subscriptions",
            },
            {
                "merchant": "SPOTIFY",
                "amount": -10.99,
                "date": _d(-2, 12),
                "category": "Subscriptions",
            },
            {
                "merchant": "PG&E",
                "amount": -105.00,
                "date": _d(-2, 10),
                "category": "Utility Bills",
            },
            {
                "merchant": "COMCAST",
                "amount": -79.99,
                "date": _d(-2, 1),
                "category": "Internet & Phone",
            },
            {
                "merchant": "EQUINOX",
                "amount": -89.00,
                "date": _d(-2, 1),
                "category": "Fitness & Gym",
            },
            {
                "merchant": "SHELL",
                "amount": -45.00,
                "date": _d(-2, 14),
                "category": "Fuel & Tolls",
            },
        ],
        "warnings_history": [
            {
                "id": "warn_m001",
                "timestamp": _ts(0, 17, 14, 30),
                "source": "cash_flow",
                "risk_level": "HIGH",
                "title": "High-risk payment attempted",
                "message": "Your Rent of $1,500.00 is due in 3 days. Buying $249.99 at BEST BUY will leave you with projected balance of -$149.99.",
                "context": {
                    "payment_amount": 249.99,
                    "merchant": "BEST BUY",
                    "projected_balance": -149.99,
                    "triggering_bill": {
                        "name": "Rent",
                        "amount": 1500.00,
                        "due_in_days": 3,
                    },
                },
                "outcome": {
                    "user_action": "proceeded",
                    "action_label": "User proceeded anyway",
                },
            },
            {
                "id": "warn_m002",
                "timestamp": _ts(0, 11, 9, 15),
                "source": "bnpl",
                "risk_level": "MEDIUM",
                "title": "BNPL risk elevated",
                "message": "You already have 2 active BNPL plans. Adding another takes up 38% of your available monthly cash.",
                "context": {
                    "bnpl_score": 52,
                    "payment_amount": 129.99,
                    "merchant": "AMAZON",
                    "num_payments": 4,
                    "monthly_payment": 32.50,
                    "risk_factors": [
                        "2 active BNPL plans",
                        "BNPL consumes 38% of free cash",
                    ],
                },
                "outcome": {
                    "user_action": "cancelled",
                    "action_label": "User cancelled",
                },
            },
            {
                "id": "warn_m003",
                "timestamp": _ts(0, 6, 16, 45),
                "source": "cash_flow",
                "risk_level": "HIGH",
                "title": "Large purchase exceeds safety buffer",
                "message": "This $249.99 purchase at BEST BUY reduces your balance to $1,350.01. Rent ($1,500) is due in 25 days.",
                "context": {
                    "payment_amount": 249.99,
                    "merchant": "BEST BUY",
                    "projected_balance": 1350.01,
                    "triggering_bill": {
                        "name": "Rent",
                        "amount": 1500.00,
                        "due_in_days": 25,
                    },
                },
                "outcome": {
                    "user_action": "proceeded",
                    "action_label": "User proceeded anyway",
                },
            },
            {
                "id": "warn_m004",
                "timestamp": _ts(-1, 28, 11, 20),
                "source": "cash_flow",
                "risk_level": "MEDIUM",
                "title": "Spending pace above average",
                "message": "You've spent 85% of your typical monthly budget with 3 days remaining.",
                "context": {
                    "payment_amount": 78.30,
                    "merchant": "WHOLE FOODS",
                    "projected_balance": 620.00,
                },
                "outcome": {
                    "user_action": "proceeded",
                    "action_label": "User proceeded anyway",
                },
            },
            {
                "id": "warn_m005",
                "timestamp": _ts(-1, 14, 8, 0),
                "source": "cash_flow",
                "risk_level": "LOW",
                "title": "Payment within safe range",
                "message": "This $15.00 Uber ride is within your daily budget.",
                "context": {
                    "payment_amount": 15.00,
                    "merchant": "UBER",
                    "projected_balance": 2100.00,
                },
                "outcome": {
                    "user_action": "proceeded",
                    "action_label": "User proceeded",
                },
            },
        ],
    },
    "user_sarah": {
        "balance": 5000.00,
        "monthly_rent": 1200.00,
        "bills": [
            {"name": "Rent", "amount": 1200, "due_in_days": 15},
        ],
        "active_bnpls": 0,
        "active_bnpl_amount": 0.00,
        "late_bnpl_payments": 0,
        "transactions": [
            # --- Current month ---
            {
                "merchant": "WHOLE FOODS",
                "amount": -89.50,
                "date": _d(0, 17),
                "category": "Groceries",
            },
            {
                "merchant": "SEPHORA",
                "amount": -67.00,
                "date": _d(0, 16),
                "category": "Wellness & Beauty",
            },
            {
                "merchant": "TRADER JOES",
                "amount": -45.30,
                "date": _d(0, 14),
                "category": "Groceries",
            },
            {
                "merchant": "YOGA STUDIO",
                "amount": -35.00,
                "date": _d(0, 13),
                "category": "Fitness & Gym",
            },
            {
                "merchant": "TARGET",
                "amount": -82.40,
                "date": _d(0, 12),
                "category": "Home & General",
            },
            {
                "merchant": "EMPLOYER DIRECT",
                "amount": 6500.00,
                "date": _d(0, 1),
                "category": "Salary",
            },
            {
                "merchant": "LANDLORD PMT",
                "amount": -1200.00,
                "date": _d(0, 1),
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "STARBUCKS",
                "amount": -6.25,
                "date": _d(0, 10),
                "category": "Restaurants & Bars",
            },
            {
                "merchant": "UBER",
                "amount": -22.00,
                "date": _d(0, 9),
                "category": "Taxi & Ride-sharing",
            },
            {
                "merchant": "NETFLIX",
                "amount": -15.99,
                "date": _d(0, 8),
                "category": "Subscriptions",
            },
            {
                "merchant": "WHOLE FOODS",
                "amount": -72.10,
                "date": _d(0, 5),
                "category": "Groceries",
            },
            {
                "merchant": "ZARA",
                "amount": -145.00,
                "date": _d(0, 3),
                "category": "Fashion",
            },
            # --- Previous month ---
            {
                "merchant": "LANDLORD PMT",
                "amount": -1200.00,
                "date": _d(-1, 1),
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "EMPLOYER DIRECT",
                "amount": 6500.00,
                "date": _d(-1, 1),
                "category": "Salary",
            },
            {
                "merchant": "WHOLE FOODS",
                "amount": -65.20,
                "date": _d(-1, 25),
                "category": "Groceries",
            },
            {
                "merchant": "TRADER JOES",
                "amount": -38.90,
                "date": _d(-1, 18),
                "category": "Groceries",
            },
            {
                "merchant": "SEPHORA",
                "amount": -52.00,
                "date": _d(-1, 15),
                "category": "Wellness & Beauty",
            },
            {
                "merchant": "NETFLIX",
                "amount": -15.99,
                "date": _d(-1, 15),
                "category": "Subscriptions",
            },
            # --- Two months ago ---
            {
                "merchant": "LANDLORD PMT",
                "amount": -1200.00,
                "date": _d(-2, 1),
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "EMPLOYER DIRECT",
                "amount": 6500.00,
                "date": _d(-2, 1),
                "category": "Salary",
            },
            {
                "merchant": "WHOLE FOODS",
                "amount": -58.40,
                "date": _d(-2, 20),
                "category": "Groceries",
            },
            {
                "merchant": "NETFLIX",
                "amount": -15.99,
                "date": _d(-2, 15),
                "category": "Subscriptions",
            },
        ],
        "warnings_history": [
            {
                "id": "warn_s001",
                "timestamp": _ts(0, 3, 10, 0),
                "source": "cash_flow",
                "risk_level": "LOW",
                "title": "Payment within safe range",
                "message": "This $145.00 purchase at ZARA is within your budget.",
                "context": {
                    "payment_amount": 145.00,
                    "merchant": "ZARA",
                    "projected_balance": 4855.00,
                },
                "outcome": {
                    "user_action": "proceeded",
                    "action_label": "User proceeded",
                },
            },
        ],
    },
    "user_bob": {
        "balance": 2200.00,
        "monthly_rent": 1400.00,
        "bills": [
            {"name": "Rent", "amount": 1400, "due_in_days": 7},
            {"name": "Car Payment", "amount": 300, "due_in_days": 5},
        ],
        "active_bnpls": 1,
        "active_bnpl_amount": 200.00,
        "late_bnpl_payments": 1,
        "transactions": [
            # --- Current month ---
            {
                "merchant": "CHEVRON",
                "amount": -65.00,
                "date": _d(0, 16),
                "category": "Fuel & Tolls",
            },
            {
                "merchant": "MCDONALD'S",
                "amount": -8.50,
                "date": _d(0, 16),
                "category": "Restaurants & Bars",
            },
            {
                "merchant": "AUTOZONE",
                "amount": -42.30,
                "date": _d(0, 14),
                "category": "Home & General",
            },
            {
                "merchant": "WALMART",
                "amount": -156.80,
                "date": _d(0, 12),
                "category": "Groceries",
            },
            {
                "merchant": "CHEVRON",
                "amount": -58.00,
                "date": _d(0, 10),
                "category": "Fuel & Tolls",
            },
            {
                "merchant": "HOME DEPOT",
                "amount": -87.50,
                "date": _d(0, 8),
                "category": "Maintenance & Decor",
            },
            {
                "merchant": "LANDLORD PMT",
                "amount": -1400.00,
                "date": _d(0, 1),
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "CAR LOAN PMT",
                "amount": -300.00,
                "date": _d(0, 1),
                "category": "Debt & Loans",
            },
            {
                "merchant": "EMPLOYER DIRECT",
                "amount": 4800.00,
                "date": _d(0, 1),
                "category": "Salary",
            },
            {
                "merchant": "AT&T",
                "amount": -95.00,
                "date": _d(0, 1),
                "category": "Internet & Phone",
            },
            {
                "merchant": "WALMART",
                "amount": -92.30,
                "date": _d(0, 5),
                "category": "Groceries",
            },
            {
                "merchant": "DRAFTKINGS",
                "amount": -50.00,
                "date": _d(0, 7),
                "category": "Hobbies & Gaming",
            },
            # --- Previous month ---
            {
                "merchant": "LANDLORD PMT",
                "amount": -1400.00,
                "date": _d(-1, 1),
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "CAR LOAN PMT",
                "amount": -300.00,
                "date": _d(-1, 1),
                "category": "Debt & Loans",
            },
            {
                "merchant": "EMPLOYER DIRECT",
                "amount": 4800.00,
                "date": _d(-1, 1),
                "category": "Salary",
            },
            {
                "merchant": "CHEVRON",
                "amount": -55.00,
                "date": _d(-1, 20),
                "category": "Fuel & Tolls",
            },
            {
                "merchant": "WALMART",
                "amount": -134.50,
                "date": _d(-1, 15),
                "category": "Groceries",
            },
            {
                "merchant": "MCDONALD'S",
                "amount": -12.00,
                "date": _d(-1, 10),
                "category": "Restaurants & Bars",
            },
            {
                "merchant": "AT&T",
                "amount": -95.00,
                "date": _d(-1, 1),
                "category": "Internet & Phone",
            },
            # --- Two months ago ---
            {
                "merchant": "LANDLORD PMT",
                "amount": -1400.00,
                "date": _d(-2, 1),
                "category": "Rent & Mortgage",
            },
            {
                "merchant": "EMPLOYER DIRECT",
                "amount": 4800.00,
                "date": _d(-2, 1),
                "category": "Salary",
            },
            {
                "merchant": "CHEVRON",
                "amount": -50.00,
                "date": _d(-2, 18),
                "category": "Fuel & Tolls",
            },
            {
                "merchant": "WALMART",
                "amount": -120.00,
                "date": _d(-2, 12),
                "category": "Groceries",
            },
            {
                "merchant": "AT&T",
                "amount": -95.00,
                "date": _d(-2, 1),
                "category": "Internet & Phone",
            },
        ],
        "warnings_history": [
            {
                "id": "warn_b001",
                "timestamp": _ts(0, 14, 13, 0),
                "source": "bnpl",
                "risk_level": "HIGH",
                "title": "BNPL risk critical",
                "message": "You have a late BNPL payment and 1 active plan. Adding another is high-risk.",
                "context": {
                    "bnpl_score": 78,
                    "payment_amount": 42.30,
                    "merchant": "AUTOZONE",
                    "num_payments": 3,
                    "monthly_payment": 14.10,
                    "risk_factors": ["1 late BNPL payment", "1 active BNPL plan"],
                },
                "outcome": {
                    "user_action": "cancelled",
                    "action_label": "User cancelled",
                },
            },
            {
                "id": "warn_b002",
                "timestamp": _ts(0, 8, 11, 30),
                "source": "cash_flow",
                "risk_level": "MEDIUM",
                "title": "Large purchase impacts bill coverage",
                "message": "This $87.50 at HOME DEPOT reduces your safety buffer. Rent ($1,400) is due in 23 days.",
                "context": {
                    "payment_amount": 87.50,
                    "merchant": "HOME DEPOT",
                    "projected_balance": 1812.50,
                    "triggering_bill": {
                        "name": "Rent",
                        "amount": 1400.00,
                        "due_in_days": 23,
                    },
                },
                "outcome": {
                    "user_action": "proceeded",
                    "action_label": "User proceeded anyway",
                },
            },
            {
                "id": "warn_b003",
                "timestamp": _ts(-1, 20, 9, 0),
                "source": "cash_flow",
                "risk_level": "MEDIUM",
                "title": "Fuel spending above average",
                "message": "Your fuel spending this month is 15% above your 3-month average.",
                "context": {
                    "payment_amount": 55.00,
                    "merchant": "CHEVRON",
                    "projected_balance": 2400.00,
                },
                "outcome": {
                    "user_action": "proceeded",
                    "action_label": "User proceeded anyway",
                },
            },
        ],
    },
}

# ---------------------------------------------------------------------------
# Supabase client (lazy)
# ---------------------------------------------------------------------------
_supabase_client = None


def _get_supabase():
    global _supabase_client
    if _supabase_client is not None:
        return _supabase_client
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    if not url or not key:
        return None
    try:
        from supabase import create_client

        _supabase_client = create_client(url, key)
        return _supabase_client
    except ImportError:
        return None


# ---------------------------------------------------------------------------
# Plaid client (lazy — only if user has a token in Supabase)
# ---------------------------------------------------------------------------
def _get_plaid_access_token(user_id: str) -> str | None:
    """Returns Plaid access_token for user if they've connected their bank, else None."""
    sb = _get_supabase()
    if not sb:
        return None
    try:
        res = (
            sb.table("plaid_tokens")
            .select("access_token")
            .eq("user_id", user_id)
            .execute()
        )
        if res.data:
            return res.data[0]["access_token"]
    except Exception:
        pass
    return None


def _get_plaid_client():
    try:
        from services.banking.plaid_client import get_plaid_client

        return get_plaid_client()
    except Exception:
        return None


# ---------------------------------------------------------------------------
# HELPER: convert calendar due_day → due_in_days from today
# ---------------------------------------------------------------------------
def _days_until(due_day: int) -> int:
    today = date.today()
    candidate = today.replace(day=due_day)
    if candidate < today:
        if today.month == 12:
            candidate = candidate.replace(year=today.year + 1, month=1)
        else:
            candidate = candidate.replace(month=today.month + 1)
    return (candidate - today).days


def _using_supabase() -> bool:
    return _get_supabase() is not None


# ===========================================================================
# PUBLIC API  ←  Martín and Mahi only import these
# ===========================================================================


def get_balance(user_id: str) -> float:
    """
    Returns current account balance for the user.

    Source priority: Plaid → Supabase → Local mock

    >>> get_balance("user_marcus")
    1600.0
    """
    # 1. Try Plaid (real bank connection)
    access_token = _get_plaid_access_token(user_id)
    if access_token:
        try:
            from plaid.model.accounts_get_request import AccountsGetRequest

            client = _get_plaid_client()
            response = client.accounts_get(
                AccountsGetRequest(access_token=access_token)
            )
            accounts = response["accounts"]
            if accounts:
                # Return sum of all depository (checking/savings) account balances
                total = sum(
                    float(a["balances"]["current"] or 0)
                    for a in accounts
                    if a["type"] == "depository"
                )
                return total
        except Exception as e:
            log.failure(
                "get_balance",
                error_type=type(e).__name__,
                message=str(e),
                user_id=user_id,
                detail="Plaid API failed, falling back",
            )

    # 2. Try Supabase
    sb = _get_supabase()
    if sb:
        res = sb.table("accounts").select("balance").eq("user_id", user_id).execute()
        if res.data:
            return float(res.data[0]["balance"])
        raise ValueError(f"Unknown user: {user_id}")

    # 3. Local mock fallback
    if user_id not in LOCAL_MOCK_DATA:
        raise ValueError(f"Unknown user: {user_id}")
    return LOCAL_MOCK_DATA[user_id].get("balance", 0.0)


def get_upcoming_bills(user_id: str, days_ahead: int = 7) -> List[Dict[str, Any]]:
    """
    Returns bills due within the next `days_ahead` days.

    Return format:
        [{"name": "Rent", "amount": 1500.00, "due_in_days": 3}, ...]

    Note: Bills always come from Supabase (Plaid doesn't provide bill data).

    >>> bills = get_upcoming_bills("user_marcus", days_ahead=7)
    >>> any(b["name"] == "Rent" for b in bills)
    True
    """
    sb = _get_supabase()
    if sb:
        res = (
            sb.table("bills")
            .select("name, amount, due_day")
            .eq("user_id", user_id)
            .execute()
        )
        upcoming = []
        for bill in res.data:
            due_in = _days_until(bill["due_day"])
            if due_in <= days_ahead:
                upcoming.append(
                    {
                        "name": bill["name"],
                        "amount": float(bill["amount"]),
                        "due_in_days": due_in,
                    }
                )
        return upcoming

    all_bills = LOCAL_MOCK_DATA.get(user_id, {}).get("bills", [])
    return [b for b in all_bills if b["due_in_days"] <= days_ahead]


def get_transactions(user_id: str, days_back: int = 30) -> List[Dict[str, Any]]:
    """
    Returns recent transactions for the user.

    Source priority: Plaid → Supabase → Local mock

    Return format:
        [{"merchant": "STARBUCKS", "amount": -4.50, "date": "2026-03-17", "category": "Food & Drink"}, ...]

    >>> txns = get_transactions("user_marcus")
    >>> len(txns) > 0
    True
    """
    # 1. Try Plaid
    access_token = _get_plaid_access_token(user_id)
    if access_token:
        try:
            from plaid.model.transactions_get_request import TransactionsGetRequest
            from plaid.model.transactions_get_request_options import (
                TransactionsGetRequestOptions,
            )

            start_date = date.today() - timedelta(days=days_back)
            end_date = date.today()

            client = _get_plaid_client()
            response = client.transactions_get(
                TransactionsGetRequest(
                    access_token=access_token,
                    start_date=start_date,
                    end_date=end_date,
                    options=TransactionsGetRequestOptions(count=100),
                )
            )

            return [
                {
                    "merchant": t.get("merchant_name") or t.get("name", "Unknown"),
                    "amount": -abs(
                        float(t["amount"])
                    ),  # Plaid uses positive = debit, we flip
                    "date": str(t["date"]),
                    "category": (
                        t["category"][0] if t.get("category") else "Uncategorized"
                    ),
                }
                for t in response["transactions"]
            ]
        except Exception as e:
            log.failure(
                "get_transactions",
                error_type=type(e).__name__,
                message=str(e),
                user_id=user_id,
                detail="Plaid API failed, falling back",
            )

    # 2. Try Supabase
    sb = _get_supabase()
    if sb:
        try:
            # Find account_id for this user
            acct_res = (
                sb.table("accounts").select("id").eq("user_id", user_id).execute()
            )
            if not acct_res.data:
                raise ValueError(f"Unknown user: {user_id}")
            account_id = acct_res.data[0]["id"]

            since = str(date.today() - timedelta(days=days_back))
            txn_res = (
                sb.table("transactions")
                .select("merchant_name, amount, date")
                .eq("account_id", account_id)
                .gte("date", since)
                .order("date", desc=True)
                .execute()
            )
            return [
                {
                    "merchant": t["merchant_name"],
                    "amount": float(t["amount"]),
                    "date": t["date"],
                    "category": "Uncategorized",  # Categories come in future sprint
                }
                for t in txn_res.data
            ]
        except ValueError:
            raise
        except Exception as e:
            log.failure(
                "get_transactions",
                error_type=type(e).__name__,
                message=str(e),
                user_id=user_id,
                detail="Supabase query failed, falling back to local mock",
            )

    # 3. Local mock
    if user_id not in LOCAL_MOCK_DATA:
        raise ValueError(f"Unknown user: {user_id}")
    txns = LOCAL_MOCK_DATA[user_id].get("transactions", [])
    cutoff = str(date.today() - timedelta(days=days_back))
    return [t for t in txns if t["date"] >= cutoff]


def count_active_bnpls(user_id: str) -> int:
    """
    Returns number of active BNPLs for the user.

    >>> count_active_bnpls("user_marcus")
    2
    """
    sb = _get_supabase()
    if sb:
        res = (
            sb.table("bnpls")
            .select("id", count="exact")
            .eq("user_id", user_id)
            .neq("status", "completed")
            .execute()
        )
        return res.count or 0
    return LOCAL_MOCK_DATA.get(user_id, {}).get("active_bnpls", 0)


def get_active_bnpl_amount(user_id: str) -> float:
    """
    Returns total outstanding BNPL amount for the user.

    >>> get_active_bnpl_amount("user_marcus")
    350.0
    """
    sb = _get_supabase()
    if sb:
        res = (
            sb.table("bnpls")
            .select("remaining_amount")
            .eq("user_id", user_id)
            .neq("status", "completed")
            .execute()
        )
        return sum(row["remaining_amount"] for row in (res.data or []))
    return LOCAL_MOCK_DATA.get(user_id, {}).get("active_bnpl_amount", 0.0)


def count_late_bnpl_payments(user_id: str) -> int:
    """
    Returns number of BNPLs with 'late' status for the user.

    >>> count_late_bnpl_payments("user_bob")
    1
    """
    sb = _get_supabase()
    if sb:
        res = (
            sb.table("bnpls")
            .select("id", count="exact")
            .eq("user_id", user_id)
            .eq("status", "late")
            .execute()
        )
        return res.count or 0
    return LOCAL_MOCK_DATA.get(user_id, {}).get("late_bnpl_payments", 0)


def get_warnings_history(user_id: str, limit: int = 10) -> List[Dict[str, Any]]:
    """
    Returns risk warning history for the user, newest first.

    Source priority: Supabase → Local mock

    Return format:
        [{"id": "warn_001", "timestamp": "...", "source": "cash_flow",
          "risk_level": "HIGH", "title": "...", "message": "...",
          "context": {...}, "outcome": {...}}, ...]

    >>> warnings = get_warnings_history("user_marcus", limit=5)
    >>> len(warnings) > 0
    True
    """
    sb = _get_supabase()
    if sb:
        try:
            res = (
                sb.table("warnings_history")
                .select("*")
                .eq("user_id", user_id)
                .order("timestamp", desc=True)
                .limit(limit)
                .execute()
            )
            return res.data if res.data else []
        except Exception as e:
            log.failure(
                "get_warnings_history",
                error_type=type(e).__name__,
                message=str(e),
                user_id=user_id,
                detail="Supabase query failed, falling back",
            )

    # Local mock
    if user_id not in LOCAL_MOCK_DATA:
        raise ValueError(f"Unknown user: {user_id}")
    warnings = LOCAL_MOCK_DATA[user_id].get("warnings_history", [])
    sorted_warnings = sorted(warnings, key=lambda w: w["timestamp"], reverse=True)
    return sorted_warnings[:limit]
