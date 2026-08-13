import * as deepseek from "./deepseek.client";
import * as claude from "./claude.client";
import { LLMCallOptions } from "./claude.client";

export type { LLMMessage, LLMCallOptions, ClaudeModel } from "./claude.client";

// Single entry point for every chatbot integration in this backend (Chris's
// banking/tickpay/blockhub/lifex/general/unified agents, routing, compliance,
// and the LifeX AI coach). DeepSeek answers first; if it errors (not
// configured, rate-limited, network failure) this falls back to the existing
// Claude integration so a DeepSeek outage never takes Chris down.
export async function callLLM(options: LLMCallOptions): Promise<string> {
  try {
    return await deepseek.callLLM({
      systemPrompt: options.systemPrompt,
      messages: options.messages,
      maxTokens: options.maxTokens,
    });
  } catch (err) {
    const reason = err instanceof Error ? err.message : String(err);
    console.error(`[llm.client] DeepSeek call failed, falling back to Claude: ${reason}`);
    return claude.callLLM(options);
  }
}

export async function callLLMFast(
  systemPrompt: string,
  userMessage: string
): Promise<string> {
  try {
    return await deepseek.callLLMFast(systemPrompt, userMessage);
  } catch (err) {
    const reason = err instanceof Error ? err.message : String(err);
    console.error(`[llm.client] DeepSeek fast call failed, falling back to Claude: ${reason}`);
    return claude.callLLMFast(systemPrompt, userMessage);
  }
}
