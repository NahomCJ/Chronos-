import { callLLM, LLMMessage } from "../../llm/claude.client";
import {
  compileSystemPrompt,
  UserLevel,
  ResponseMode,
} from "../../llm/prompt-compiler";
import {
  UserFinancialContext,
  summarizeContextForLLM,
} from "../../core/data-retrieval.service";

export async function runPredictiveFinance(
  ctx: UserFinancialContext,
  userMessage: string,
  responseMode: ResponseMode,
  history: LLMMessage[] = []
): Promise<string> {
  const level = ctx.userLevel as UserLevel;
  const systemPrompt = compileSystemPrompt("BANKING", level, responseMode);
  const contextSummary = summarizeContextForLLM(ctx);

  const prompt = `Here is the user's current financial data:

${contextSummary}

User question: ${userMessage}

Focus on PREDICTION tasks: future balance projection, cashflow forecast, overdraft risk, salary arrival estimation, and safe-to-spend calculation. Use the transaction history to identify recurring patterns. Express all predictions with appropriate uncertainty. Base all numbers strictly on the data provided.`;

  return callLLM({
    systemPrompt,
    messages: [...history, { role: "user", content: prompt }],
    model: "claude-sonnet-5",
    maxTokens: 1024,
  });
}
