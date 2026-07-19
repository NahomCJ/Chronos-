# Dashboard Insights API

**Responsibility:** Turns raw banking transactions and risk warnings into chart-ready JSON for the mobile dashboard (spending summary, top categories, warnings timeline).

**Depends on:** `services/banking/mock_api.py`, `services/insights/constants.py`, `core/logger.py`, `FastAPI`

## Architecture

```
Router (routers/insights/router.py)
  |-- fetches data via services/insights/data.py (thin wrapper over banking mock API)
  |-- delegates to pure computation functions:
  |     spending_summary.py  (monthly breakdown + daily series)
  |     top_categories.py    (top 5 + sparklines + AI insights)
  |     warnings.py          (risk timeline + calendar heatmap)
  |-- shared helpers: services/insights/helpers.py
  |-- response models: routers/insights/models.py (Pydantic, auto-generates OpenAPI)
```

Computation functions are pure (no I/O). The router owns data fetching and anchor-date logic.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/insights/spending-summary` | Monthly spending with category breakdown, daily series, day-of-week patterns |
| GET | `/api/insights/top-categories` | Top 5 categories with 3-month trend sparklines and AI observations |
| GET | `/api/insights/warnings-history` | Risk warning timeline with severity distribution and calendar heatmap |

## Contracts

**Input (all endpoints):**
```
?user_id=user_marcus  (required, pattern: ^[a-z0-9_]{3,50}$)
```

**Spending Summary** additional params: `&month=3&year=2026`

**Top Categories** additional params: `&days=30` (default 30, 1-365)

**Warnings History** additional params: `&limit=10&offset=0` (pagination)

**Output — Spending Summary:**
```json
{
  "meta": {"user_id": "user_marcus", "period": {"month": 3, "year": 2026, "label": "March 2026", "start_date": "2026-03-01", "end_date": "2026-03-31"}, "currency": "USD"},
  "summary": {"total_spent": 4250.00, "total_income": 8500.00, "net_cash_flow": 4250.00, "transaction_count": 45, "daily_average": 137.10, "vs_previous_month": {"total_spent_delta": -320.50, "direction": "decreased"}},
  "by_category": [{"category_id": "cat_housing", "category_name": "Housing", "amount": 1800.00, "percentage": 42.4, "subcategories": [...], "top_merchants": [...], "vs_previous_month": {...}}],
  "daily_series": [{"date": "2026-03-01", "total": 45.20, "cumulative": 45.20}],
  "day_of_week_pattern": [{"day": "Monday", "average": 120.50, "total": 482.00}]
}
```

**Output — Top Categories:**
```json
{
  "meta": {"user_id": "user_marcus", "period": {"days": 30, "label": "Last 30 days"}},
  "total_spent": 4250.00,
  "top_categories": [{"rank": 1, "category_name": "Housing", "amount": 1800.00, "percentage": 42.4, "trend": {"direction": "stable", "spark": [1750.00, 1800.00, 1800.00]}, "is_recurring_dominant": true}],
  "other_categories": {"count": 3, "amount": 450.00},
  "insights": [{"type": "concentration", "severity": "warning", "message": "42.4% of your spending goes to Housing. Mostly recurring bills."}]
}
```

**Output — Warnings History:**
```json
{
  "meta": {"user_id": "user_marcus", "pagination": {"limit": 10, "offset": 0, "total": 8, "has_more": false}},
  "risk_summary": {"total_warnings": 8, "by_level": {"HIGH": {"count": 2, "percentage": 25.0, "color": "#E53E3E"}}, "trend_last_30d": {"warnings_count": 3, "vs_previous_30d": {"direction": "decreased"}}},
  "warnings": [{"id": "w_001", "date_label": "Today", "risk_level": "HIGH", "title": "Unusual spending detected"}],
  "calendar_heatmap": [{"date": "2026-03-01", "warning_count": 1, "max_severity": "HIGH"}]
}
```

**Error — 404:**
```json
{"detail": "Unknown user: user_xyz"}
```

## Test Command

```bash
pytest tests/test_insights.py -v
```
