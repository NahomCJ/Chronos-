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

export type LifexDomain =
  | "EDUCATION"
  | "FINANCIAL"
  | "HEALTH"
  | "SPIRITUAL"
  | "VISION"
  | "SOCIAL"
  | "RELATIONSHIPS"
  | "GENERAL";

const DOMAIN_FOCUS: Record<LifexDomain, string> = {
  EDUCATION:
    "Focus on learning goals, course recommendations, scholarships, and skill development.",
  FINANCIAL:
    "Focus on connecting life goals with financial decisions — savings for goals, budget adjustments for priorities.",
  HEALTH:
    "Focus on fitness habits, wellness goals, HSA usage, and health milestone tracking.",
  SPIRITUAL:
    "Focus on spiritual goals, faith-based financial giving, charitable contributions, and community involvement.",
  VISION:
    "Focus on long-term life goals, vision board progress, milestones, and motivational insights.",
  SOCIAL:
    "Focus on social goals, community engagement, networking, and social spending optimization.",
  RELATIONSHIPS:
    "Focus on family and relationship goals, shared financial planning, and milestone reminders.",
  GENERAL:
    "Provide a holistic view across all 7 life domains based on the user's habits and goals.",
};

export async function runLifeXAgent(
  ctx: UserFinancialContext,
  userMessage: string,
  domain: LifexDomain,
  responseMode: ResponseMode
): Promise<string> {
  const level = ctx.userLevel as UserLevel;
  const systemPrompt = compileSystemPrompt("LIFEX", level, responseMode);
  const contextSummary = summarizeContextForLLM(ctx);

  const domainInstruction = DOMAIN_FOCUS[domain];

  const prompt = `Here is the user's data:

${contextSummary}

LifeX Domain: ${domain}
${domainInstruction}

User question: ${userMessage}

Provide personalized, actionable guidance for this life domain. Connect their financial data to their life goals where relevant. Be encouraging and practical.`;

  return callLLM({
    systemPrompt,
    messages: [{ role: "user", content: prompt }],
    model: "claude-sonnet-4-6",
    maxTokens: 1024,
  });
}

export function detectLifexDomain(message: string): LifexDomain {
  const lower = message.toLowerCase();
  if (/course|learn|study|scholarship|tutor|education|skill/.test(lower))
    return "EDUCATION";
  if (/gym|health|fitness|workout|diet|meal|calories|exercise|hsa/.test(lower))
    return "HEALTH";
  if (/faith|spiritual|church|mosque|temple|donate|charity|tithe/.test(lower))
    return "SPIRITUAL";
  if (/goal|vision|milestone|dream|plan|future|ambition/.test(lower))
    return "VISION";
  if (/friend|social|community|network|event|party/.test(lower))
    return "SOCIAL";
  if (/family|relationship|partner|anniversary|birthday/.test(lower))
    return "RELATIONSHIPS";
  if (/budget|save|spend|money|invest|finance/.test(lower)) return "FINANCIAL";
  return "GENERAL";
}
