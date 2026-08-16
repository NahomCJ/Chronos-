import OpenAI from "openai";
import { CircuitBreaker } from "./circuit-breaker";

// DeepSeek is the primary provider for every chatbot call in this app — a
// hung or slow-but-not-erroring response would otherwise block on the SDK's
// default timeout before llm.client.ts's fallback ever kicks in.
const breaker = new CircuitBreaker("deepseek", {
  failureThreshold: 3,
  resetTimeoutMs: 30_000,
  callTimeoutMs: 8_000,
  maxConcurrent: 20,
});

let _client: OpenAI | null = null;
function getClient(): OpenAI {
  if (!_client) {
    if (!process.env.DEEPSEEK_API_KEY) {
      throw new Error("DEEPSEEK_API_KEY environment variable is not set");
    }
    _client = new OpenAI({
      apiKey: process.env.DEEPSEEK_API_KEY,
      baseURL: "https://api.deepseek.com",
    });
  }
  return _client;
}

export type DeepSeekModel = "deepseek-chat" | "deepseek-reasoner";

export interface LLMMessage {
  role: "user" | "assistant";
  content: string;
}

export interface LLMCallOptions {
  systemPrompt: string;
  messages: LLMMessage[];
  model?: DeepSeekModel;
  maxTokens?: number;
}

// DeepSeek's API is OpenAI-compatible, so this reuses the `openai` package
// already installed for Whisper transcription — just pointed at DeepSeek's
// base URL instead of a second SDK dependency.
export async function callLLM(options: LLMCallOptions): Promise<string> {
  const {
    systemPrompt,
    messages,
    model = "deepseek-chat",
    maxTokens = 1024,
  } = options;

  const response = await breaker.execute(() =>
    getClient().chat.completions.create({
      model,
      max_tokens: maxTokens,
      messages: [{ role: "system", content: systemPrompt }, ...messages],
    })
  );

  return response.choices[0]?.message?.content ?? "";
}

export async function callLLMFast(
  systemPrompt: string,
  userMessage: string
): Promise<string> {
  return callLLM({
    systemPrompt,
    messages: [{ role: "user", content: userMessage }],
    model: "deepseek-chat",
    maxTokens: 512,
  });
}
