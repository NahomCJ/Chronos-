import { getUserFinancialContext } from "./core/data-retrieval.service";
import { routeQuery } from "./core/routing-agent";
import { checkCompliance } from "./core/compliance-guard";
import {
  compileMultiDomainResponse,
  AgentResult,
} from "./core/response-compiler";
import { runBankingAnalyst } from "./agents/banking/banking-analyst.agent";
import { runPredictiveFinance } from "./agents/banking/predictive-finance.agent";
import { runBnplChat } from "./agents/tickpay/affordability.agent";
import { runBlockHubAgent } from "./agents/blockhub/blockhub.agent";
import {
  runLifeXAgent,
  detectLifexDomain,
} from "./agents/lifex/lifestyle.agent";
import { callLLM, LLMMessage } from "./llm/claude.client";
import {
  compileSystemPrompt,
  UserLevel,
  ResponseMode,
} from "./llm/prompt-compiler";
import { summarizeContextForLLM } from "./core/data-retrieval.service";

export interface OrchestratorInput {
  userId: string;
  message: string;
  responseMode?: ResponseMode;
  history?: LLMMessage[];
}

export interface OrchestratorOutput {
  reply: string;
  domain: string;
  userLevel: string;
}

export async function runPanther(
  input: OrchestratorInput
): Promise<OrchestratorOutput> {
  const { userId, message, responseMode = "text", history = [] } = input;

  const ctx = await getUserFinancialContext(userId);
  const domain = await routeQuery(message);
  const userLevel = ctx.userLevel as UserLevel;

  let rawReply: string;
  const results: AgentResult[] = [];

  switch (domain) {
    case "BANKING": {
      const isPredictive =
        /predict|forecast|next month|future|how much will|overdraft|will i have|safe to spend/i.test(
          message
        );
      rawReply = isPredictive
        ? await runPredictiveFinance(ctx, message, responseMode, history)
        : await runBankingAnalyst(ctx, message, responseMode, history);
      results.push({ domain, content: rawReply });
      break;
    }

    case "TICKPAY": {
      rawReply = await runBnplChat(ctx, message, responseMode, history);
      results.push({ domain, content: rawReply });
      break;
    }

    case "BLOCKHUB": {
      rawReply = await runBlockHubAgent(ctx, message, responseMode);
      results.push({ domain, content: rawReply });
      break;
    }

    case "LIFEX": {
      const lifexDomain = detectLifexDomain(message);
      rawReply = await runLifeXAgent(
        ctx,
        message,
        lifexDomain,
        responseMode,
        history
      );
      results.push({ domain, content: rawReply });
      break;
    }

    case "UNIFIED":
    default: {
      const systemPrompt = compileSystemPrompt("UNIFIED", userLevel, responseMode);
      const contextSummary = summarizeContextForLLM(ctx);

      const unifiedPrompt = `Here is the user's complete financial data:

${contextSummary}

User question: ${message}

Provide a unified answer that draws on all relevant domains (banking, TickPay/BNPL, and lifestyle). Give one cohesive, level-appropriate response — not separate sections for each domain.`;

      rawReply = await callLLM({
        systemPrompt,
        messages: [...history, { role: "user", content: unifiedPrompt }],
        model: "claude-sonnet-4-6",
        maxTokens: 1200,
      });
      results.push({ domain: "UNIFIED", content: rawReply });
      break;
    }
  }

  const compiled = compileMultiDomainResponse(results, responseMode);
  const safeReply = await checkCompliance(compiled);

  return {
    reply: safeReply,
    domain,
    userLevel: ctx.userLevel,
  };
}
