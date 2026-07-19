import { callLLM } from "../../llm/claude.client";
import {
  compileSystemPrompt,
  UserLevel,
  ResponseMode,
} from "../../llm/prompt-compiler";
import { UserFinancialContext } from "../../core/data-retrieval.service";

export interface ProductSearchResult {
  query: string;
  budget: number;
  bnplEligible: boolean;
  message: string;
  note: string;
}

export async function runMarketplaceSearch(
  ctx: UserFinancialContext,
  searchQuery: string,
  maxBudget: number | null,
  responseMode: ResponseMode
): Promise<ProductSearchResult> {
  const level = ctx.userLevel as UserLevel;
  const systemPrompt = compileSystemPrompt("TICKPAY", level, responseMode);

  const available = ctx.tickPay?.available ?? 0;
  const budget = maxBudget ?? available;
  const bnplEligible = available > 0 && budget <= available;

  const prompt = `User wants to search for: "${searchQuery}"
Max budget: $${budget.toFixed(2)}
Available TickPay credit: $${available.toFixed(2)}
BNPL eligible for this budget: ${bnplEligible ? "Yes" : "No"}

Note: Product search via external APIs (Firecrawl) is not yet connected. Respond to the user explaining what Chris (our buying agent) will do for them, confirm their budget and BNPL eligibility, and let them know this feature is coming soon with real product results. Be helpful and exciting about it. Keep to user level: ${ctx.userLevel}.`;

  const message = await callLLM({
    systemPrompt,
    messages: [{ role: "user", content: prompt }],
    model: "claude-haiku-4-5-20251001",
    maxTokens: 512,
  });

  return {
    query: searchQuery,
    budget,
    bnplEligible,
    message,
    note: "Live product search via Firecrawl will be connected in the next phase.",
  };
}
