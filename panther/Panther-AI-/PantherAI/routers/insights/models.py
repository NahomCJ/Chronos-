"""
routers/insights/models.py
===========================
Pydantic response models for the Dashboard Insights API.

These models auto-generate OpenAPI documentation at /docs.
Every field that appears in the JSON response is typed here.
"""

from __future__ import annotations

from typing import Any, Literal, Optional

from pydantic import BaseModel


# ---------------------------------------------------------------------------
# Shared
# ---------------------------------------------------------------------------


# Two usage patterns share this model:
#   spending-summary → month, year, days_in_period, days_elapsed, label, start_date, end_date
#   top-categories   → days, label, start_date, end_date
# All non-shared fields are Optional so both shapes validate.
class PeriodMeta(BaseModel):
    month: Optional[int] = None
    year: Optional[int] = None
    days: Optional[int] = None
    label: str
    start_date: str
    end_date: str
    days_in_period: Optional[int] = None
    days_elapsed: Optional[int] = None


class PaginationMeta(BaseModel):
    limit: int
    offset: int
    total: int
    has_more: bool


class SummaryDelta(BaseModel):
    total_spent_delta: float
    total_spent_delta_pct: float
    direction: Literal["increased", "decreased", "unchanged"]


class CategoryDelta(BaseModel):
    amount_delta: float
    amount_delta_pct: float
    direction: Literal["increased", "decreased", "unchanged"]


# ---------------------------------------------------------------------------
# Spending Summary
# ---------------------------------------------------------------------------


class TopMerchant(BaseModel):
    merchant: str
    amount: float
    count: int


class SubcategoryBreakdown(BaseModel):
    subcategory_id: str
    subcategory_name: str
    amount: float
    percentage_of_category: float
    percentage_of_total: float
    transaction_count: int
    color: str


class CategoryBreakdown(BaseModel):
    category_id: str
    category_name: str
    amount: float
    percentage: float
    transaction_count: int
    daily_average: float
    color: str
    icon: str
    rank: int
    vs_previous_month: CategoryDelta
    subcategories: list[SubcategoryBreakdown]
    top_merchants: list[TopMerchant]


class DailyEntry(BaseModel):
    date: str
    total: float
    cumulative: float
    day_of_week: str
    is_weekend: bool


class DayOfWeekEntry(BaseModel):
    day: str
    day_index: int
    average: float
    total: float


class SpendingSummary(BaseModel):
    total_spent: float
    total_income: float
    net_cash_flow: float
    transaction_count: int
    daily_average: float
    vs_previous_month: SummaryDelta


class SpendingSummaryMeta(BaseModel):
    user_id: str
    period: PeriodMeta
    currency: str
    generated_at: str


class SpendingSummaryResponse(BaseModel):
    meta: SpendingSummaryMeta
    summary: SpendingSummary
    by_category: list[CategoryBreakdown]
    daily_series: list[DailyEntry]
    day_of_week_pattern: list[DayOfWeekEntry]


# ---------------------------------------------------------------------------
# Top Categories
# ---------------------------------------------------------------------------


class TrendData(BaseModel):
    direction: Literal["increasing", "decreasing", "stable"]
    spark: list[float]
    periods: list[str]
    current_vs_3mo_avg: float
    current_vs_3mo_avg_pct: float


class TopCategory(BaseModel):
    rank: int
    category_id: str
    category_name: str
    amount: float
    percentage: float
    transaction_count: int
    avg_transaction: float
    color: str
    icon: str
    is_recurring_dominant: bool
    trend: TrendData
    budget_status: Optional[Any] = None


class OtherCategories(BaseModel):
    count: int
    amount: float
    percentage: float
    categories: list[dict[str, Any]]


class Insight(BaseModel):
    type: str
    severity: Literal["info", "warning"]
    message: str
    category_id: str
    icon: str


class TopCategoriesMeta(BaseModel):
    user_id: str
    period: PeriodMeta
    currency: str
    generated_at: str


class TopCategoriesResponse(BaseModel):
    meta: TopCategoriesMeta
    total_spent: float
    category_count_total: int
    top_categories: list[TopCategory]
    other_categories: OtherCategories
    insights: list[Insight]


# ---------------------------------------------------------------------------
# Warnings History
# ---------------------------------------------------------------------------


class RiskLevelDetail(BaseModel):
    count: int
    percentage: float
    color: str


class TrendLast30d(BaseModel):
    warnings_count: int
    vs_previous_30d: dict[str, Any]


class RiskSummary(BaseModel):
    total_warnings: int
    by_level: dict[str, RiskLevelDetail]
    by_source: dict[str, int]
    trend_last_30d: TrendLast30d


class WarningEntry(BaseModel):
    id: str
    timestamp: str
    date_label: str
    source: str
    risk_level: Literal["HIGH", "MEDIUM", "LOW"]
    risk_color: str
    risk_icon: str
    title: str
    message: str
    context: dict[str, Any]
    outcome: dict[str, Any]


class CalendarHeatmapEntry(BaseModel):
    date: str
    warning_count: int
    max_severity: Optional[Literal["HIGH", "MEDIUM", "LOW"]] = None


class WarningsHistoryMeta(BaseModel):
    user_id: str
    pagination: PaginationMeta
    generated_at: str


class WarningsHistoryResponse(BaseModel):
    meta: WarningsHistoryMeta
    risk_summary: RiskSummary
    warnings: list[WarningEntry]
    calendar_heatmap: list[CalendarHeatmapEntry]


# ---------------------------------------------------------------------------
# Cashflow Forecast
# ---------------------------------------------------------------------------


class CashflowPoint(BaseModel):
    date: str
    projected_balance: float


class CashflowForecastResponse(BaseModel):
    projected_balance_series: list[CashflowPoint]
    overdraft_risk: Literal["HIGH", "MEDIUM", "LOW"]
    days_until_projected_zero: int
    income_spike_expected: bool
    confidence: Literal["high", "low"]


# ---------------------------------------------------------------------------
# Subscriptions
# ---------------------------------------------------------------------------


class SubscriptionCharge(BaseModel):
    merchant: str
    amount: float
    frequency: Literal["weekly", "monthly", "quarterly", "annual"]
    next_charge_date: Optional[str] = None
    months_active: int
    unused_for_30_days: bool = False


class SubscriptionsResponse(BaseModel):
    subscriptions: list[SubscriptionCharge]
    monthly_total: float
