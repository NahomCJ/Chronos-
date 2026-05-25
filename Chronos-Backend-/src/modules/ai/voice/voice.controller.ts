import { Request, Response } from "express";
import { transcribeAudio, synthesizeSpeech } from "./voice.service";

export async function transcribe(req: Request, res: Response): Promise<void> {
  const file = (req as any).file as
    | { buffer: Buffer; mimetype: string }
    | undefined;

  if (!file) {
    res.status(400).json({ error: "Audio file is required" });
    return;
  }

  try {
    const text = await transcribeAudio(file.buffer);
    res.status(200).json({ text });
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Transcription failed";
    res.status(500).json({ error: msg });
  }
}

export async function synthesize(req: Request, res: Response): Promise<void> {
  const { text } = req.body as { text?: string };

  if (!text || typeof text !== "string") {
    res.status(400).json({ error: "text is required" });
    return;
  }

  if (text.length > 500) {
    res.status(400).json({ error: "text must be under 500 characters for voice synthesis" });
    return;
  }

  try {
    const audioBuffer = await synthesizeSpeech(text);
    res.set("Content-Type", "audio/mpeg");
    res.set("Content-Length", audioBuffer.length.toString());
    res.status(200).send(audioBuffer);
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Speech synthesis failed";
    res.status(500).json({ error: msg });
  }
}
