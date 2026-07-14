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

export interface RiskFlags {
  level: "LOW" | "MEDIUM" | "HIGH";
  flags: string[];
  summary: string;
}

export async function runRiskFraudCheck(
  ctx: UserFinancialContext,
  responseMode: ResponseMode
): Promise<RiskFlags> {
  const level = ctx.userLevel as UserLevel;
  const systemPrompt = compileSystemPrompt("BANKING", level, responseMode);
  const contextSummary = summarizeContextForLLM(ctx);

  const prompt = `Here is the user's financial data:

${contextSummary}

TASK: Perform a risk and anomaly check. Look for:
1. Unusually large or rapid withdrawals
2. Duplicate or repeated transactions
3. High spending velocity this period vs. previous patterns
4. Risk of overdraft based on current balance and upcoming obligations
5. Suspicious merchant patterns

Return your response in this exact JSON format (no markdown):
{
  "level": "LOW" | "MEDIUM" | "HIGH",
  "flags": ["flag1", "flag2"],
  "summary": "One sentence summary for the user"
}`;

  try {
    const raw = await callLLM({
      systemPrompt,
      messages: [{ role: "user", content: prompt }],
      model: "claude-sonnet-5",
      maxTokens: 512,
    });

    const parsed = JSON.parse(raw) as RiskFlags;
    return parsed;
  } catch {
    return {
      level: "LOW",
      flags: [],
      summary: "No significant risk patterns detected.",
    };
  }
}
