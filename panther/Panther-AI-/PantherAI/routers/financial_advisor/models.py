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
    property_value: Optional[float] = Field(
        None, description="Mortgage-type debts only. Enables an LTV/PMI check."
    )


class CryptoTransactionInput(BaseModel):
    asset: str = Field(..., description="Ticker, e.g. 'BTC', 'ETH'.")
    side: Literal["buy", "sell"]
    quantity: float
    price_per_unit: float = Field(..., description="USD price per unit at time of trade.")
    fee: float = 0.0
    date: Optional[str] = Field(None, description="ISO date of the trade.")


class NftTransactionInput(BaseModel):
    collection: str
    event: Literal["mint", "purchase", "sale", "transfer_in", "transfer_out"]
    price: float = Field(0.0, description="USD. 0 for transfers.")
    gas_fee: float = 0.0
    date: Optional[str] = None
    current_floor_price: Optional[float] = Field(
        None, description="USD, per-unit. Used to value unsold holdings."
    )


class PersonFinancialInput(BaseModel):
    name: Optional[str] = Field(None, description="Used only for report labeling — not persisted.")
    location: Optional[str] = Field(None, description="Person's general location, e.g. 'Austin, TX'.")
    monthly_income: float = Field(..., ge=0)
    filing_status: Literal["single", "married_joint"] = "single"
    transactions: list[TransactionInput] = Field(default_factory=list)
    debts: list[DebtInput] = Field(default_factory=list)
    crypto_transactions: list[CryptoTransactionInput] = Field(default_factory=list)
    crypto_current_prices: dict[str, float] = Field(
        default_factory=dict, description="Optional current price per ticker, enables unrealized P&L."
    )
    nft_transactions: list[NftTransactionInput] = Field(default_factory=list)


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
    crypto_analysis: dict[str, Any]
    nft_analysis: dict[str, Any]
    advice: list[dict[str, Any]]


class BatchFinancialAdviceReport(BaseModel):
    reports: list[FinancialAdviceReport]
