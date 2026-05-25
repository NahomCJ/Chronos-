import { runPanther } from "../panther/orchestrator";
import { ResponseMode } from "../panther/llm/prompt-compiler";

export interface ChatInput {
  userId: string;
  message: string;
  responseMode?: ResponseMode;
}

export interface ChatOutput {
  reply: string;
  domain: string;
  userLevel: string;
  timestamp: string;
}

export async function processChrisChat(input: ChatInput): Promise<ChatOutput> {
  const { userId, message, responseMode = "text" } = input;

  if (!message || message.trim().length === 0) {
    throw new Error("Message cannot be empty");
  }

  if (message.length > 2000) {
    throw new Error("Message too long — please keep it under 2000 characters");
  }

  const result = await runPanther({ userId, message, responseMode });

  return {
    reply: result.reply,
    domain: result.domain,
    userLevel: result.userLevel,
    timestamp: new Date().toISOString(),
  };
}
