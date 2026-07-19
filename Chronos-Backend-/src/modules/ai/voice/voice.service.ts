import OpenAI from "openai";
import fs from "fs";
import path from "path";
import os from "os";
import * as elevenlabs from "./elevenlabs.client";

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
  const { buffer } = await elevenlabs.synthesizeSpeech(text);
  return buffer;
}

export type VoiceHealth = elevenlabs.VoiceHealth;

export async function checkVoiceHealth(): Promise<VoiceHealth> {
  return elevenlabs.checkHealth();
}
