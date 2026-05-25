import { callLLM } from "../../llm/claude.client";
import {
  compileSystemPrompt,
  UserLevel,
  ResponseMode,
} from "../../llm/prompt-compiler";
import {
  UserFinancialContext,
  summarizeContextForLLM,
} from "../../core/data-retrieval.service";

export async function runBankingAnalyst(
  ctx: UserFinancialContext,
  userMessage: string,
  responseMode: ResponseMode
): Promise<string> {
  const level = ctx.userLevel as UserLevel;
  const systemPrompt = compileSystemPrompt("BANKING", level, responseMode);
  const contextSummary = summarizeContextForLLM(ctx);

  const prompt = `Here is the user's current financial data:

${contextSummary}

User question: ${userMessage}

Analyze their spending patterns, account activity, and financial health. Provide clear, actionable insights based strictly on the data above. Do not make up numbers.`;

  return callLLM({
    systemPrompt,
    messages: [{ role: "user", content: prompt }],
    model: "claude-sonnet-4-6",
    maxTokens: 1024,
  });
}
