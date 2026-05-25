# TASK: Generate Dashboard UI with Google Stitch MCP

### Martín - The Visual Architect (4-6h)
**Your Role:** Turn the chart-ready API responses into production-quality UI designs using Google Stitch, so the frontend team can implement pixel-perfect dashboards without guessing.

---

## Context

The backend is **done**. Three endpoints return chart-ready JSON — pre-sorted, pre-colored, WCAG AA compliant. Now we need the frontend UI designs that consume this data.

**Google Stitch** (stitch.withgoogle.com) is a design tool with an MCP server (`@_davideast/stitch-mcp`) already configured in `.mcp.json`. It generates UI designs from prompts, and we'll feed it our exact API response shapes so the designs match the data contract 1:1.

---

## What to Build

Use Google Stitch MCP to generate 3 dashboard screens:

### Screen 1: Spending Summary Dashboard
**Data source:** `GET /api/insights/spending-summary?user_id=user_marcus&month=2&year=2025`

**Must include these visualizations:**
1. **Donut chart** — Category breakdown (`by_category`). Colors from `color` field. Labels = `category_name + percentage%`.
2. **Line chart (cumulative)** — Daily spending over the month (`daily_series`). X-axis = dates. Y-axis = `cumulative` values. Weekend dates shaded.
3. **Bar chart** — Day-of-week spending pattern (`day_of_week_pattern`). Mon-Sun, Y = `average`.
4. **Summary cards** at top — `total_spent`, `total_income`, `net_cash_flow`, `daily_average`. Each shows `vs_previous_month.direction` arrow (green ↓ = good for spending, red ↑ = bad).
5. **Category drill-down** — Expandable list showing subcategories, top merchants (max 3), and MoM delta per category.

**Key data contract (from `models.py`):**
```python
SpendingSummaryResponse:
  meta: SpendingSummaryMeta  # user_id, period, currency
  summary: SpendingSummary   # total_spent, total_income, net_cash_flow, vs_previous_month
  by_category: list[CategoryBreakdown]  # sorted desc, each has color, icon, subcategories, top_merchants
  daily_series: list[DailyEntry]        # date, total, cumulative, day_of_week, is_weekend
  day_of_week_pattern: list[DayOfWeekEntry]  # day, average, total
```

### Screen 2: Top Categories
**Data source:** `GET /api/insights/top-categories?user_id=user_marcus&days=30`

**Must include these visualizations:**
1. **Ranked cards (1-5)** — Each card: category name, amount, percentage, sparkline from `trend.spark` (3 months), trend arrow (`trend.direction`). Background tinted with `color`.
2. **"Other" row** — Collapsed summary of remaining categories (`other_categories.count`, `other_categories.amount`).
3. **Insight banners** — AI-generated observations from `insights[]`. Warning-severity = yellow banner, info = blue.
4. **Recurring badge** — Categories where `is_recurring_dominant=true` get a "Recurring" chip.

**Key data contract:**
```python
TopCategoriesResponse:
  total_spent: float
  top_categories: list[TopCategory]  # rank, amount, percentage, color, icon, trend.spark, is_recurring_dominant
  other_categories: OtherCategories  # count, amount, percentage
  insights: list[Insight]            # type, severity, message, icon
```

### Screen 3: Warnings History
**Data source:** `GET /api/insights/warnings-history?user_id=user_marcus&limit=10&offset=0`

**Must include these visualizations:**
1. **Risk summary strip** — 3 colored pills: HIGH (red `#E53E3E`), MEDIUM (yellow `#ECC94B`), LOW (green `#38A169`). Each shows count + percentage.
2. **Warning timeline** — Vertical list, newest first. Each entry: `date_label`, `title`, `message`, colored left border = `risk_color`, icon = `risk_icon`.
3. **Calendar heatmap** — Month grid from `calendar_heatmap[]`. Cell intensity = `warning_count`. Hover = `max_severity`.
4. **By-source breakdown** — Small horizontal bar chart from `risk_summary.by_source` (e.g., "cash_flow: 3, bnpl: 2").
5. **Pagination** — "Load more" button when `pagination.has_more = true`.

**Key data contract:**
```python
WarningsHistoryResponse:
  risk_summary: RiskSummary    # by_level (with colors), by_source, trend_last_30d
  warnings: list[WarningEntry] # id, timestamp, date_label, risk_level, risk_color, title, message
  calendar_heatmap: list[CalendarHeatmapEntry]  # date, warning_count, max_severity
  meta.pagination: PaginationMeta  # limit, offset, total, has_more
```

---

## Design Requirements

| Requirement | Detail |
|-------------|--------|
| **Target** | Tier-1 US national bank (Chase/Amex level) |
| **Style** | Clean, minimal, whitespace-heavy. No gradients. Flat colors. |
| **Colors** | Use EXACTLY the hex codes from the API `color` fields. Defined in `services/insights/constants.py` |
| **Typography** | System font stack. Numbers = tabular lining. Currency = 2 decimal places. |
| **Accessibility** | WCAG AA contrast. Colors already pass — don't modify them. |
| **Responsive** | Desktop-first, but cards should stack on mobile. |
| **Dark mode** | Not required for MVP. Design light-only. |

---

## WCAG AA Color Palette (from `constants.py`)

