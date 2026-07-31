"""
routers/financial_advisor/models.py
=====================================
Pydantic request/response models for the Financial Advisor API.
"""

from __future__ import annotations

from typing import Any, Literal, Optional

from pydantic import BaseModel, Field


class TransactionInput(BaseModel):
    merchant: str
    amount: float = Field(..., description="Positive dollar amount for the charge.")
    frequency: Literal["monthly", "weekly", "quarterly", "annual", "one_time"] = "monthly"
    category: Optional[str] = Field(
        None, description="Optional category hint (taxonomy id or name). Inferred from merchant if omitted."
    )
    location: Optional[str] = Field(
        None, description="Optional merchant location, e.g. 'Austin, TX'. Used for gym pricing checks."
    )


class DebtInput(BaseModel):
    name: str
    type: Literal["credit_card", "student_loan", "auto_loan", "personal_loan", "mortgage", "bnpl", "other"] = "other"
    balance: float = 0.0
    monthly_payment: float = 0.0
    interest_rate: Optional[float] = Field(None, description="Annual interest rate as a percent, e.g. 22.5")


class PersonFinancialInput(BaseModel):
    name: Optional[str] = Field(None, description="Used only for report labeling — not persisted.")
    location: Optional[str] = Field(None, description="Person's general location, e.g. 'Austin, TX'.")
    monthly_income: float = Field(..., ge=0)
    filing_status: Literal["single", "married_joint"] = "single"
    transactions: list[TransactionInput] = Field(default_factory=list)
    debts: list[DebtInput] = Field(default_factory=list)


class BatchFinancialInput(BaseModel):
    people: list[PersonFinancialInput]


class FinancialAdviceReport(BaseModel):
    name: Optional[str] = None
    monthly_income: float
    summary: dict[str, Any]
    expenses: dict[str, Any]
    gym_analysis: dict[str, Any]
    supplement_analysis: dict[str, Any]
    liabilities: dict[str, Any]
    tax_estimate: dict[str, Any]
    advice: list[dict[str, Any]]


class BatchFinancialAdviceReport(BaseModel):
    reports: list[FinancialAdviceReport]


class FullPictureBrief(BaseModel):
    safe_to_spend_today: float
    monthly_leftover: float
    savings_rate_pct: float
    itemized_transaction_count: int
    top_advice: Optional[str] = None
    hidden_spend_note: Optional[str] = Field(
        None, description="Set when a receipt line item surfaces spend a merchant-level charge alone wouldn't show."
    )


class ItemLevelCategory(BaseModel):
    subcategory_id: str
    subcategory_name: str
    category_name: str
    amount: float


class FullFinancialPictureReport(BaseModel):
    user_id: str
    brief: FullPictureBrief = Field(
        ..., description="Headline summary — the brief surface for a UI to show inline, not a new bulk category section."
    )
    item_level_breakdown: list[ItemLevelCategory] = Field(
        default_factory=list,
        description="Receipt line items rolled up by taxonomy subcategory — detail Plaid alone can't provide.",
    )
    full_report: FinancialAdviceReport = Field(
        ..., description="Full-capability advice report for a surface that explicitly wants to drill in."
    )
