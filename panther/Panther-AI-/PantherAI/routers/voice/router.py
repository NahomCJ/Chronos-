"""
routers/voice/router.py
========================
POST /api/chris/voice — Voice interface for Chris.

Flow:
  1. Accept audio file (webm/mp4/m4a/wav/ogg)
  2. Transcribe — VibeVoice-ASR (local, free) → OpenAI Whisper-1 (cloud fallback) (B1)
  3. Route query to domain (B5)
  4. Detect payment intent in transcript (B10)
  5. If payment intent: enter 2FA state machine (B11)
     INTENT_CAPTURED → AWAITING_2FA → EXECUTING → COMPLETED
  6. Otherwise: run chris_chat() with domain context (B8/B9)
  7. Optionally synthesize TTS audio response (B2)

Request (multipart/form-data):
    user_id            — authenticated user ID
    audio              — audio file upload
    voice              — bool, include TTS audio in response
    history_user_id    — owner of conversation_history (Layer 1 security)
    transfer_state     — current state in 2FA flow (pass back from prev response)
    payment_intent_json — JSON-encoded PaymentIntent from previous turn
    conversation_history_json — JSON-encoded conversation history

Response: VoiceResponse JSON

Setup for VibeVoice ASR:
    git clone https://github.com/microsoft/VibeVoice.git
    cd VibeVoice && pip install -e .
    # Set VIBEVOICE_ASR_ENABLED=true in .env
    # Note: vibevoice requires transformers<5.0.0; pin to 4.51.3 in that env
"""

from __future__ import annotations

import io
import json
import os
from typing import Any, Optional

from fastapi import APIRouter, File, Form, HTTPException, UploadFile
from pydantic import BaseModel

from services.conversational_ai.chris import chris_chat
from services.conversational_ai.payment_intent import parse_payment_intent
from services.conversational_ai.router import route_query
from services.voice.tts import synthesize_base64

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

VIBEVOICE_ASR_ENABLED = os.getenv("VIBEVOICE_ASR_ENABLED", "false").lower() == "true"
VIBEVOICE_ASR_MODEL = os.getenv("VIBEVOICE_ASR_MODEL", "microsoft/VibeVoice-ASR")

# Lazy-loaded globals — populated on first VibeVoice ASR call
_vv_asr_model = None
_vv_asr_processor = None

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
    # State machine: INTENT_CAPTURED | AWAITING_2FA | EXECUTING | COMPLETED | CANCELLED | FAILED
    transfer_state: Optional[str] = None
    conversation_history: Optional[dict[str, Any]] = None


@router.post("/voice", response_model=VoiceResponse)
async def voice_chat(
    user_id: str = Form(...),
    audio: UploadFile = File(...),
    voice: bool = Form(False),
    history_user_id: Optional[str] = Form(None),
    transfer_state: Optional[str] = Form(None),
    payment_intent_json: Optional[str] = Form(None),
    conversation_history_json: Optional[str] = Form(None),
):
    """
    Voice interface for Chris — transcribe, route, respond, optionally speak.

    Pass transfer_state and payment_intent_json back on subsequent requests
    to continue a payment flow through the 2FA gate.
    """
    # Transcribe audio (B1)
    transcript = await _transcribe(audio)

    # Parse conversation history
    conversation_history = None
    if conversation_history_json:
        try:
            conversation_history = json.loads(conversation_history_json)
        except Exception:
            pass

    # Parse pending payment intent from previous turn
    pending_intent = None
    if payment_intent_json:
        try:
            pending_intent = json.loads(payment_intent_json)
        except Exception:
            pass

    # 2FA gate: handle confirmation/cancellation (B11)
    if transfer_state == "INTENT_CAPTURED":
        return await _handle_2fa_confirmation(
            user_id=user_id,
            transcript=transcript,
            pending_intent=pending_intent,
            voice=voice,
        )

    # Classify domain for routing (B5)
    domain = route_query(transcript)

    # Detect payment intent in transcript (B10)
    payment_intent = parse_payment_intent(transcript)
    if payment_intent:
        confirm_text = (
            f"I'd like to send ${payment_intent['amount']:.2f} to "
            f"{payment_intent['recipient']}. "
            f"Say 'confirm' to proceed or 'cancel' to stop."
        )
        audio_b64, audio_fmt = _maybe_tts(confirm_text, voice)
        return VoiceResponse(
            transcript=transcript,
            response_text=confirm_text,
            tools_called=[],
            context_used={},
            domain="banking",
            audio_base64=audio_b64,
            audio_format=audio_fmt,
            payment_intent=payment_intent,
            transfer_state="INTENT_CAPTURED",
        )

    # Normal Chris chat with domain context (B8/B9)
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
# Transcription — VibeVoice-ASR (local) → OpenAI Whisper (cloud fallback)
# ---------------------------------------------------------------------------


async def _transcribe(audio: UploadFile) -> str:
    audio_bytes = await audio.read()
    filename = audio.filename or "audio.webm"
    content_type = audio.content_type or "audio/webm"

    if VIBEVOICE_ASR_ENABLED:
        try:
            return await _vibevoice_transcribe(audio_bytes, filename)
        except Exception:
            pass  # Fall through to Whisper

    return await _whisper_transcribe(audio_bytes, filename, content_type)


