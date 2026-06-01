"""
routers/voice/router.py
========================
POST /api/chris/voice — Voice interface for Chris.

Flow:
  1. Accept audio file (webm / mp4 / m4a / wav / ogg)
  2. Transcribe via Whisper (primary) / ElevenLabs (fallback)
  3. Detect transaction intent — transfer, request, exchange, purchase, trade, invest
  4. If transaction detected → enter 2-step voice confirmation gate:
       INTENT_CAPTURED  — Chris reads back details, asks user to confirm
       EXECUTING        — user said "confirm", Chris executes
       COMPLETED / FAILED / CANCELLED
  5. Otherwise → run chris_chat() with domain context
  6. Synthesize reply via ElevenLabs TTS (streaming)

D8 — Voice Checkout Loop (TickPay):
  State: CHECKOUT_INITIATED
  - Chris finds a product via marketplace search, reads back name + price + BNPL plan
  - User says "buy it" → triggers checkout_agent (D6)
  - User says "next" → offers next result from pending_results list
  - User says "cancel" → aborts

Request (multipart/form-data):
    user_id                   — authenticated user ID
    audio                     — audio file upload
    voice                     — bool, include TTS audio in response (default false)
    history_user_id           — owner of conversation_history (Layer 1 security)
    transfer_state            — current state (pass back from prev response)
    payment_intent_json       — JSON-encoded TransactionIntent from previous turn
    checkout_state_json       — JSON-encoded checkout state for D8 voice loop
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
    # D8: CHECKOUT_INITIATED | CHECKOUT_CONFIRMED | CHECKOUT_CANCELLED
    transfer_state: Optional[str] = None
    conversation_history: Optional[dict[str, Any]] = None
    # D8 — pending product results for "next" navigation
    checkout_state: Optional[dict[str, Any]] = None


@router.post("/voice", response_model=VoiceResponse)
async def voice_chat(
    user_id: str = Form(...),
    audio: UploadFile = File(...),
    voice: bool = Query(False, description="Set to true to include TTS audio in response"),
    history_user_id: Optional[str] = Form(None),
    transfer_state: Optional[str] = Form(None),
    payment_intent_json: Optional[str] = Form(None),
    checkout_state_json: Optional[str] = Form(None),
    conversation_history_json: Optional[str] = Form(None),
):
    """
    Voice interface for Chris.
    Transcribes audio, detects transaction intent or routes to Chris chat,
    and optionally speaks the response back via ElevenLabs TTS.

    D8: Also handles voice checkout loop (CHECKOUT_INITIATED state).
    """
    audio_bytes = await audio.read()
    filename = audio.filename or "audio.webm"
    content_type = audio.content_type or "audio/webm"

    try:
        transcript = await stt_transcribe(audio_bytes, filename, content_type)
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Transcription failed: {e}")

    conversation_history = _parse_json(conversation_history_json)
    pending_intent = _parse_json(payment_intent_json)
    checkout_state = _parse_json(checkout_state_json)

    # --- D8: Voice checkout loop ---
    if transfer_state == "CHECKOUT_INITIATED" and checkout_state:
        return await _handle_voice_checkout(
            user_id=user_id,
            transcript=transcript,
            checkout_state=checkout_state,
            voice=voice,
        )

    # --- 2FA confirmation gate ---
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


def _is_buy_confirmation(text: str) -> bool:
    keywords = {"buy it", "buy", "confirm", "yes", "do it", "go ahead", "purchase", "checkout", "get it", "ok", "okay", "yeah", "yep"}
    return any(k in text.lower() for k in keywords)


def _is_next(text: str) -> bool:
    keywords = {"next", "show me another", "other", "different", "skip", "something else"}
    return any(k in text.lower() for k in keywords)


def _checkout_readback(product: dict) -> str:
    """Builds the TTS readback string for a product offer."""
    name = product.get("name", "this product")
    vendor = product.get("vendor", "")
    price = product.get("price", 0)
    installments = product.get("max_safe_installments", 3)
    per_month = round(price / installments, 2) if installments else price
    bnpl = product.get("bnpl_eligible", False)

    if bnpl:
        return (
            f"Found {name} at {vendor} for ${price:.2f}. "
            f"You can split that into {installments} payments of ${per_month:.2f} each. "
            f"Say 'buy it' to confirm or 'next' for another option."
        )
    return (
        f"Found {name} at {vendor} for ${price:.2f}. "
        f"Say 'buy it' to confirm or 'next' for another option."
    )


async def _handle_voice_checkout(
    user_id: str,
    transcript: str,
    checkout_state: dict,
    voice: bool,
) -> VoiceResponse:
    """
    D8 — Voice checkout loop state machine.

    checkout_state shape:
        {
            "results": [...],   # list of SearchResult dicts from D3+D4
            "index": 0,         # current product index
        }

    States:
        CHECKOUT_INITIATED  → user hears readback, says "buy it" or "next"
        CHECKOUT_CONFIRMED  → checkout executed, order confirmed
        CHECKOUT_CANCELLED  → user cancelled
    """
    results: list = checkout_state.get("results", [])
    index: int = checkout_state.get("index", 0)

    # User cancelled
    if _is_cancellation(transcript):
        reply = "No problem, checkout cancelled. Anything else?"
        audio_b64, audio_fmt = _maybe_tts(reply, voice)
        return VoiceResponse(
            transcript=transcript,
            response_text=reply,
            tools_called=[],
            context_used={},
            transfer_state="CHECKOUT_CANCELLED",
            audio_base64=audio_b64,
            audio_format=audio_fmt,
        )

    # User wants next product
    if _is_next(transcript):
        next_index = index + 1
        if next_index >= len(results):
            reply = "That's all the options I found. Want me to search for something else?"
            audio_b64, audio_fmt = _maybe_tts(reply, voice)
            return VoiceResponse(
                transcript=transcript,
                response_text=reply,
                tools_called=[],
                context_used={},
                transfer_state="CHECKOUT_CANCELLED",
                audio_base64=audio_b64,
                audio_format=audio_fmt,
            )
        product = results[next_index]
        reply = _checkout_readback(product)
        audio_b64, audio_fmt = _maybe_tts(reply, voice)
        return VoiceResponse(
            transcript=transcript,
            response_text=reply,
            tools_called=[],
            context_used={"current_product": product},
            transfer_state="CHECKOUT_INITIATED",
            checkout_state={"results": results, "index": next_index},
            audio_base64=audio_b64,
            audio_format=audio_fmt,
        )

    # User confirmed — execute checkout via D6
    if _is_buy_confirmation(transcript):
        if not results or index >= len(results):
            raise HTTPException(status_code=400, detail="No product selected for checkout.")

        product = results[index]
        try:
            from services.marketplace.checkout_agent import checkout as run_checkout
            order = run_checkout(
                user_id=user_id,
                product_name=product["name"],
                product_id=product.get("url", product["name"]),
                price=product["price"],
                partner_id=product.get("partner_id", "mock_nike"),
                vendor=product.get("vendor", ""),
                tickpay_token=f"voice-{user_id}",
                num_payments=product.get("max_safe_installments", 3),
            )
            bnpl = order.get("bnpl_plan")
            if bnpl:
                reply = (
                    f"Done. {product['name']} ordered from {product.get('vendor', '')}. "
                    f"${bnpl['payment_per_installment']:.2f} per month for "
                    f"{bnpl['num_payments']} months. Order ID: {order['order_id']}."
                )
            else:
                reply = (
                    f"Done. {product['name']} ordered from {product.get('vendor', '')} "
                    f"for ${order['total_cost']:.2f}. Order ID: {order['order_id']}."
                )
            state = "CHECKOUT_CONFIRMED"
            ctx = {"order": order}
        except Exception as e:
            reply = f"Checkout failed: {e}. Want to try another option?"
            state = "CHECKOUT_INITIATED"
            ctx = {"error": str(e)}

        audio_b64, audio_fmt = _maybe_tts(reply, voice)
        return VoiceResponse(
            transcript=transcript,
            response_text=reply,
            tools_called=["checkout"],
            context_used=ctx,
            transfer_state=state,
            checkout_state=checkout_state if state == "CHECKOUT_INITIATED" else None,
            audio_base64=audio_b64,
            audio_format=audio_fmt,
        )

    # Didn't catch a clear command
    reply = "Didn't catch that. Say 'buy it' to confirm, 'next' for another option, or 'cancel' to stop."
    audio_b64, audio_fmt = _maybe_tts(reply, voice)
    return VoiceResponse(
        transcript=transcript,
        response_text=reply,
        tools_called=[],
        context_used={},
        transfer_state="CHECKOUT_INITIATED",
        checkout_state=checkout_state,
        audio_base64=audio_b64,
        audio_format=audio_fmt,
    )
