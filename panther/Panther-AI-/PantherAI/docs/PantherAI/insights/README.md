# Dashboard Insights API [LIVE]

**Responsibility:** Transforms raw transaction and warning data into chart-ready JSON responses for tier-1 bank-quality dashboard visualizations (spending breakdowns, category trends, risk timelines).
**Depends on:** `services/banking/mock_api.py` (`get_transactions`, `get_warnings_history`), `services/TC-TransactionClassifier/classifier/taxonomy.py` (category/subcategory definitions)

## Contracts

### `GET /api/insights/spending-summary`

**Input:**
```
?user_id=user_marcus&month=2&year=2026
```
**Output:**
```json
{
  "meta": {"user_id": "user_marcus", "period": {"month": 2, "year": 2026, "label": "February 2026"}, "currency": "USD"},
  "summary": {"total_spent": 2699.40, "total_income": 5200.00, "net_cash_flow": 2500.60, "transaction_count": 25, "daily_average": 96.41, "vs_previous_month": {"total_spent_delta": 586.53, "total_spent_delta_pct": 27.8, "direction": "increased"}},
  "by_category": [{"category_id": "cat_home_utilities", "category_name": "Home & Utilities", "amount": 1699.99, "percentage": 63.0, "color": "#4A90D9", "icon": "home", "rank": 1, "subcategories": [...], "top_merchants": [...], "vs_previous_month": {"amount_delta": 0.0, "amount_delta_pct": 0.0, "direction": "unchanged"}}],
  "daily_series": [{"date": "2026-02-01", "total": 1804.98, "cumulative": 1804.98, "day_of_week": "Saturday", "is_weekend": true}],
  "day_of_week_pattern": [{"day": "Monday", "day_index": 0, "average": 98.40, "total": 393.60}]
}
```

### `GET /api/insights/top-categories`

**Input:**
```
?user_id=user_marcus&days=30
```
**Output:**
```json
{
  "meta": {"user_id": "user_marcus", "period": {"days": 30, "label": "Last 30 days"}, "currency": "USD"},
  "total_spent": 2699.40,
  "top_categories": [{"rank": 1, "category_id": "cat_home_utilities", "amount": 1699.99, "percentage": 63.0, "color": "#4A90D9", "trend": {"direction": "stable", "spark": [1699.99, 1699.99, 1699.99], "periods": ["Jan 2025", "Feb 2025", "Mar 2025"]}, "is_recurring_dominant": true}],
  "other_categories": {"count": 3, "amount": 200.00, "percentage": 7.4},
  "insights": [{"type": "concentration", "severity": "warning", "message": "63.0% of your spending goes to Home & Utilities. Mostly recurring bills."}]
}
```

### `GET /api/insights/warnings-history`

**Input:**
```
?user_id=user_marcus&limit=10&offset=0
```
**Output:**
```json
{
  "meta": {"user_id": "user_marcus", "pagination": {"limit": 10, "offset": 0, "total": 5, "has_more": false}},
  "risk_summary": {"total_warnings": 5, "by_level": {"HIGH": {"count": 2, "percentage": 40.0, "color": "#E53E3E"}, "MEDIUM": {"count": 2, "percentage": 40.0, "color": "#ECC94B"}, "LOW": {"count": 1, "percentage": 20.0, "color": "#38A169"}}, "by_source": {"cash_flow": 3, "bnpl": 2}},
  "warnings": [{"id": "warn_m001", "timestamp": "2025-02-17T14:30:00Z", "date_label": "Feb 17", "source": "cash_flow", "risk_level": "HIGH", "risk_color": "#E53E3E", "title": "High-risk payment attempted", "message": "...", "context": {...}, "outcome": {"user_action": "proceeded"}}],
  "calendar_heatmap": [{"date": "2025-02-01", "warning_count": 0, "max_severity": null}]
}
```

**Raises (all endpoints):**
- `HTTPException(404)` — unknown `user_id` (bubbled from `mock_api`)

## WCAG AA Color Palette

Category colors are assigned server-side in `services/insights/constants.py`. Single source of truth for all platforms.

| Category | Hex | Use |
|----------|-----|-----|
| Food & Drink | `#E07C5A` | Donut chart, category cards |
| Shopping | `#D4A843` | Donut chart, category cards |
| Transport | `#5B9BD5` | Donut chart, category cards |
| Entertainment & Leisure | `#9B6BB0` | Donut chart, category cards |
| Home & Utilities | `#4A90D9` | Donut chart, category cards |
| Health & Wellbeing | `#5AAD7A` | Donut chart, category cards |
| HIGH risk | `#E53E3E` | Warning pills, timeline borders |
| MEDIUM risk | `#ECC94B` | Warning pills, timeline borders |
| LOW risk | `#38A169` | Warning pills, timeline borders |

Subcategory colors are computed as lighter variants of the parent (see `get_subcategory_color()`).

## Architecture

```
routers/insights/
  router.py          — 3 GET endpoints (FastAPI, @contract decorated)
  models.py          — Pydantic response models (auto-generates OpenAPI docs)

services/insights/
  constants.py       — WCAG AA color palette, icons, taxonomy reverse-lookup maps
  spending_analytics.py — Pure computation (no I/O), deterministic, testable
```

Key design: the analytics layer is pure functions. The router fetches data via `mock_api`, passes it to analytics, and returns the result. This separation means analytics functions can be unit-tested without mocking any I/O.

**Fetch optimization:** `spending-summary` calculates the minimum `days_back` (~60 days) to cover target + previous month. `top-categories` fetches `max(days, 90)` for sparklines. Neither fetches more than necessary.

**Anchor-date pattern:** All 3 endpoints anchor "today"/"now" to the latest data timestamp. This makes mock data (which has fixed dates) render correctly regardless of when you call the API. In production (Plaid/Supabase), data is always current, so the anchor equals `date.today()` — a no-op.

## UI Designs

Stitch-generated mobile screens live in `docs/PantherAI/insights/designs/`:
- `spending-summary.png` — Donut chart, line chart, bar chart, category drill-down
- `top-categories.png` — Ranked cards, sparklines, recurring badges, AI insights
- `warnings-history.png` — Risk pills, warning timeline, calendar heatmap

Deviations from prompts are tracked in `designs/design-notes.md`.

## Test Command
```bash
pytest tests/test_insights.py -v
```

114 tests: 72 unit tests (pure computation, edge cases, insight generation) + 21 integration tests (TestClient against all 3 demo users) + 21 constant/helper tests.
