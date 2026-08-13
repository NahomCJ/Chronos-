import { Request, Response } from "express";
import { processChrisChat } from "./chris.service";
import { ResponseMode } from "../panther/llm/prompt-compiler";
import { LLMMessage } from "../panther/llm/llm.client";

function sanitizeHistory(raw: unknown): LLMMessage[] {
  if (!Array.isArray(raw)) return [];
  return raw
    .filter(
      (turn): turn is { role: string; content: string } =>
        !!turn &&
        typeof turn === "object" &&
        (turn.role === "user" || turn.role === "assistant") &&
        typeof turn.content === "string"
    )
    .slice(-10)
    .map((turn) => ({
      role: turn.role as "user" | "assistant",
      content: turn.content,
    }));
}

export async function chrisChat(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;

  if (!userId) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  const { message, responseMode, history } = req.body as {
    message?: string;
    responseMode?: ResponseMode;
    history?: unknown;
  };

  if (!message || typeof message !== "string") {
    res.status(400).json({ error: "message is required" });
    return;
  }

  try {
    const result = await processChrisChat({
      userId,
      message,
      responseMode: responseMode ?? "text",
      history: sanitizeHistory(history),
    });
    res.status(200).json(result);
  } catch (err) {
    const message =
      err instanceof Error ? err.message : "AI processing failed";
    res.status(500).json({ error: message });
  }
}
