# Chronos ElevenLabs Voice Chat

This adds a Chronos voice-chat surface powered by ElevenLabs speech-to-text and text-to-speech. It also supports the ElevenLabs hosted agent widget through signed conversation URLs.

## Files

- `src/modules/lifex/modules/ai/elevenLabsVoice.service.ts`
- `src/modules/lifex/modules/ai/elevenLabsVoice.routes.ts`
- `public/chronos-voice-chat.html`

## Mount

The router is mounted from `lifeAI.routes.ts` at `/voice`. The browser client expects these endpoints under `/api/lifex/ai/voice`.

## Environment

Required:

```bash
ELEVENLABS_API_KEY=...
```

Recommended:

```bash
ELEVENLABS_VOICE_ID=JBFqnCBsd6RMkjVDRZzb
ELEVENLABS_STT_MODEL=scribe_v2
ELEVENLABS_TTS_MODEL=eleven_multilingual_v2
```

By default, voice chat uses `LifeAiService.coachReply()` with the authenticated Chronos user. Set `CHRONOS_VOICE_CHAT_URL` only if you want to proxy voice turns to another chat service.

Optional ElevenLabs agent widget:

```bash
ELEVENLABS_AGENT_ID=agent_...
```

All voice endpoints except `/config` use the existing `requireAuth` middleware.
