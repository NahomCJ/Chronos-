# Design Notes — Stitch UI Generation (Mobile)

Tracks deviations between the Stitch prompts and the generated output.
Generated via Google Stitch MCP on 2026-03-30.
Project ID: `2200865661768545827` on stitch.withgoogle.com.
Design system: **Sovereign Blue / The Architectural Ledger**
Device: **Mobile** (single column, bottom tab nav)

---

## Screen 1: Spending Summary

| Element | Expected | Actual | Deviation |
|---------|----------|--------|-----------|
| Summary cards (4) | total_spent, income, net_cash_flow, daily_avg | All 4 present: $2,699.40 (+23%), $5,200.00, $2,500.60, $96.41 | Match |
| Donut chart | Category breakdown with exact hex colors | Present with "$2.7k" center label. Colors close to spec — design system embedded our exact hex codes (#4A90D9, #E07C5A, #D4A843, #5B9BD5, #9B6BB0, #95A5A6) | Match — Stitch used our colors in the "Ledger Palette" |
| Line chart | Cumulative spending, shaded weekends | "Spending Over Time" line chart present | Weekends not visibly shaded |
| Bar chart | Mon-Sun averages | "Daily Average Distribution" bar chart present | Match |
| Category list | Expandable rows, merchants, MoM delta | Shows Home & Mortgage ($1,700.62), Food & Dining ($350.92), Shopping ($269.94) | Match — tappable cards |
| Bottom tab bar | Overview, Transactions, Analytics, Kevin, Profile | 5-tab bar present | Match |

## Screen 2: Top Categories

| Element | Expected | Actual | Deviation |
|---------|----------|--------|-----------|
| Total spent header | $2,699.40 | Shown prominently | Match |
| AI Insight banners | Yellow warning + blue info | Both present at top: "63% of spending goes to Home and Utilities" (amber) + "Transportation costs decreased by 6%" (blue) | Match — placed at top instead of bottom |
| Ranked cards (1-5) | Color tint at 10% opacity | All 5 categories with tinted backgrounds and rank numbers | Match |
| Recurring badge | Chip on Home & Utilities | "RECURRING" badge visible on card #1 | Match |
| Sparkline trends | 3-month spark | Trend arrows visible on cards | Sparklines not visible — shows percentage trends instead |
| Other row | Collapsed, expandable | "Other - 3 categories" with $200.00 and 7.4%, expand chevron | Match |
| Bottom tab bar | 5 tabs | Present with Analytics highlighted | Match |

## Screen 3: Warnings History

| Element | Expected | Actual | Deviation |
|---------|----------|--------|-----------|
| Risk pills | HIGH #E53E3E, MEDIUM #ECC94B, LOW #38A169 | 3 colored segments/pills showing distribution | Match — uses correct risk colors |
| Warning timeline | Colored left border, date labels | 5 entries visible: Anomalous Cash Withdrawal (red), BNPL Delinquency (yellow), Unusual Spending Pattern (red), Low Balance Alert (yellow), Policy Violation (green) | Match — all entries with colored borders and date labels |
| Calendar heatmap | Feb 2025 grid, intensity coloring | "February Summary" calendar grid with colored cells | Match |
| By-source bar chart | Cash Flow: 3, BNPL: 2 | Horizontal bars: "Cash Flow 3 events" and "BNPL 2 events" | Match |
| Pagination | "Load more" button | "Load More Warnings" button at bottom | Match |
| Bottom tab bar | 5 tabs | Present | Match |

---

## Global Notes

1. **Design system consistency**: All 3 screens use the same "Sovereign Blue" design system. Our exact category hex codes from `constants.py` are embedded in the design system as "The Ledger Palette".

2. **Risk colors**: The warnings screen uses the correct risk colors (#E53E3E, #ECC94B, #38A169).

3. **Typography**: Manrope (headlines/display) + Inter (body/UI). Stitch added `font-variant-numeric: tabular-nums` for financial figures.

4. **Layout**: Pure mobile single-column with bottom tab navigation (Overview, Transactions, Analytics, Kevin, Profile).

5. **Minor deviations**:
   - Sparkline trends on Top Categories show arrows instead of mini charts
   - AI insight banners placed at top of screen instead of bottom
   - Weekend shading on line chart not visually distinct

---

## Color Reference (from `services/insights/constants.py`)

**Category colors:**
- Food & Drink: `#E07C5A` | Shopping: `#D4A843` | Transportation: `#5B9BD5`
- Entertainment: `#9B6BB0` | Home & Utilities: `#4A90D9` | Other: `#95A5A6`

**Risk colors:**
- HIGH: `#E53E3E` | MEDIUM: `#ECC94B` | LOW: `#38A169`
