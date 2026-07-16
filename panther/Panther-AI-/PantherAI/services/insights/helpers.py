"""
services/insights/helpers.py
==============================
Shared utility functions for the Dashboard Insights API modules.
"""

from __future__ import annotations

from datetime import date


def _parse_date(d: str) -> date:
    return date.fromisoformat(d)


def _direction(delta: float) -> str:
    if delta > 0:
        return "increased"
    if delta < 0:
        return "decreased"
    return "unchanged"


def _pct(part: float, whole: float) -> float:
    if whole == 0:
        return 0.0
    return round(part / whole * 100, 1)
