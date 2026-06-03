"""
routers/kevin_chat/router.py
==============================
POST /api/kevin/chat — Exposes Kevin to the frontend.

Request:  { user_id, message, conversation_history?, history_user_id? }
Response: { response, tools_called, context_used, conversation_history? }
"""

from __future__ import annotations

from typing import Any, Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, field_validator

from services.conversational_ai.kevin import kevin_chat
from services.conversational_ai.router import route_query

router = APIRouter()


class KevinChatRequest(BaseModel):
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


class KevinChatResponse(BaseModel):
    response: str
    tools_called: list[str]
    context_used: dict[str, Any]
    domain: Optional[str] = None
    conversation_history: Optional[dict[str, Any]] = None


@router.post("/kevin/chat", response_model=KevinChatResponse)
def chat(request: KevinChatRequest):
    """
    Process a chat message through Kevin.

    Args:
        request (KevinChatRequest): Must include user_id and message.
            Pass history_user_id to enable Layer 1 cross-user protection.

    Returns:
        KevinChatResponse: Kevin's reply with tools called and context data.

    Raises:
        HTTPException(404): If user_id is unknown in banking data.
        HTTPException(422): If message is empty (via Pydantic validator).
    """
    domain = route_query(request.message)

    try:
        result = kevin_chat(
            user_id=request.user_id,
            message=request.message,
            conversation_history=request.conversation_history,
            history_user_id=request.history_user_id,
            domain=domain,
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    return KevinChatResponse(
        response=result["response"],
        tools_called=result["tools_called"],
        context_used=result["context_used"],
        domain=domain,
        conversation_history=result.get("conversation_history"),
    )
