import { callLLMFast } from "../llm/llm.client";
import { AgentDomain } from "../llm/prompt-compiler";

const ROUTING_PROMPT = `You are a query router for Chris, an AI assistant inside the Chronos finance app. Given a user message, classify it into exactly one of these domains:

BANKING - spending analysis, budgeting, cashflow, account balances, savings, transfers, bill payments, financial health score, transaction history, salary, overdraft, fees
TICKPAY - buy now pay later, BNPL, affordability check, product search, price comparison, purchases, shopping, installments, TickPay account
BLOCKHUB - crypto, cryptocurrency, bitcoin, ethereum, blockchain, NFT, portfolio, trading, market prices, wallet, tokens
LIFEX - life goals, health, fitness, education, courses, habits, wellness, relationships, spirituality, social, vision board, scholarships
UNIFIED - question spans multiple domains above, or a general overview of the user's own finances ("how am I doing overall")
GENERAL - greetings and small talk ("hi", "how are you"), general knowledge, casual conversation, or anything that is not about the user's own finances, crypto, purchases, or life goals. If in doubt and the message isn't clearly about the user's financial data, choose GENERAL.

Reply with ONLY one word: BANKING, TICKPAY, BLOCKHUB, LIFEX, UNIFIED, or GENERAL.`;

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
      "GENERAL",
    ];
    return valid.includes(domain) ? domain : "GENERAL";
  } catch {
    return "GENERAL";
  }
}
