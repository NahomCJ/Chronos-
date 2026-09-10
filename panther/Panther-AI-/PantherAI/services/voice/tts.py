"""
services/voice/tts.py
======================
TTS layer for Chris voice responses.

Priority:
  1. VibeVoice-Realtime-0.5B (local, free) — VIBEVOICE_TTS_ENABLED=true + vibevoice installed
  2. ElevenLabs API                         — ELEVENLABS_API_KEY (or ELEVEN_API_KEY) set
  3. OpenAI TTS                             — OPENAI_API_KEY set

Setup for VibeVoice TTS:
    git clone https://github.com/microsoft/VibeVoice.git
    cd VibeVoice && pip install -e .[streamingtts]
    # Note: vibevoice requires transformers<5.0.0; pin to 4.51.3 in that env

Environment:
    VIBEVOICE_TTS_ENABLED  — "true" to enable (default: false)
    VIBEVOICE_TTS_MODEL    — HF model ID (default: microsoft/VibeVoice-Realtime-0.5B)
    VIBEVOICE_SPEAKER      — voice preset name (default: carter)
    VIBEVOICE_VOICE_DIR    — path to directory containing <speaker>.pt voice files
    ELEVENLABS_API_KEY     — ElevenLabs API key (canonical name, shared with Express backend)
    ELEVEN_API_KEY         — legacy alias for ELEVENLABS_API_KEY (either works)
    ELEVENLABS_VOICE_ID    — ElevenLabs voice ID (canonical name, shared with Express backend)
    ELEVEN_VOICE_ID        — legacy alias for ELEVENLABS_VOICE_ID (either works)
    OPENAI_API_KEY         — OpenAI API key (secondary cloud fallback)
"""

from __future__ import annotations

import base64
import io
import os
from typing import Tuple

from dotenv import load_dotenv

load_dotenv()

# Accept both the canonical name (shared with Express backend) and the legacy alias
ELEVEN_API_KEY = os.getenv("ELEVENLABS_API_KEY") or os.getenv("ELEVEN_API_KEY")
# Default voice matches Express backend's Chris voice (Rachel) for a consistent sound
ELEVEN_VOICE_ID = os.getenv("ELEVENLABS_VOICE_ID") or os.getenv("ELEVEN_VOICE_ID", "21m00Tcm4TlvDq8ikWAM")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

VIBEVOICE_TTS_ENABLED = os.getenv("VIBEVOICE_TTS_ENABLED", "false").lower() == "true"
VIBEVOICE_TTS_MODEL = os.getenv("VIBEVOICE_TTS_MODEL", "microsoft/VibeVoice-Realtime-0.5B")
VIBEVOICE_SPEAKER = os.getenv("VIBEVOICE_SPEAKER", "carter")
VIBEVOICE_VOICE_DIR = os.getenv("VIBEVOICE_VOICE_DIR", "")

# Lazy-loaded globals — populated on first VibeVoice TTS call
_vv_tts_model = None
_vv_tts_processor = None
_vv_voice_cache = None


def synthesize(text: str) -> Tuple[bytes, str]:
    """
    Converts text to audio bytes.

    Returns:
        (audio_bytes, format) — format is "wav" for VibeVoice, "mp3" for cloud providers

    Raises:
        RuntimeError: If no TTS provider is configured or available.
    """
    if len(text) > 5000:
        text = text[:5000]

    if VIBEVOICE_TTS_ENABLED:
        try:
            return _vibevoice_tts(text)
        except Exception:
            pass  # Fall through to cloud providers

    if ELEVEN_API_KEY:
        try:
            return _elevenlabs(text)
        except Exception:
            pass  # Fall through to OpenAI

    if OPENAI_API_KEY:
        return _openai_tts(text)

    raise RuntimeError(
        "No TTS provider configured. Set VIBEVOICE_TTS_ENABLED=true, "
        "ELEVEN_API_KEY, or OPENAI_API_KEY."
    )


def synthesize_base64(text: str) -> Tuple[str, str]:
    """Returns (base64_encoded_audio, format)."""
    audio_bytes, fmt = synthesize(text)
    return base64.b64encode(audio_bytes).decode("utf-8"), fmt


# ---------------------------------------------------------------------------
# VibeVoice-Realtime TTS (local, free)
# ---------------------------------------------------------------------------