```python
CATEGORY_COLORS = {
    "cat_food_drink":            "#E07C5A",  # Warm Terracotta
    "cat_transport":             "#5B9BD5",  # Steel Blue
    "cat_travel":                "#3AAFA9",  # Teal
    "cat_health_wellbeing":      "#5AAD7A",  # Fresh Green
    "cat_shopping":              "#D4A843",  # Rich Gold
    "cat_home_utilities":        "#4A90D9",  # Deep Sky
    "cat_entertainment_leisure": "#9B6BB0",  # Soft Purple
    "cat_personal":              "#C97B84",  # Dusty Rose
    "cat_family":                "#E8A87C",  # Peach
    "cat_pets":                  "#6B8EC2",  # Slate Blue
    "cat_financial_services":    "#4A7C59",  # Forest Green
    "cat_cash":                  "#8B7355",  # Bronze
    "cat_income":                "#38A169",  # Green (positive)
    "cat_uncategorized":         "#95A5A6",  # Neutral Gray
}

RISK_COLORS = {
    "HIGH":   "#E53E3E",
    "MEDIUM": "#ECC94B",
    "LOW":    "#38A169",
}
```

---

## MCP Setup (one-time, on your Mac)

The MCP config is already in `.mcp.json`:
```json
{
  "mcpServers": {
    "stitch": {
      "command": "npx",
      "args": ["@_davideast/stitch-mcp", "proxy"]
    }
  }
}
```

**Before starting:**
1. Run `npx @_davideast/stitch-mcp init` to authenticate with Google (OAuth, one-time)
2. Verify MCP connects by checking for the `stitch` tool in your Claude Code session
3. Use the Stitch MCP `create_design` / `generate_ui` tools with the prompts below

---

## Stitch Prompts (copy-paste ready)

### Prompt 1: Spending Summary
```
Design a fintech dashboard screen for a tier-1 US bank app. The screen shows a monthly spending summary.

Layout (top to bottom):
1. Header: "February 2025" with month navigation arrows
2. Summary cards row: Total Spent ($2,699.40 ↑23%), Income ($5,200.00), Net Cash Flow ($2,500.60), Daily Avg ($96.41)
3. Left: Donut chart — category breakdown. Use these exact colors: Home & Utilities #4A90D9 (63%), Food & Drink #E07C5A (13%), Shopping #D4A843 (10%), Transportation #5B9BD5 (7%), Entertainment #9B6BB0 (4%), Other #95A5A6 (3%)
4. Right: Cumulative line chart — daily spending over Feb 2025. Shaded weekends.
5. Bottom: Day-of-week bar chart (Mon-Sun). Show daily average per weekday.
6. Category list below: expandable rows with subcategories, top 3 merchants, and month-over-month change.

Style: Chase/Amex-level banking app. Clean, minimal, whitespace-heavy. WCAG AA accessible. Light theme only.
```

### Prompt 2: Top Categories
```
Design a "Top Categories" screen for a tier-1 US bank fintech app.

Layout:
1. Header: "Top Categories — Last 30 days" with total spent ($2,699.40)
2. Five ranked cards (1-5), each showing: rank number, category icon, category name, amount, percentage, a 3-month sparkline trend, and trend direction (↑↗→↘↓). Background tinted with category color at 10% opacity.
3. Categories with "Recurring" badge get a small chip/tag.
4. Below top 5: collapsed "Other (3 categories, $200.00, 7.4%)" expandable row.
5. AI Insight banners at bottom: yellow for warnings ("63% of spending goes to Home & Utilities"), blue for info.

Colors: Home & Utilities #4A90D9, Food & Drink #E07C5A, Shopping #D4A843, Transportation #5B9BD5, Entertainment #9B6BB0.
Style: Chase/Amex banking. Clean, flat, professional.
```

### Prompt 3: Warnings History
```
Design a "Risk Warnings" screen for a tier-1 US bank fintech app.

Layout:
1. Risk summary strip: three colored pills — HIGH (2, 40%, red #E53E3E), MEDIUM (2, 40%, yellow #ECC94B), LOW (1, 20%, green #38A169)
2. Warning timeline: vertical list, newest first. Each entry has: date label ("Feb 17"), title, description, colored left border matching risk level, and a small icon.
3. Right sidebar: calendar heatmap for the current month. Each day cell colored by warning count intensity. Tooltip shows severity.
4. Bottom bar chart: warnings by source — "Cash Flow: 3" and "BNPL: 2" as horizontal bars.
5. "Load more" button at bottom (pagination).

Style: Chase/Amex banking. Clean, professional, light theme. WCAG AA.
```

---

## Phase Progression

```python
# Phase 1: Generate UI designs via Stitch MCP (this task)
# Input: API response schemas from models.py + sample data from mock_api
# Output: 3 Stitch-generated UI screens

# Phase 2: Frontend implementation (future sprint)
# Input: Stitch designs + API contracts
# Output: React/Next.js components consuming real endpoints
```

---

## Deliverables

- [ ] 3 Stitch UI designs (spending-summary, top-categories, warnings-history)
- [ ] Screenshots saved to `docs/PantherAI/insights/designs/`
- [ ] Design notes: any deviations from the prompt (colors, layout adjustments)

## Before PR

- [ ] **Remove API key from `.mcp.json`** — the Stitch API key was added inline during setup. Move it to `.env` (e.g. `STITCH_API_KEY=...`) and reference via env var, or remove it entirely before committing. Do NOT merge a raw API key into the repo.

## Done When

- [ ] All 3 screens generated and saved
- [ ] Colors match the WCAG AA palette from `constants.py` exactly
- [ ] Every data field from the API response is represented in the UI
- [ ] A frontend developer can look at the design + API docs and build it without asking questions
- [ ] Screenshots committed to `docs/PantherAI/insights/designs/`
