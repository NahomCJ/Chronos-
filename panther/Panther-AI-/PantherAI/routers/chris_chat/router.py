"""
routers/chris_chat/router.py
==============================
POST /api/chris/chat — Exposes Chris to the frontend.
POST /api/chris/advise — Cross-domain advisor (B8): fires all relevant tools in
                          parallel and returns one unified answer.

Request:  { user_id, message, conversation_history?, history_user_id? }
Response: { response, tools_called, context_used, domain, conversation_history? }
"""

from __future__ import annotations

from typing import Any, Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, field_validator

from services.conversational_ai.chris import chris_chat
from services.conversational_ai.router import route_query

router = APIRouter()


class ChrisChatRequest(BaseModel):
    user_id: str
    message: str
    conversation_history: Optional[list[dict[str, str]]] = None
    history_user_id: Optional[str] = None

    @field_validator("message")
    @classmethod
    def message_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("message cannot be empty")
        return v


class ChrisChatResponse(BaseModel):
    response: str
    tools_called: list[str]
    context_used: dict[str, Any]
    domain: Optional[str] = None
    conversation_history: Optional[dict[str, Any]] = None


class AdviseRequest(BaseModel):
    user_id: str
    query: str

    @field_validator("query")
    @classmethod
    def query_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("query cannot be empty")
        return v


class AdviseResponse(BaseModel):
    response: str
    tools_called: list[str]
    context_used: dict[str, Any]
    domains: list[str]


@router.post("/chris/chat", response_model=ChrisChatResponse)
def chat(request: ChrisChatRequest):
    """
    Process a chat message through Chris.

    Raises:
        HTTPException(404): If user_id is unknown in banking data.
        HTTPException(422): If message is empty.
    """
    domain = route_query(request.message)

    try:
        result = chris_chat(
            user_id=request.user_id,
            message=request.message,
            conversation_history=request.conversation_history,
            history_user_id=request.history_user_id,
            domain=domain,
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    return ChrisChatResponse(
        response=result["response"],
        tools_called=result["tools_called"],
        context_used=result["context_used"],
        domain=domain,
        conversation_history=result.get("conversation_history"),
    )


@router.post("/chris/advise", response_model=AdviseResponse)
def advise(request: AdviseRequest):
    """
    Cross-domain advisor (B8).

    Fires all relevant tools in parallel across banking, crypto, investment,
    and marketplace domains, then compiles a single coherent answer.

    Use this endpoint when the query spans multiple financial areas.
    Example: "Given my bank balance, crypto P&L, and upcoming bills — can I afford to invest $500?"

    Raises:
        HTTPException(404): If user_id is unknown.
        HTTPException(422): If query is empty.
    """
    from services.conversational_ai.cross_domain_advisor import advise as cross_domain_advise

    try:
        result = cross_domain_advise(user_id=request.user_id, query=request.query)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    return AdviseResponse(
        response=result["response"],
        tools_called=result["tools_called"],
        context_used=result["context_used"],
        domains=result["domains"],
    )