def _vibevoice_tts(text: str) -> Tuple[bytes, str]:
    import copy

    import scipy.io.wavfile as wavfile
    import torch
    from vibevoice.modular.modeling_vibevoice_streaming_inference import (
        VibeVoiceStreamingForConditionalGenerationInference,
    )
    from vibevoice.processor.vibevoice_streaming_processor import VibeVoiceStreamingProcessor

    global _vv_tts_model, _vv_tts_processor, _vv_voice_cache

    device = "cuda" if torch.cuda.is_available() else "cpu"
    dtype = torch.bfloat16 if device == "cuda" else torch.float32
    attn = "flash_attention_2" if device == "cuda" else "sdpa"

    if _vv_tts_processor is None:
        _vv_tts_processor = VibeVoiceStreamingProcessor.from_pretrained(VIBEVOICE_TTS_MODEL)

    if _vv_tts_model is None:
        try:
            _vv_tts_model = VibeVoiceStreamingForConditionalGenerationInference.from_pretrained(
                VIBEVOICE_TTS_MODEL,
                torch_dtype=dtype,
                device_map=device,
                attn_implementation=attn,
            )
        except Exception:
            # flash_attention_2 may not be installed — retry with sdpa
            _vv_tts_model = VibeVoiceStreamingForConditionalGenerationInference.from_pretrained(
                VIBEVOICE_TTS_MODEL,
                torch_dtype=dtype,
                device_map=device,
                attn_implementation="sdpa",
            )
        _vv_tts_model.eval()
        _vv_tts_model.set_ddpm_inference_steps(num_steps=5)

    if _vv_voice_cache is None:
        voice_path = _resolve_voice_path()
        _vv_voice_cache = torch.load(voice_path, map_location=device, weights_only=False)

    inputs = _vv_tts_processor.process_input_with_cached_prompt(
        text=text,
        cached_prompt=_vv_voice_cache,
        padding=True,
        return_tensors="pt",
        return_attention_mask=True,
    )
    inputs = {k: v.to(device) if torch.is_tensor(v) else v for k, v in inputs.items()}

    outputs = _vv_tts_model.generate(
        **inputs,
        max_new_tokens=None,
        cfg_scale=1.5,
        tokenizer=_vv_tts_processor.tokenizer,
        generation_config={"do_sample": False},
        all_prefilled_outputs=copy.deepcopy(_vv_voice_cache),
    )

    audio_np = outputs.speech_outputs[0].cpu().float().numpy()
    buf = io.BytesIO()
    wavfile.write(buf, 24000, audio_np)
    return buf.getvalue(), "wav"


def _resolve_voice_path() -> str:
    """Locate the .pt voice preset file for the configured speaker."""
    if not VIBEVOICE_VOICE_DIR:
        raise RuntimeError(
            "VIBEVOICE_VOICE_DIR is not set. Point it to the directory containing "
            "<speaker>.pt voice files from the VibeVoice repo "
            "(demo/voices/streaming_model/)."
        )
    for name in (VIBEVOICE_SPEAKER, VIBEVOICE_SPEAKER.lower(), VIBEVOICE_SPEAKER.title()):
        path = os.path.join(VIBEVOICE_VOICE_DIR, f"{name}.pt")
        if os.path.exists(path):
            return path
    raise RuntimeError(
        f"Voice preset '{VIBEVOICE_SPEAKER}.pt' not found in {VIBEVOICE_VOICE_DIR}. "
        "Available presets: " + ", ".join(
            f.replace(".pt", "") for f in os.listdir(VIBEVOICE_VOICE_DIR) if f.endswith(".pt")
        )
    )


# ---------------------------------------------------------------------------
# Cloud TTS providers (fallback)
# ---------------------------------------------------------------------------


def _elevenlabs(text: str) -> Tuple[bytes, str]:
    import httpx

    url = f"https://api.elevenlabs.io/v1/text-to-speech/{ELEVEN_VOICE_ID}"
    headers = {
        "xi-api-key": ELEVEN_API_KEY,
        "Content-Type": "application/json",
    }
    payload = {
        "text": text,
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {
            "stability": 0.45,
            "similarity_boost": 0.8,
            "style": 0.25,
            "use_speaker_boost": True,
        },
    }
    response = httpx.post(url, json=payload, headers=headers, timeout=30.0)
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
