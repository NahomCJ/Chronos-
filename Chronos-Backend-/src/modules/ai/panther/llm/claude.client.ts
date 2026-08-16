import Anthropic from "@anthropic-ai/sdk";
import { CircuitBreaker } from "./circuit-breaker";

// Claude is the fallback provider (llm.client.ts calls this when DeepSeek
// errors or times out) — a longer budget than DeepSeek's since there's no
// further fallback behind it, but still bounded so a hung call fails fast
// with a clear error instead of hanging the request indefinitely.
const breaker = new CircuitBreaker("claude", {
  failureThreshold: 3,
  resetTimeoutMs: 30_000,
  callTimeoutMs: 20_000,
  maxConcurrent: 20,
});

let _client: Anthropic | null = null;
function getClient(): Anthropic {
  if (!_client) {
    if (!process.env.ANTHROPIC_API_KEY) {
      throw new Error("ANTHROPIC_API_KEY environment variable is not set");
    }
    _client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  }
  return _client;
}

export type ClaudeModel = "claude-haiku-4-5-20251001" | "claude-sonnet-5";

export interface LLMMessage {
  role: "user" | "assistant";
  content: string;
}

export interface LLMCallOptions {
  systemPrompt: string;
  messages: LLMMessage[];
  model?: ClaudeModel;
  maxTokens?: number;
}

export async function callLLM(options: LLMCallOptions): Promise<string> {
  const {
    systemPrompt,
    messages,
    model = "claude-sonnet-5",
    maxTokens = 1024,
  } = options;

  const response = await breaker.execute(() =>
    getClient().messages.create({
      model,
      max_tokens: maxTokens,
      system: [
        {
          type: "text",
          text: systemPrompt,
          cache_control: { type: "ephemeral" },
        },
      ],
      messages,
    })
  );

  const block = response.content[0];
  if (block.type !== "text") return "";
  return block.text;
}

export async function callLLMFast(
  systemPrompt: string,
  userMessage: string
): Promise<string> {
  return callLLM({
    systemPrompt,
    messages: [{ role: "user", content: userMessage }],
    model: "claude-haiku-4-5-20251001",
    maxTokens: 512,
  });
}
