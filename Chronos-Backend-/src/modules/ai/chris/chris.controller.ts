import { Request, Response } from "express";
import { processChrisChat } from "./chris.service";
import { ResponseMode } from "../panther/llm/prompt-compiler";

export async function chrisChat(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;

  if (!userId) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  const { message, responseMode } = req.body as {
    message?: string;
    responseMode?: ResponseMode;
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
    });
    res.status(200).json(result);
  } catch (err) {
    const message =
      err instanceof Error ? err.message : "AI processing failed";
    res.status(500).json({ error: message });
  }
}
