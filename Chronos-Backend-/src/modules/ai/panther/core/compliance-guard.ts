import { callLLMFast } from "../llm/claude.client";

const GUARD_PROMPT = `You are a financial AI compliance checker.

Review the AI response below. If it contains any of the following violations, return ONLY the word: VIOLATION
- Recommends buying or selling specific investment assets (stocks, crypto, funds) with certainty
- Guarantees financial returns or profits
- Fabricates specific numbers not grounded in data
- Provides unlicensed tax or legal advice presented as fact

If the response is safe and appropriate, return ONLY the word: SAFE

Reply with a single word only: SAFE or VIOLATION`;

export async function checkCompliance(aiResponse: string): Promise<string> {
  try {
    const result = await callLLMFast(
      GUARD_PROMPT,
      `AI Response to check:\n${aiResponse}`
    );

    if (result.trim().toUpperCase() === "VIOLATION") {
      return "I can see what you're asking about, but I'm not able to provide that specific type of financial advice. I can share general insights based on your data — would that help?";
    }

    return aiResponse;
  } catch {
    return aiResponse;
  }
}
