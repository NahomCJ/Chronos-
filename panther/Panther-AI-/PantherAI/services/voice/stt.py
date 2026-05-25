"""
services/voice/stt.py
======================
Speech-to-text via ElevenLabs Scribe.

ElevenLabs Scribe handles conversational audio well — accents, financial
terminology, natural speech patterns — making it the right fit for Panther.

Environment:
    ELEVEN_API_KEY  — ElevenLabs API key
    ELEVEN_STT_MODEL — Scribe model ID (default: scribe_v1)
"""

from __future__ import annotations

import os

import httpx
from dotenv import load_dotenv

load_dotenv()

ELEVEN_API_KEY = os.getenv("ELEVEN_API_KEY")
ELEVEN_STT_MODEL = os.getenv("ELEVEN_STT_MODEL", "scribe_v1")


async def transcribe(audio_bytes: bytes, filename: str, content_type: str) -> str:
    """
    Transcribes audio bytes to text using ElevenLabs Scribe.

    Args:
        audio_bytes:  Raw audio data from the uploaded file.
        filename:     Original filename (used to hint the format).
        content_type: MIME type of the audio.

    Returns:
        Transcribed text string.

    Raises:
        RuntimeError: If ELEVEN_API_KEY is not configured.
        httpx.HTTPStatusError: If the ElevenLabs API returns an error.
    """
    if not ELEVEN_API_KEY:
        raise RuntimeError(
            "STT unavailable: ELEVEN_API_KEY not configured."
        )

    async with httpx.AsyncClient(timeout=60.0) as client:
        response = await client.post(
            "https://api.elevenlabs.io/v1/speech-to-text",
            headers={"xi-api-key": ELEVEN_API_KEY},
            files={"file": (filename, audio_bytes, content_type)},
            data={"model_id": ELEVEN_STT_MODEL},
        )
        response.raise_for_status()
        return response.json()["text"]
