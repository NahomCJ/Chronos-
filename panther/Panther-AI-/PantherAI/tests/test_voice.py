import base64
import importlib

from fastapi import FastAPI
from fastapi.testclient import TestClient

voice_router = importlib.import_module('routers.voice.router')
tts = importlib.import_module('services.voice.tts')


def test_elevenlabs_uses_supported_chris_voice_defaults(monkeypatch):
    captured = {}

    class Response:
        content = b'ID3-audio'

        @staticmethod
        def raise_for_status():
            return None

    def fake_post(url, *, json, headers, timeout):
        captured.update(url=url, json=json, headers=headers, timeout=timeout)
        return Response()

    monkeypatch.setenv('ELEVENLABS_API_KEY', 'test-key')
    monkeypatch.delenv('ELEVEN_API_KEY', raising=False)
    monkeypatch.delenv('XI_API_KEY', raising=False)
    monkeypatch.delenv('ELEVENLABS_VOICE_ID', raising=False)
    monkeypatch.delenv('ELEVEN_VOICE_ID', raising=False)
    monkeypatch.delenv('ELEVENLABS_TTS_MODEL', raising=False)
    monkeypatch.setattr('httpx.post', fake_post)

    audio, audio_format = tts._elevenlabs('Hello, I am Chris.')

    assert audio == b'ID3-audio'
    assert audio_format == 'mp3'
    assert tts.DEFAULT_ELEVEN_VOICE_ID in captured['url']
    assert 'output_format=mp3_44100_128' in captured['url']
    assert captured['json']['model_id'] == 'eleven_multilingual_v2'
    assert captured['headers']['xi-api-key'] == 'test-key'


def test_synthesize_base64_uses_elevenlabs_alias(monkeypatch):
    monkeypatch.setattr(tts, 'VIBEVOICE_TTS_ENABLED', False)
    monkeypatch.setenv('ELEVEN_API_KEY', 'alias-key')
    monkeypatch.delenv('ELEVENLABS_API_KEY', raising=False)
    monkeypatch.setattr(tts, '_elevenlabs', lambda text: (b'voice', 'mp3'))

    encoded, audio_format = tts.synthesize_base64('hello')

    assert base64.b64decode(encoded) == b'voice'
    assert audio_format == 'mp3'


def test_payment_confirmation_matches_whole_spoken_phrases():
    assert voice_router._is_confirmation('Yes, go ahead')
    assert voice_router._is_cancellation("No, don't send it")
    assert not voice_router._is_confirmation('I called yesterday')
    assert not voice_router._is_cancellation('That recipient is unknown')


def test_chris_voice_endpoint_returns_transcript_reply_and_audio(monkeypatch):
    async def fake_transcribe(_audio):
        return "What's my balance?"

    monkeypatch.setattr(voice_router, '_transcribe', fake_transcribe)
    monkeypatch.setattr(voice_router, 'route_query', lambda _text: 'banking')
    monkeypatch.setattr(voice_router, 'parse_payment_intent', lambda _text: None)
    monkeypatch.setattr(
        voice_router,
        'chris_chat',
        lambda **_kwargs: {
            'response': 'Your balance is $1,600.',
            'tools_called': ['check_balance'],
            'context_used': {'balance': 1600.0},
            'conversation_history': {'user_id': 'user_marcus', 'messages': []},
        },
    )
    monkeypatch.setattr(
        voice_router,
        '_maybe_tts',
        lambda _text, enabled: ('dm9pY2U=', 'mp3') if enabled else (None, None),
    )

    app = FastAPI()
    app.include_router(voice_router.router, prefix='/api')
    client = TestClient(app)
    response = client.post(
        '/api/chris/voice',
        data={'user_id': 'user_marcus', 'voice': 'true'},
        files={'audio': ('question.webm', b'fake-audio', 'audio/webm')},
    )

    assert response.status_code == 200
    assert response.json() == {
        'transcript': "What's my balance?",
        'response_text': 'Your balance is $1,600.',
        'tools_called': ['check_balance'],
        'context_used': {'balance': 1600.0},
        'domain': 'banking',
        'audio_base64': 'dm9pY2U=',
        'audio_format': 'mp3',
        'payment_intent': None,
        'transfer_state': None,
        'conversation_history': {'user_id': 'user_marcus', 'messages': []},
    }
