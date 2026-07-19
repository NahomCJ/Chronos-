"""
services/insights/spending_analytics.py
========================================
DEPRECATED — this module existed as a backwards-compat shim.

All logic now lives in dedicated modules:
  - services.insights.spending_summary  → compute_spending_summary
  - services.insights.top_categories    → compute_top_categories
  - services.insights.warnings          → compile_warnings_history
  - services.insights.helpers           → _pct, _direction
"""
