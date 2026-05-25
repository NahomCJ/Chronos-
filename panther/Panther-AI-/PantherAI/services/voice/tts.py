"""
services/voice/tts.py
======================
Text-to-speech for Kevin voice responses.

Primary:  ElevenLabs eleven_turbo_v2_5 — optimised for real-time conversation
          (~300 ms first-audio latency, multilingual).
Fallback: OpenAI TTS — used only if ElevenLabs is unavailable.

Environment:
    ELEVEN_API_KEY   — ElevenLabs API key (required for primary)
    ELEVEN_VOICE_ID  — Voice ID to use (default: JBFqnCBsd6RMkjVDRZzb / George)
    ELEVEN_TTS_MODEL — TTS model ID (default: eleven_turbo_v2_5)
    OPENAI_API_KEY   — OpenAI key (fallback only)
"""

from __future__ import annotations

import base64
import os
from typing import Tuple

import httpx
from dotenv import load_dotenv

load_dotenv()

ELEVEN_API_KEY = os.getenv("ELEVEN_API_KEY")
ELEVEN_VOICE_ID = os.getenv("ELEVEN_VOICE_ID", "JBFqnCBsd6RMkjVDRZzb")
ELEVEN_TTS_MODEL = os.getenv("ELEVEN_TTS_MODEL", "eleven_turbo_v2_5")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")


def synthesize(text: str) -> Tuple[bytes, str]:
    """
    Converts text to audio bytes.

    Returns:
        (audio_bytes, format) — "mp3"

    Raises:
        RuntimeError: If no TTS provider is configured.
    """
    if len(text) > 5000:
        text = text[:5000]

    if ELEVEN_API_KEY:
        try:
            return _elevenlabs(text)
        except Exception:
            pass  # Fall through to OpenAI

    if OPENAI_API_KEY:
        return _openai_tts(text)

    raise RuntimeError(
        "No TTS provider configured. Set ELEVEN_API_KEY or OPENAI_API_KEY."
    )


def synthesize_base64(text: str) -> Tuple[str, str]:
    """Returns (base64_encoded_audio, format)."""
    audio_bytes, fmt = synthesize(text)
    return base64.b64encode(audio_bytes).decode("utf-8"), fmt


def synthesize_streaming(text: str) -> bytes:
    """
    Streams audio from ElevenLabs and returns the full audio bytes.
    Uses the /stream endpoint so ElevenLabs starts encoding immediately —
    lower end-to-end latency than the standard endpoint.
    """
    if len(text) > 5000:
        text = text[:5000]

    if not ELEVEN_API_KEY:
        raise RuntimeError("ELEVEN_API_KEY not configured.")

    url = f"https://api.elevenlabs.io/v1/text-to-speech/{ELEVEN_VOICE_ID}/stream"
    headers = {
        "xi-api-key": ELEVEN_API_KEY,
        "Content-Type": "application/json",
    }
    payload = {
        "text": text,
        "model_id": ELEVEN_TTS_MODEL,
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75,
            "style": 0.0,
            "use_speaker_boost": True,
        },
    }

    chunks: list[bytes] = []
    with httpx.stream("POST", url, json=payload, headers=headers, timeout=60.0) as r:
        r.raise_for_status()
        for chunk in r.iter_bytes():
            if chunk:
                chunks.append(chunk)

    return b"".join(chunks)


# ---------------------------------------------------------------------------
# Internal providers
# ---------------------------------------------------------------------------


def _elevenlabs(text: str) -> Tuple[bytes, str]:
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{ELEVEN_VOICE_ID}"
    headers = {
        "xi-api-key": ELEVEN_API_KEY,
        "Content-Type": "application/json",
    }
    payload = {
        "text": text,
        "model_id": ELEVEN_TTS_MODEL,
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75,
            "style": 0.0,
            "use_speaker_boost": True,
        },
    }
    response = httpx.post(url, json=payload, headers=headers, timeout=60.0)
    response.raise_for_status()
    return response.content, "mp3"


def _openai_tts(text: str) -> Tuple[bytes, str]:
    from openai import OpenAI

    client = OpenAI(api_key=OPENAI_API_KEY)
    response = client.audio.speech.create(
        model="tts-1",
        voice="alloy",
        input=text,
        response_format="mp3",
    )
    return response.content, "mp3"
