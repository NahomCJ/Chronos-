import { callLLM, LLMMessage } from "../../llm/llm.client";
import {
  compileSystemPrompt,
  UserLevel,
  ResponseMode,
} from "../../llm/prompt-compiler";
import {
  UserFinancialContext,
  summarizeContextForLLM,
} from "../../core/data-retrieval.service";

export interface AffordabilityResult {
  approved: boolean;
  riskScore: number;
  maxAmount: number;
  message: string;
  reasoning: string;
}

export async function runAffordabilityCheck(
  ctx: UserFinancialContext,
  purchaseAmount: number,
  merchant: string,
  responseMode: ResponseMode
): Promise<AffordabilityResult> {
  const level = ctx.userLevel as UserLevel;
  const systemPrompt = compileSystemPrompt("TICKPAY", level, responseMode);
  const contextSummary = summarizeContextForLLM(ctx);

  const prompt = `Here is the user's financial data:

${contextSummary}

BNPL AFFORDABILITY CHECK REQUEST:
Purchase amount: $${purchaseAmount.toFixed(2)}
Merchant: ${merchant}

Evaluate:
1. Can the user afford this BNPL purchase given their current balance and obligations?
2. What is the risk score (0-100, where 100 = highest risk)?
3. What is the maximum safe BNPL amount for this user?
4. Should we approve or decline this purchase?

Consider: available TickPay credit, upcoming installments, monthly salary vs. obligations, spending velocity.

Return ONLY valid JSON (no markdown):
{
  "approved": true | false,
  "riskScore": 0-100,
  "maxAmount": number,
  "message": "Short message for the user (level-appropriate)",
  "reasoning": "Internal reasoning (one sentence)"
}`;

  try {
    const raw = await callLLM({
      systemPrompt,
      messages: [{ role: "user", content: prompt }],
      model: "claude-sonnet-5",
      maxTokens: 512,
    });

    return JSON.parse(raw) as AffordabilityResult;
  } catch {
    const available = ctx.tickPay?.available ?? 0;
    return {
      approved: purchaseAmount <= available,
      riskScore: 50,
      maxAmount: available,
      message:
        purchaseAmount <= available
          ? "Purchase looks within your available limit."
          : "This purchase exceeds your available TickPay credit.",
      reasoning: "Fallback: compared purchase amount against available credit.",
    };
  }
}

export async function runBnplChat(
  ctx: UserFinancialContext,
  userMessage: string,
  responseMode: ResponseMode,
  history: LLMMessage[] = []
): Promise<string> {
  const level = ctx.userLevel as UserLevel;
  const systemPrompt = compileSystemPrompt("TICKPAY", level, responseMode);
  const contextSummary = summarizeContextForLLM(ctx);

  const prompt = `Here is the user's financial data:

${contextSummary}

User question about TickPay/BNPL: ${userMessage}

Answer based strictly on their data. Cover: available credit, repayment schedule, affordability, upcoming installments.`;

  return callLLM({
    systemPrompt,
    messages: [...history, { role: "user", content: prompt }],
    model: "claude-sonnet-5",
    maxTokens: 768,
  });
}
