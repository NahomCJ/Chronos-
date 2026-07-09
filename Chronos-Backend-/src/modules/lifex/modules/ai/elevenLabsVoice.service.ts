import { LifeAiService } from "./lifeAi.service";

type FetchLike = (input: string, init?: Record<string, unknown>) => Promise<any>;

export interface VoiceChatHistoryItem {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

export interface VoiceChatInput {
  userId?: string;
  conversationId?: string;
  message?: string;
  audioBase64?: string;
  audioDataUrl?: string;
  mimeType?: string;
  fileName?: string;
  context?: Record<string, unknown>;
  history?: VoiceChatHistoryItem[];
  voiceId?: string;
  languageCode?: string;
}

export interface VoiceChatResponse {
  transcript: string;
  reply: string;
  audioBase64: string;
  audioMimeType: string;
  conversationId?: string;
}

interface ParsedAudio {
  buffer: Buffer;
  mimeType: string;
  fileName: string;
}

const ELEVENLABS_API_BASE_URL = 'https://api.elevenlabs.io/v1';
const DEFAULT_VOICE_ID = 'JBFqnCBsd6RMkjVDRZzb';
const DEFAULT_OUTPUT_FORMAT = 'mp3_44100_128';

export class ElevenLabsVoiceService {
  private readonly fetchImpl: FetchLike;
  private readonly apiKey?: string;
  private readonly lifeAiService: LifeAiService;

  constructor(fetchImpl?: FetchLike) {
    this.fetchImpl = fetchImpl || (globalThis as any).fetch;
    this.apiKey = process.env.ELEVENLABS_API_KEY || process.env.XI_API_KEY;
    this.lifeAiService = new LifeAiService();
  }

  async createSignedConversationUrl(options: {
    agentId?: string;
    branchId?: string;
    environment?: string;
    includeConversationId?: boolean;
  } = {}): Promise<{ signedUrl: string; agentId: string }> {
    this.assertElevenLabsReady();

    const agentId = options.agentId || process.env.ELEVENLABS_AGENT_ID;
    if (!agentId) {
      throw new Error('ELEVENLABS_AGENT_ID is required to create a signed conversation URL.');
    }

    const params = new URLSearchParams({
      agent_id: agentId,
      include_conversation_id: String(Boolean(options.includeConversationId)),
    });

    if (options.branchId) {
      params.set('branch_id', options.branchId);
    }

    if (options.environment) {
      params.set('environment', options.environment);
    }

    const response = await this.fetchJson(
      `${ELEVENLABS_API_BASE_URL}/convai/conversation/get-signed-url?${params.toString()}`,
      {
        method: 'GET',
        headers: this.elevenLabsHeaders(),
      },
    );

    return {
      signedUrl: response.signed_url,
      agentId,
    };
  }

  async chatFromText(input: VoiceChatInput): Promise<VoiceChatResponse> {
    const transcript = this.requireText(input.message, 'message');
    const reply = await this.getChronosReply(transcript, input);
    const speech = await this.textToSpeech(reply, input.voiceId);

    return {
      transcript,
      reply,
      audioBase64: speech.audioBase64,
      audioMimeType: speech.mimeType,
      conversationId: input.conversationId,
    };
  }

  async chatFromAudio(input: VoiceChatInput): Promise<VoiceChatResponse> {
    const audio = this.parseAudio(input);
    const transcript = await this.speechToText(audio, input.languageCode);
    const reply = await this.getChronosReply(transcript, input);
    const speech = await this.textToSpeech(reply, input.voiceId);

    return {
      transcript,
      reply,
      audioBase64: speech.audioBase64,
      audioMimeType: speech.mimeType,
      conversationId: input.conversationId,
    };
  }

  private async speechToText(audio: ParsedAudio, languageCode?: string): Promise<string> {
    this.assertElevenLabsReady();

    const FormDataCtor = (globalThis as any).FormData;
    const BlobCtor = (globalThis as any).Blob;

    if (!FormDataCtor || !BlobCtor) {
      throw new Error('Node runtime must provide global FormData and Blob for ElevenLabs speech-to-text uploads.');
    }

    const form = new FormDataCtor();
    form.append('model_id', process.env.ELEVENLABS_STT_MODEL || 'scribe_v2');
    form.append('file', new BlobCtor([audio.buffer], { type: audio.mimeType }), audio.fileName);

    if (languageCode) {
      form.append('language_code', languageCode);
    }

    const response = await this.fetchJson(`${ELEVENLABS_API_BASE_URL}/speech-to-text`, {
      method: 'POST',
      headers: this.elevenLabsHeaders(),
      body: form,
    });

    return this.requireText(response.text, 'transcript');
  }

