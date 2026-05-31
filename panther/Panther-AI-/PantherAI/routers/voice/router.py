"""
routers/voice/router.py
========================
POST /api/chris/voice — Voice interface for Chris.

Flow:
  1. Accept audio file (webm / mp4 / m4a / wav / ogg)
  2. Transcribe via ElevenLabs Scribe
  3. Detect transaction intent — transfer, request, exchange, purchase, trade, invest
  4. If transaction detected → enter 2-step voice confirmation gate:
       INTENT_CAPTURED  — Chris reads back details, asks user to confirm
       EXECUTING        — user said "confirm", Chris executes
       COMPLETED / FAILED / CANCELLED
  5. Otherwise → run chris_chat() with domain context
  6. Synthesize reply via ElevenLabs TTS (streaming)

Request (multipart/form-data):
    user_id                   — authenticated user ID
    audio                     — audio file upload
    voice                     — bool, include TTS audio in response (default false)
    history_user_id           — owner of conversation_history (Layer 1 security)
    transfer_state            — current 2FA state (pass back from prev response)
    payment_intent_json       — JSON-encoded TransactionIntent from previous turn
    conversation_history_json — JSON-encoded conversation history

Response: VoiceResponse JSON
"""

from __future__ import annotations

import base64
import json
import os
from typing import Any, Optional

from fastapi import APIRouter, File, Form, HTTPException, Query, UploadFile
from pydantic import BaseModel

from services.conversational_ai.chris import chris_chat
from services.conversational_ai.payment_intent import parse_payment_intent
from services.conversational_ai.payment_executor import execute_transaction
from services.conversational_ai.router import route_query
from services.voice.stt import transcribe as stt_transcribe
from services.voice.tts import synthesize_base64, synthesize_streaming

router = APIRouter(prefix="/chris", tags=["voice"])


class VoiceResponse(BaseModel):
    transcript: str
    response_text: str
    tools_called: list[str]
    context_used: dict[str, Any]
    domain: Optional[str] = None
    audio_base64: Optional[str] = None
    audio_format: Optional[str] = None
    payment_intent: Optional[dict[str, Any]] = None
    # INTENT_CAPTURED | EXECUTING | COMPLETED | CANCELLED | FAILED
    transfer_state: Optional[str] = None
    conversation_history: Optional[dict[str, Any]] = None


