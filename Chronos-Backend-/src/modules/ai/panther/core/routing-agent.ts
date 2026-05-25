import { callLLMFast } from "../llm/claude.client";
import { AgentDomain } from "../llm/prompt-compiler";

const ROUTING_PROMPT = `You are a financial query router. Given a user message, classify it into exactly one of these domains:

BANKING - spending analysis, budgeting, cashflow, account balances, savings, transfers, bill payments, financial health score, transaction history, salary, overdraft, fees
TICKPAY - buy now pay later, BNPL, affordability check, product search, price comparison, purchases, shopping, installments, TickPay account
BLOCKHUB - crypto, cryptocurrency, bitcoin, ethereum, blockchain, NFT, portfolio, trading, market prices, wallet, tokens
LIFEX - life goals, health, fitness, education, courses, habits, wellness, relationships, spirituality, social, vision board, scholarships
UNIFIED - question spans multiple domains above, general financial overview, "how am I doing overall", or unclear

Reply with ONLY one word: BANKING, TICKPAY, BLOCKHUB, LIFEX, or UNIFIED.`;

export async function routeQuery(userMessage: string): Promise<AgentDomain> {
  try {
    const raw = await callLLMFast(ROUTING_PROMPT, userMessage);
    const domain = raw.trim().toUpperCase() as AgentDomain;
    const valid: AgentDomain[] = [
      "BANKING",
      "TICKPAY",
      "BLOCKHUB",
      "LIFEX",
      "UNIFIED",
    ];
    return valid.includes(domain) ? domain : "UNIFIED";
  } catch {
    return "UNIFIED";
  }
}