async def _vibevoice_transcribe(audio_bytes: bytes, filename: str) -> str:
    import tempfile

    import torch
    from vibevoice.modular.modeling_vibevoice_asr import VibeVoiceASRForConditionalGeneration
    from vibevoice.processor.vibevoice_asr_processor import VibeVoiceASRProcessor

    global _vv_asr_model, _vv_asr_processor

    device = "cuda" if torch.cuda.is_available() else "cpu"
    dtype = torch.bfloat16 if device == "cuda" else torch.float32

    if _vv_asr_processor is None:
        _vv_asr_processor = VibeVoiceASRProcessor.from_pretrained(
            VIBEVOICE_ASR_MODEL,
            language_model_pretrained_name="Qwen/Qwen2.5-7B",
        )

    if _vv_asr_model is None:
        _vv_asr_model = VibeVoiceASRForConditionalGeneration.from_pretrained(
            VIBEVOICE_ASR_MODEL,
            dtype=dtype,
            device_map="auto" if device == "cuda" else device,
            attn_implementation="sdpa",
            trust_remote_code=True,
        )
        _vv_asr_model.eval()

    ext = os.path.splitext(filename)[1] or ".webm"
    with tempfile.NamedTemporaryFile(suffix=ext, delete=False) as tmp:
        tmp.write(audio_bytes)
        tmp_path = tmp.name

    try:
        inputs = _vv_asr_processor(
            audio=[tmp_path],
            sampling_rate=None,
            return_tensors="pt",
            padding=True,
            add_generation_prompt=True,
        )
        inputs = {
            k: v.to(_vv_asr_model.device) if torch.is_tensor(v) else v
            for k, v in inputs.items()
        }

        with torch.no_grad():
            output_ids = _vv_asr_model.generate(**inputs, max_new_tokens=512)

        input_len = inputs["input_ids"].shape[1]
        generated_ids = output_ids[0, input_len:]
        raw_text = _vv_asr_processor.decode(generated_ids, skip_special_tokens=True)

        try:
            segments = _vv_asr_processor.post_process_transcription(raw_text)
            if segments:
                return " ".join(seg.get("text", "") for seg in segments).strip()
        except Exception:
            pass
        return raw_text.strip()
    finally:
        os.unlink(tmp_path)


async def _whisper_transcribe(audio_bytes: bytes, filename: str, content_type: str) -> str:
    if not OPENAI_API_KEY:
        raise HTTPException(
            status_code=503,
            detail="STT unavailable: set VIBEVOICE_ASR_ENABLED=true or OPENAI_API_KEY.",
        )

    from openai import AsyncOpenAI

    client = AsyncOpenAI(api_key=OPENAI_API_KEY)
    transcript = await client.audio.transcriptions.create(
        model="whisper-1",
        file=(filename, io.BytesIO(audio_bytes), content_type),
    )
    return transcript.text


# ---------------------------------------------------------------------------
# 2FA confirmation handler (B11)
# ---------------------------------------------------------------------------


async def _handle_2fa_confirmation(
    user_id: str,
    transcript: str,
    pending_intent: dict | None,
    voice: bool,
) -> VoiceResponse:
    """Processes user's confirm/cancel response in the transfer 2FA gate."""
    from services.conversational_ai.payment_executor import execute_transfer

    if _is_cancellation(transcript):
        reply = "Transfer cancelled. Is there anything else I can help you with?"
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
        # Unrecognised — re-prompt
        reply = (
            "I didn't catch that. Please say 'confirm' to proceed "
            "or 'cancel' to abort the transfer."
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
        raise HTTPException(status_code=400, detail="No pending transfer intent.")

    # Execute the transfer (B12)
    try:
        result = await execute_transfer(user_id, pending_intent)
        reply = (
            f"Done! ${pending_intent['amount']:.2f} sent to "
            f"{pending_intent['recipient']}. "
            f"Transfer ID: {result.get('transfer_id', 'N/A')}."
        )
        state = "COMPLETED"
        ctx: dict[str, Any] = {"transfer_result": result}
    except RuntimeError as e:
        reply = f"Transfer failed: {e}. Please try again or contact support."
        state = "FAILED"
        ctx = {"error": str(e)}

    audio_b64, audio_fmt = _maybe_tts(reply, voice)
    return VoiceResponse(
        transcript=transcript,
        response_text=reply,
        tools_called=["execute_transfer"],
        context_used=ctx,
        transfer_state=state,
        audio_base64=audio_b64,
        audio_format=audio_fmt,
    )


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _maybe_tts(text: str, enabled: bool) -> tuple[str | None, str | None]:
    if not enabled:
        return None, None
    try:
        b64, fmt = synthesize_base64(text)
        return b64, fmt
    except Exception:
        return None, None


def _is_confirmation(text: str) -> bool:
    keywords = {"confirm", "yes", "proceed", "do it", "go ahead", "approve", "ok", "okay", "sure"}
    return any(k in text.lower() for k in keywords)


def _is_cancellation(text: str) -> bool:
    keywords = {"cancel", "no", "stop", "abort", "nevermind", "never mind", "don't"}
    return any(k in text.lower() for k in keywords)