  private async textToSpeech(text: string, voiceId?: string): Promise<{ audioBase64: string; mimeType: string }> {
    this.assertElevenLabsReady();

    const selectedVoiceId = voiceId || process.env.ELEVENLABS_VOICE_ID || DEFAULT_VOICE_ID;
    const outputFormat = process.env.ELEVENLABS_OUTPUT_FORMAT || DEFAULT_OUTPUT_FORMAT;
    const url = `${ELEVENLABS_API_BASE_URL}/text-to-speech/${encodeURIComponent(selectedVoiceId)}?output_format=${encodeURIComponent(outputFormat)}`;

    const response = await this.fetchImpl(url, {
      method: 'POST',
      headers: {
        ...this.elevenLabsHeaders(),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        text,
        model_id: process.env.ELEVENLABS_TTS_MODEL || 'eleven_multilingual_v2',
        voice_settings: {
          stability: Number(process.env.ELEVENLABS_VOICE_STABILITY || 0.45),
          similarity_boost: Number(process.env.ELEVENLABS_VOICE_SIMILARITY_BOOST || 0.8),
          style: Number(process.env.ELEVENLABS_VOICE_STYLE || 0.25),
          use_speaker_boost: process.env.ELEVENLABS_SPEAKER_BOOST !== 'false',
        },
      }),
    });

    if (!response.ok) {
      throw new Error(await this.formatElevenLabsError(response, 'text-to-speech'));
    }

    const contentType = response.headers?.get?.('content-type') || 'audio/mpeg';
    const audioBuffer = Buffer.from(await response.arrayBuffer());

    return {
      audioBase64: audioBuffer.toString('base64'),
      mimeType: contentType,
    };
  }

  private async getChronosReply(transcript: string, input: VoiceChatInput): Promise<string> {
    const chatUrl = process.env.CHRONOS_VOICE_CHAT_URL || process.env.CHRONOS_TEXT_CHAT_URL;

    if (!chatUrl && input.userId) {
      const response = await this.lifeAiService.coachReply(input.userId, transcript);
      return this.extractReplyText(response);
    }

    if (!chatUrl) {
      return [
        `I heard: "${transcript}".`,
        'Chronos voice input and ElevenLabs speech output are connected, but no authenticated Chronos user was attached to this request.',
      ].join(' ');
    }

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    if (process.env.CHRONOS_VOICE_CHAT_AUTH_TOKEN) {
      headers.Authorization = `Bearer ${process.env.CHRONOS_VOICE_CHAT_AUTH_TOKEN}`;
    }

    const response = await this.fetchJson(chatUrl, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        message: transcript,
        transcript,
        userId: input.userId,
        conversationId: input.conversationId,
        context: input.context,
        history: input.history,
        source: 'chronos-elevenlabs-voice',
      }),
    });

    return this.extractReplyText(response);
  }

  private extractReplyText(response: any): string {
    const candidates = [
      response?.reply,
      response?.response,
      response?.message,
      response?.text,
      response?.answer,
      response?.data?.reply,
      response?.data?.response,
      response?.data?.message,
      response?.data?.text,
      response?.result?.reply,
      response?.result?.response,
      response?.result?.message,
      response?.result?.text,
    ];

    const reply = candidates.find((candidate) => typeof candidate === 'string' && candidate.trim().length > 0);
    if (!reply) {
      throw new Error('Chronos chat endpoint did not return a reply string.');
    }

    return reply.trim();
  }

  private parseAudio(input: VoiceChatInput): ParsedAudio {
    const dataUrlMatch = input.audioDataUrl?.match(/^data:([^;,]+)?(;[^,]*)?,(.*)$/);
    const mimeType = input.mimeType || dataUrlMatch?.[1] || 'audio/webm';
    const encoded = input.audioBase64 || dataUrlMatch?.[3];

    if (!encoded) {
      throw new Error('audioBase64 or audioDataUrl is required.');
    }

    const buffer = Buffer.from(encoded.replace(/\s/g, ''), 'base64');
    if (buffer.length === 0) {
      throw new Error('Audio payload is empty.');
    }

    return {
      buffer,
      mimeType,
      fileName: input.fileName || this.defaultAudioFileName(mimeType),
    };
  }

  private defaultAudioFileName(mimeType: string): string {
    if (mimeType.includes('wav')) {
      return 'chronos-voice.wav';
    }

    if (mimeType.includes('mpeg') || mimeType.includes('mp3')) {
      return 'chronos-voice.mp3';
    }

    if (mimeType.includes('mp4')) {
      return 'chronos-voice.m4a';
    }

    return 'chronos-voice.webm';
  }

  private async fetchJson(url: string, init: Record<string, unknown>): Promise<any> {
    if (!this.fetchImpl) {
      throw new Error('Node runtime must provide global fetch.');
    }

    const response = await this.fetchImpl(url, init);
    if (!response.ok) {
      throw new Error(await this.formatElevenLabsError(response, url));
    }

    return response.json();
  }

  private async formatElevenLabsError(response: any, label: string): Promise<string> {
    const status = `${response.status || 'unknown'} ${response.statusText || ''}`.trim();
    let body = '';

    try {
      body = await response.text();
    } catch {
      body = 'Unable to read error body.';
    }

    return `Request failed for ${label}: ${status}${body ? ` - ${body}` : ''}`;
  }

  private elevenLabsHeaders(): Record<string, string> {
    return {
      'xi-api-key': this.apiKey || '',
    };
  }

  private assertElevenLabsReady(): void {
    if (!this.apiKey) {
      throw new Error('ELEVENLABS_API_KEY or XI_API_KEY is required.');
    }

    if (!this.fetchImpl) {
      throw new Error('Node runtime must provide global fetch.');
    }
  }

  private requireText(value: unknown, fieldName: string): string {
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw new Error(`${fieldName} is required.`);
    }

    return value.trim();
  }
}

export default new ElevenLabsVoiceService();
