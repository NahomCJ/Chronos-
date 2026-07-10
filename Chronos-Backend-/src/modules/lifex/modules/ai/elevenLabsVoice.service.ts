import { LifeAiService } from "./lifeAi.service";
import * as elevenlabs from "../../../ai/voice/elevenlabs.client";

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

export class ElevenLabsVoiceService {
  private readonly lifeAiService: LifeAiService;

  constructor() {
    this.lifeAiService = new LifeAiService();
  }

  async createSignedConversationUrl(options: {
    agentId?: string;
    branchId?: string;
    environment?: string;
    includeConversationId?: boolean;
  } = {}): Promise<{ signedUrl: string; agentId: string }> {
    return elevenlabs.createSignedConversationUrl(options);
  }

  async chatFromText(input: VoiceChatInput): Promise<VoiceChatResponse> {
    const transcript = this.requireText(input.message, 'message');
    const reply = await this.getChronosReply(transcript, input);
    const speech = await elevenlabs.synthesizeSpeech(reply, { voiceId: input.voiceId });

    return {
      transcript,
      reply,
      audioBase64: speech.buffer.toString('base64'),
      audioMimeType: speech.mimeType,
      conversationId: input.conversationId,
    };
  }

  async chatFromAudio(input: VoiceChatInput): Promise<VoiceChatResponse> {
    const audio = this.parseAudio(input);
    const transcript = await elevenlabs.speechToText({
      buffer: audio.buffer,
      mimeType: audio.mimeType,
      fileName: audio.fileName,
      languageCode: input.languageCode,
    });
    const reply = await this.getChronosReply(transcript, input);
    const speech = await elevenlabs.synthesizeSpeech(reply, { voiceId: input.voiceId });

    return {
      transcript,
      reply,
      audioBase64: speech.buffer.toString('base64'),
      audioMimeType: speech.mimeType,
      conversationId: input.conversationId,
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

    const response = await fetch(chatUrl, {
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

    if (!response.ok) {
      const body = await response.text().catch(() => '');
      throw new Error(`Chronos chat endpoint failed (${response.status}): ${body.slice(0, 300)}`);
    }

    return this.extractReplyText(await response.json());
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

  private requireText(value: unknown, fieldName: string): string {
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw new Error(`${fieldName} is required.`);
    }

    return value.trim();
  }
}

export default new ElevenLabsVoiceService();
