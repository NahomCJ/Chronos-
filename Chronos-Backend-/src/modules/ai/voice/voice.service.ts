import OpenAI from "openai";
import fs from "fs";
import path from "path";
import os from "os";

let _openaiClient: OpenAI | null = null;
function getOpenAIClient(): OpenAI {
  if (!_openaiClient) {
    if (!process.env.OPENAI_API_KEY) {
      throw new Error("OPENAI_API_KEY is not configured. Voice transcription is unavailable.");
    }
    _openaiClient = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
  }
  return _openaiClient;
}

const ELEVENLABS_API_KEY = process.env.ELEVENLABS_API_KEY;
const ELEVENLABS_VOICE_ID =
  process.env.ELEVENLABS_VOICE_ID || "21m00Tcm4TlvDq8ikWAM";

export async function transcribeAudio(audioBuffer: Buffer): Promise<string> {
  const tmpFile = path.join(os.tmpdir(), `panther-voice-${Date.now()}.webm`);
  fs.writeFileSync(tmpFile, audioBuffer);

  try {
    const transcription = await getOpenAIClient().audio.transcriptions.create({
      file: fs.createReadStream(tmpFile),
      model: "whisper-1",
      language: "en",
    });
    return transcription.text;
  } finally {
    fs.unlinkSync(tmpFile);
  }
}

export async function synthesizeSpeech(text: string): Promise<Buffer> {
  if (!ELEVENLABS_API_KEY) {
    throw new Error(
      "ELEVENLABS_API_KEY is not configured. Voice synthesis is unavailable."
    );
  }

  const response = await fetch(
    `https://api.elevenlabs.io/v1/text-to-speech/${ELEVENLABS_VOICE_ID}`,
    {
      method: "POST",
      headers: {
        "xi-api-key": ELEVENLABS_API_KEY,
        "Content-Type": "application/json",
        Accept: "audio/mpeg",
      },
      body: JSON.stringify({
        text,
        model_id: "eleven_monolingual_v1",
        voice_settings: { stability: 0.5, similarity_boost: 0.75 },
      }),
    }
  );

  if (!response.ok) {
    // response.statusText is frequently empty/unhelpful (varies by runtime) —
    // ElevenLabs puts the actual reason (invalid key, quota exceeded, voice
    // not found, etc.) in the JSON body, which was previously discarded, so
    // every synthesis failure looked identical from the client's point of
    // view no matter the real cause.
    let detail = response.statusText;
    try {
      const body = await response.text();
      if (body) detail = body.slice(0, 300);
    } catch {
      // keep statusText fallback
    }
    console.error(
      `[voice.synthesize] ElevenLabs ${response.status}: ${detail}`
    );
    throw new Error(
      `ElevenLabs synthesis failed (${response.status}): ${detail}`
    );
  }

  const arrayBuffer = await response.arrayBuffer();
  return Buffer.from(arrayBuffer);
}

// Cheap health check — hits ElevenLabs' subscription endpoint (no
// characters spent) so misconfiguration (missing/invalid key, exhausted
// monthly character quota) can be diagnosed directly instead of guessing
// from a silent client-side fallback to the on-device voice.
export interface VoiceHealth {
  configured: boolean;
  ok: boolean;
  detail?: string;
  charactersUsed?: number;
  charactersLimit?: number;
}

export async function checkVoiceHealth(): Promise<VoiceHealth> {
  if (!ELEVENLABS_API_KEY) {
    return {
      configured: false,
      ok: false,
      detail: "ELEVENLABS_API_KEY is not set on this environment.",
    };
  }

  try {
    const response = await fetch("https://api.elevenlabs.io/v1/user/subscription", {
      headers: { "xi-api-key": ELEVENLABS_API_KEY },
    });
    if (!response.ok) {
      const body = await response.text().catch(() => "");
      return {
        configured: true,
        ok: false,
        detail: `ElevenLabs rejected the configured key (${response.status}): ${body.slice(0, 300)}`,
      };
    }
    const data = (await response.json()) as {
      character_count?: number;
      character_limit?: number;
    };
    const used = data.character_count ?? 0;
    const limit = data.character_limit ?? 0;
    const exhausted = limit > 0 && used >= limit;
    return {
      configured: true,
      ok: !exhausted,
      detail: exhausted
        ? `Monthly character quota exhausted (${used}/${limit}).`
        : undefined,
      charactersUsed: used,
      charactersLimit: limit,
    };
  } catch (err) {
    return {
      configured: true,
      ok: false,
      detail: err instanceof Error ? err.message : "Network error reaching ElevenLabs",
    };
  }
}
