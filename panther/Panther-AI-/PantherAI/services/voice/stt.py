"""
services/voice/stt.py
======================
Speech-to-text for Panther voice input.

Primary:  OpenAI Whisper (whisper-1) — strong accuracy across accents and
          financial terminology, supports webm/mp4/wav/ogg/m4a.
Fallback: ElevenLabs Scribe — used only if OPENAI_API_KEY is absent.

Environment:
    OPENAI_API_KEY   — enables Whisper (primary)
    ELEVEN_API_KEY   — enables ElevenLabs Scribe (fallback)
    ELEVEN_STT_MODEL — Scribe model ID (default: scribe_v1)
"""

from __future__ import annotations

import os

import httpx
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
ELEVEN_API_KEY = os.getenv("ELEVEN_API_KEY")
ELEVEN_STT_MODEL = os.getenv("ELEVEN_STT_MODEL", "scribe_v1")

_WHISPER_URL = "https://api.openai.com/v1/audio/transcriptions"


async def transcribe(audio_bytes: bytes, filename: str, content_type: str) -> str:
    """
    Transcribes audio bytes to text.

    Tries OpenAI Whisper first. Falls back to ElevenLabs Scribe if Whisper
    is not configured or fails.

    Args:
        audio_bytes:  Raw audio data from the uploaded file.
        filename:     Original filename — used to hint the audio format.
        content_type: MIME type (audio/webm, audio/mp4, audio/wav, etc.).

    Returns:
        Transcribed text string.

    Raises:
        RuntimeError: If no STT provider is configured.
    """
    if OPENAI_API_KEY:
        try:
            return await _whisper(audio_bytes, filename, content_type)
        except Exception:
            pass  # Fall through to ElevenLabs

    if ELEVEN_API_KEY:
        return await _elevenlabs_scribe(audio_bytes, filename, content_type)

    raise RuntimeError(
        "STT unavailable: set OPENAI_API_KEY (Whisper) or ELEVEN_API_KEY (ElevenLabs)."
    )


async def _whisper(audio_bytes: bytes, filename: str, content_type: str) -> str:
    """Transcribes via OpenAI Whisper API (whisper-1)."""
    async with httpx.AsyncClient(timeout=60.0) as client:
        response = await client.post(
            _WHISPER_URL,
            headers={"Authorization": f"Bearer {OPENAI_API_KEY}"},
            files={"file": (filename, audio_bytes, content_type)},
            data={"model": "whisper-1"},
        )
        response.raise_for_status()
        return response.json()["text"]


async def _elevenlabs_scribe(audio_bytes: bytes, filename: str, content_type: str) -> str:
    """Transcribes via ElevenLabs Scribe API (fallback)."""
    async with httpx.AsyncClient(timeout=60.0) as client:
        response = await client.post(
            "https://api.elevenlabs.io/v1/speech-to-text",
            headers={"xi-api-key": ELEVEN_API_KEY},
            files={"file": (filename, audio_bytes, content_type)},
            data={"model_id": ELEVEN_STT_MODEL},
        )
        response.raise_for_status()
        return response.json()["text"]
