// Single shared ElevenLabs client. Two independent integrations existed
// side by side (Chris/Panther's `/api/ai/voice/*` and the LifeX AI coach's
// `/api/lifex/ai/voice/*`), each with its own fetch logic, its own default
// voice/model, and its own env-var names (`ELEVENLABS_API_KEY` vs
// `XI_API_KEY`) — a recipe for drift where fixing one silently leaves the
// other broken. Both now call this module instead of ElevenLabs directly.

const ELEVENLABS_API_BASE_URL = "https://api.elevenlabs.io/v1";
const DEFAULT_VOICE_ID = "21m00Tcm4TlvDq8ikWAM"; // "Rachel" — Chris's established voice
const DEFAULT_TTS_MODEL = "eleven_multilingual_v2";
const DEFAULT_STT_MODEL = "scribe_v2";
const DEFAULT_OUTPUT_FORMAT = "mp3_44100_128";
// Hard ceiling enforced here regardless of what any individual caller
// validates, so a new route can't accidentally run up ElevenLabs costs on
// an unbounded LLM reply.
const MAX_SYNTHESIS_CHARS = 600;

function getApiKey(): string | undefined {
  return process.env.ELEVENLABS_API_KEY || process.env.XI_API_KEY;
}

export function isElevenLabsConfigured(): boolean {
  return Boolean(getApiKey());
}

function headers(): Record<string, string> {
  return { "xi-api-key": getApiKey() || "" };
}

async function describeError(response: Response, label: string): Promise<string> {
  const status = `${response.status} ${response.statusText || ""}`.trim();
  let body = "";
  try {
    body = (await response.text()).slice(0, 300);
  } catch {
    body = "";
  }
  return `${label} failed (${status})${body ? `: ${body}` : ""}`;
}

export interface SynthesisOptions {
  voiceId?: string;
  modelId?: string;
  outputFormat?: string;
  stability?: number;
  similarityBoost?: number;
  style?: number;
  speakerBoost?: boolean;
}

export async function synthesizeSpeech(
  text: string,
  opts: SynthesisOptions = {}
): Promise<{ buffer: Buffer; mimeType: string }> {
  const apiKey = getApiKey();
  if (!apiKey) {
    throw new Error(
      "ELEVENLABS_API_KEY is not configured. Voice synthesis is unavailable."
    );
  }

  const trimmed = text.length > MAX_SYNTHESIS_CHARS
    ? text.slice(0, MAX_SYNTHESIS_CHARS)
    : text;

  const voiceId = opts.voiceId || process.env.ELEVENLABS_VOICE_ID || DEFAULT_VOICE_ID;
  const outputFormat = opts.outputFormat || process.env.ELEVENLABS_OUTPUT_FORMAT || DEFAULT_OUTPUT_FORMAT;
  const url = `${ELEVENLABS_API_BASE_URL}/text-to-speech/${encodeURIComponent(voiceId)}?output_format=${encodeURIComponent(outputFormat)}`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      ...headers(),
      "Content-Type": "application/json",
      Accept: "audio/mpeg",
    },
    body: JSON.stringify({
      text: trimmed,
      model_id: opts.modelId || process.env.ELEVENLABS_TTS_MODEL || DEFAULT_TTS_MODEL,
      voice_settings: {
        stability: opts.stability ?? Number(process.env.ELEVENLABS_VOICE_STABILITY || 0.45),
        similarity_boost: opts.similarityBoost ?? Number(process.env.ELEVENLABS_VOICE_SIMILARITY_BOOST || 0.8),
        style: opts.style ?? Number(process.env.ELEVENLABS_VOICE_STYLE || 0.25),
        use_speaker_boost: opts.speakerBoost ?? process.env.ELEVENLABS_SPEAKER_BOOST !== "false",
      },
    }),
  });

  if (!response.ok) {
    const detail = await describeError(response, "ElevenLabs text-to-speech");
    console.error(`[elevenlabs] ${detail}`);
    throw new Error(detail);
  }

  const contentType = response.headers.get("content-type") || "audio/mpeg";
  const arrayBuffer = await response.arrayBuffer();
  return { buffer: Buffer.from(arrayBuffer), mimeType: contentType };
}

export async function speechToText(params: {
  buffer: Buffer;
  mimeType: string;
  fileName: string;
  languageCode?: string;
}): Promise<string> {
  const apiKey = getApiKey();
  if (!apiKey) {
    throw new Error(
      "ELEVENLABS_API_KEY is not configured. Voice transcription is unavailable."
    );
  }

  const form = new FormData();
  form.append("model_id", process.env.ELEVENLABS_STT_MODEL || DEFAULT_STT_MODEL);
  form.append("file", new Blob([new Uint8Array(params.buffer)], { type: params.mimeType }), params.fileName);
  if (params.languageCode) form.append("language_code", params.languageCode);

  const response = await fetch(`${ELEVENLABS_API_BASE_URL}/speech-to-text`, {
    method: "POST",
    headers: headers(),
    body: form,
  });

  if (!response.ok) {
    const detail = await describeError(response, "ElevenLabs speech-to-text");
    console.error(`[elevenlabs] ${detail}`);
    throw new Error(detail);
  }

  const data = (await response.json()) as { text?: string };
  if (!data.text || !data.text.trim()) {
    throw new Error("ElevenLabs speech-to-text returned an empty transcript.");
  }
  return data.text.trim();
}

export async function createSignedConversationUrl(options: {
  agentId?: string;
  branchId?: string;
  environment?: string;
  includeConversationId?: boolean;
} = {}): Promise<{ signedUrl: string; agentId: string }> {
  const apiKey = getApiKey();
  if (!apiKey) {
    throw new Error("ELEVENLABS_API_KEY is not configured.");
  }

  const agentId = options.agentId || process.env.ELEVENLABS_AGENT_ID;
  if (!agentId) {
    throw new Error("ELEVENLABS_AGENT_ID is required to create a signed conversation URL.");
  }

  const params = new URLSearchParams({
    agent_id: agentId,
    include_conversation_id: String(Boolean(options.includeConversationId)),
  });
  if (options.branchId) params.set("branch_id", options.branchId);
  if (options.environment) params.set("environment", options.environment);

  const response = await fetch(
    `${ELEVENLABS_API_BASE_URL}/convai/conversation/get-signed-url?${params.toString()}`,
    { headers: headers() }
  );

  if (!response.ok) {
    const detail = await describeError(response, "ElevenLabs signed conversation URL");
    throw new Error(detail);
  }

  const data = (await response.json()) as { signed_url: string };
  return { signedUrl: data.signed_url, agentId };
}

// Cheap health check — hits ElevenLabs' subscription endpoint (spends no
// characters) so a missing/invalid key or an exhausted monthly character
// quota can be diagnosed directly instead of guessing from a silent
// client-side fallback.
export interface VoiceHealth {
  configured: boolean;
  ok: boolean;
  detail?: string;
  charactersUsed?: number;
  charactersLimit?: number;
}

export async function checkHealth(): Promise<VoiceHealth> {
  const apiKey = getApiKey();
  if (!apiKey) {
    return {
      configured: false,
      ok: false,
      detail: "ELEVENLABS_API_KEY is not set on this environment.",
    };
  }

  try {
    const response = await fetch(`${ELEVENLABS_API_BASE_URL}/user/subscription`, {
      headers: headers(),
    });
    if (!response.ok) {
      return {
        configured: true,
        ok: false,
        detail: await describeError(response, "ElevenLabs key check"),
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
