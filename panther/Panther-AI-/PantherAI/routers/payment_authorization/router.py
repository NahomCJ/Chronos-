"""
Payment Authorization Router — POST /api/authorize-payment

Phase 2 [LIVE]: Calls real risk assessment and BNPL scoring services.

The mobile app sends one request and gets back a complete risk picture:
cashflow warning + BNPL score + a combined human-readable message.
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Literal, Optional
import uuid

from core.logger import contract

from services.risk_assessment.risk_assesment import assess_payment_risk
from services.bnpl_risk_scoring.bnpl_risk_scoring import calculate_bnpl_risk_score


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

MIN_BNPL_PAYMENTS = 1
MAX_BNPL_PAYMENTS = 36

router = APIRouter()


# ---------------------------------------------------------------------------
# Request / Response models
# ---------------------------------------------------------------------------

class PaymentRequest(BaseModel):
    """Incoming payment authorization request from the mobile app."""
    user_id: str
    amount: float
    merchant: str
    payment_type: Literal["standard", "bnpl"] = "standard"
    num_payments: Optional[int] = None


class CashFlowWarning(BaseModel):
    """Risk assessment result for cash flow impact."""
    is_risky: bool
    risk_level: Literal["HIGH", "MEDIUM", "LOW"]
    warning_message: str
    projected_balance: float
    confidence: float


class BNPLWarning(BaseModel):
    """BNPL risk scoring result."""
    score: int
    risk_level: Literal["HIGH", "MEDIUM", "LOW"]
    risk_factors: list[str]
    recommendation: str


class WarningPayload(BaseModel):
    """Combined warning section of the authorization response."""
    cash_flow: CashFlowWarning
    bnpl: Optional[BNPLWarning] = None
    combined_message: str


class PaymentAuthorizationResponse(BaseModel):
    """Full response contract for POST /api/authorize-payment."""
    authorization_id: str
    status: str
    warning: WarningPayload





# ---------------------------------------------------------------------------
# Endpoint
# ---------------------------------------------------------------------------

@router.post("/authorize-payment", response_model=PaymentAuthorizationResponse)
@contract
def authorize_payment(request: PaymentRequest):
    """
    Unified payment authorization for the mobile app.

    Calls risk assessment (always) and BNPL scoring (only when
    payment_type == "bnpl"). Returns a single combined warning the
    mobile app can display directly without further processing.

    Args:
        request (PaymentRequest): Validated request with user_id, amount,
            merchant, payment_type ("standard" | "bnpl"), and optional
            num_payments (required when payment_type == "bnpl").

    Returns:
        dict: {"authorization_id": str, "status": "pending", "warning":
            {"cash_flow": CashFlowWarning, "bnpl": BNPLWarning | None,
            "combined_message": str}}

    Raises:
        HTTPException(400): num_payments missing on BNPL request.
        HTTPException(404): Unknown user_id (ValueError from risk service).
        HTTPException(422): amount <= 0 or num_payments outside [1, 36].
    """
    # 1. Validate amount
    # ADR: Router is the authoritative validation boundary. In Phase 2,
    # services may also raise ValueError for invalid input — catch those
    # separately and map to 404 (unknown user) or let this pre-validation
    # handle bad params before the service call is made.
    if request.amount <= 0:
        raise HTTPException(status_code=422, detail="amount must be > 0")

    # 2. Risk assessment (always runs)
    try:
        cash_flow = assess_payment_risk(request.user_id, request.amount)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    # 3. BNPL scoring (conditional)
    bnpl = None
    if request.payment_type == "bnpl":
        if request.num_payments is None:
            raise HTTPException(
                status_code=400,
                detail="num_payments is required for BNPL payments",
            )
        if request.num_payments < MIN_BNPL_PAYMENTS or request.num_payments > MAX_BNPL_PAYMENTS:
            raise HTTPException(
                status_code=422,
                detail=f"num_payments must be between {MIN_BNPL_PAYMENTS} and {MAX_BNPL_PAYMENTS}",
            )
        try:
            bnpl = calculate_bnpl_risk_score(
                request.user_id, request.amount, request.num_payments,
            )
        except ValueError as e:
            raise HTTPException(status_code=422, detail=str(e))

    # 4. Normalize enum values to plain strings for JSON serialization
    # ADR: Enum values are normalized to plain strings here because the
    # risk services return RiskLevel enum objects (e.g. RiskLevel.HIGH).
    # FastAPI's JSON serializer doesn't auto-unwrap enums from raw dicts.
    # Using hasattr() makes this safe for both Phase 1 (string) and
    # Phase 2 (enum) return types — zero code changes needed on swap.
    cash_flow_dict = {
        "is_risky": cash_flow["is_risky"],
        "risk_level": cash_flow["risk_level"].value if hasattr(cash_flow["risk_level"], "value") else cash_flow["risk_level"],
        "warning_message": cash_flow["warning_message"],
        "projected_balance": cash_flow["projected_balance"],
        "confidence": cash_flow["confidence"],
    }

    bnpl_dict = None
    if bnpl:
        bnpl_dict = {
            "score": bnpl["score"],
            "risk_level": bnpl["risk_level"].value if hasattr(bnpl["risk_level"], "value") else bnpl["risk_level"],
            "risk_factors": bnpl["risk_factors"],
            "recommendation": bnpl["recommendation"],
        }

    # 5. Build combined message
    combined = cash_flow_dict["warning_message"]
    if bnpl_dict:
        combined += (
            f"\n\nBNPL Risk: {bnpl_dict['score']}/100 — {bnpl_dict['recommendation']}"
        )

    return {
        "authorization_id": str(uuid.uuid4()),
        "status": "pending",
        "warning": {
            "cash_flow": cash_flow_dict,
            "bnpl": bnpl_dict,
            "combined_message": combined,
        },
    }



