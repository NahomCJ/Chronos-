"""Liabilities service exports.

Imports are resolved lazily so callers can import one submodule without forcing
all liability analyzers to load. This keeps cross-lane services from blocking on
unrelated modules during test collection and local development.
"""

from __future__ import annotations

__all__ = [
    "LiabilitiesConsentError",
    "analyze_credit_cards",
    "analyze_loans",
    "analyze_mortgage",
    "calculate_dti",
    "sync_liabilities",
]


def __getattr__(name: str):
    if name == "analyze_credit_cards":
        from .credit_card import analyze_credit_cards

        return analyze_credit_cards
    if name == "calculate_dti":
        from .dti_calculator import calculate_dti

        return calculate_dti
    if name in {"LiabilitiesConsentError", "sync_liabilities"}:
        from .ingestion import LiabilitiesConsentError, sync_liabilities

        return {
            "LiabilitiesConsentError": LiabilitiesConsentError,
            "sync_liabilities": sync_liabilities,
        }[name]
    if name == "analyze_loans":
        from .loans import analyze_loans

        return analyze_loans
    if name == "analyze_mortgage":
        from .mortgage import analyze_mortgage

        return analyze_mortgage
    raise AttributeError(name)