@router.post("/voice", response_model=VoiceResponse)
async def voice_chat(
    user_id: str = Form(...),
    audio: UploadFile = File(...),
    voice: bool = Query(False, description="Set to true to include TTS audio in response"),
    history_user_id: Optional[str] = Form(None),
    transfer_state: Optional[str] = Form(None),
    payment_intent_json: Optional[str] = Form(None),
    conversation_history_json: Optional[str] = Form(None),
):
    """
    Voice interface for Chris.
    Transcribes audio, detects transaction intent or routes to Chris chat,
    and optionally speaks the response back via ElevenLabs TTS.
    """
    # Transcribe via ElevenLabs Scribe
    audio_bytes = await audio.read()
    filename = audio.filename or "audio.webm"
    content_type = audio.content_type or "audio/webm"

    try:
        transcript = await stt_transcribe(audio_bytes, filename, content_type)
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Transcription failed: {e}")

    # Parse JSON fields
    conversation_history = _parse_json(conversation_history_json)
    pending_intent = _parse_json(payment_intent_json)

    # --- 2-step confirmation gate ---
    if transfer_state == "INTENT_CAPTURED":
        return await _handle_confirmation(
            user_id=user_id,
            transcript=transcript,
            pending_intent=pending_intent,
            voice=voice,
        )

    # Classify domain for routing
    domain = route_query(transcript)

    # Detect transaction intent
    intent = parse_payment_intent(transcript)
    if intent:
        confirm_text = _confirmation_prompt(intent)
        audio_b64, audio_fmt = _maybe_tts(confirm_text, voice)
        return VoiceResponse(
            transcript=transcript,
            response_text=confirm_text,
            tools_called=[],
            context_used={},
            domain=domain,
            audio_base64=audio_b64,
            audio_format=audio_fmt,
            payment_intent=intent,
            transfer_state="INTENT_CAPTURED",
        )

    # Normal Chris chat
    try:
        result = chris_chat(
            user_id=user_id,
            message=transcript,
            conversation_history=conversation_history,
            history_user_id=history_user_id,
            domain=domain,
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    audio_b64, audio_fmt = _maybe_tts(result["response"], voice)

    return VoiceResponse(
        transcript=transcript,
        response_text=result["response"],
        tools_called=result["tools_called"],
        context_used=result["context_used"],
        domain=domain,
        audio_base64=audio_b64,
        audio_format=audio_fmt,
        conversation_history=result.get("conversation_history"),
    )


# ---------------------------------------------------------------------------
# Confirmation prompts — one per transaction type
# ---------------------------------------------------------------------------

def _confirmation_prompt(intent: dict) -> str:
    t = intent.get("type")
    amt = intent.get("amount")
    amt_str = f"${amt:,.2f}" if amt else "an amount"
    currency = intent.get("currency", "USD")

    if t == "transfer":
        return (
            f"Got it — sending {amt_str} to {intent.get('recipient')}. "
            "Say confirm to proceed or cancel to stop."
        )
    if t == "request":
        return (
            f"I'll send a payment request of {amt_str} to {intent.get('from_user')}. "
            "They'll be notified to pay you back. Say confirm or cancel."
        )
    if t == "exchange":
        return (
            f"Exchanging {amt_str} {intent.get('from_currency', 'USD')} "
            f"to {intent.get('to_currency')} at the current rate. "
            "Say confirm to proceed or cancel to stop."
        )
    if t == "purchase":
        item = intent.get("item", "item")
        price = f" for {amt_str}" if amt else ""
        return (
            f"Completing purchase of {item}{price}. "
            "Say confirm to checkout or cancel to stop."
        )
    if t == "trade":
        direction = intent.get("direction", "buy").title()
        asset = intent.get("asset", "asset")
        return (
            f"{direction}ing {asset} for {amt_str} at market price. "
            "This is a market order — values can change. Say confirm to place the order or cancel."
        )
    if t == "invest":
        fund = intent.get("fund", "your portfolio")
        return (
            f"Investing {amt_str} in {fund}. "
            "Investment values can go up or down. Say confirm to proceed or cancel."
        )
    return f"Proceeding with {t} of {amt_str}. Say confirm or cancel."


# ---------------------------------------------------------------------------
# Confirmation handler (second voice turn)
# ---------------------------------------------------------------------------

async def _handle_confirmation(
    user_id: str,
    transcript: str,
    pending_intent: dict | None,
    voice: bool,
) -> VoiceResponse:
    if _is_cancellation(transcript):
        reply = "Cancelled. No transaction was made. Anything else I can help with?"
        audio_b64, audio_fmt = _maybe_tts(reply, voice)
        return VoiceResponse(
            transcript=transcript,
            response_text=reply,
            tools_called=[],
            context_used={},
            transfer_state="CANCELLED",
            audio_base64=audio_b64,
            audio_format=audio_fmt,
        )

    if not _is_confirmation(transcript):
        reply = (
            "Didn't catch that. Say confirm to proceed "
            "or cancel to abort."
        )
        audio_b64, audio_fmt = _maybe_tts(reply, voice)
        return VoiceResponse(
            transcript=transcript,
            response_text=reply,
            tools_called=[],
            context_used={},
            payment_intent=pending_intent,
            transfer_state="INTENT_CAPTURED",
            audio_base64=audio_b64,
            audio_format=audio_fmt,
        )

    if not pending_intent:
        raise HTTPException(status_code=400, detail="No pending transaction intent.")

    try:
        result = await execute_transaction(user_id, pending_intent)
        reply = _success_message(pending_intent, result)
        state = "COMPLETED"
        ctx: dict[str, Any] = {"transaction_result": result}
    except RuntimeError as e:
        reply = f"Transaction failed: {e}. Please try again or contact support."
        state = "FAILED"
        ctx = {"error": str(e)}

    audio_b64, audio_fmt = _maybe_tts(reply, voice)
    return VoiceResponse(
        transcript=transcript,
        response_text=reply,
        tools_called=["execute_transaction"],
        context_used=ctx,
        transfer_state=state,
        audio_base64=audio_b64,
        audio_format=audio_fmt,
    )


def _success_message(intent: dict, result: dict) -> str:
    t = intent.get("type")
    tx_id = result.get("transaction_id", result.get("transfer_id", "N/A"))
    amt = intent.get("amount")
    amt_str = f"${amt:,.2f}" if amt else ""

    if t == "transfer":
        return f"Done — {amt_str} sent to {intent.get('recipient')}. Transaction ID: {tx_id}."
    if t == "request":
        return f"Payment request of {amt_str} sent to {intent.get('from_user')}. They'll be notified."
    if t == "exchange":
        return f"Exchanged {amt_str} {intent.get('from_currency')} to {intent.get('to_currency')}. Transaction ID: {tx_id}."
    if t == "purchase":
        return f"Purchase of {intent.get('item', 'item')} complete. Transaction ID: {tx_id}."
    if t == "trade":
        return f"{intent.get('direction','buy').title()} order for {intent.get('asset')} placed. Transaction ID: {tx_id}."
    if t == "invest":
        return f"Invested {amt_str} in {intent.get('fund')}. Transaction ID: {tx_id}."
    return f"Transaction complete. ID: {tx_id}."


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _maybe_tts(text: str, enabled: bool) -> tuple[str | None, str | None]:
    if not enabled:
        return None, None
    try:
        audio_bytes = synthesize_streaming(text)
        return base64.b64encode(audio_bytes).decode("utf-8"), "mp3"
    except Exception:
        try:
            b64, fmt = synthesize_base64(text)
            return b64, fmt
        except Exception:
            return None, None


def _parse_json(raw: str | None) -> dict | None:
    if not raw:
        return None
    try:
        return json.loads(raw)
    except Exception:
        return None


def _is_confirmation(text: str) -> bool:
    keywords = {"confirm", "yes", "proceed", "do it", "go ahead", "approve", "ok", "okay", "sure", "yep", "yeah"}
    return any(k in text.lower() for k in keywords)


def _is_cancellation(text: str) -> bool:
    keywords = {"cancel", "no", "stop", "abort", "nevermind", "never mind", "don't", "nope", "nah"}
    return any(k in text.lower() for k in keywords)
