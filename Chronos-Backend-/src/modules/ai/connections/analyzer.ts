import { callLLM } from '../panther/llm/llm.client';
import { AnalysisResult, AnalysisType, FetchedContent, Suggestion } from './types';

const SYSTEM_PROMPTS: Record<AnalysisType, string> = {
  pitch_deck: `You are an expert pitch deck reviewer and startup advisor with experience evaluating hundreds of investor decks.
Analyze the provided presentation content and return a JSON object with this exact shape (no markdown fences, raw JSON only):
{
  "summary": "2–3 sentence executive summary of the deck and its investor-readiness",
  "scores": {
    "narrative": 0-10,
    "market_opportunity": 0-10,
    "business_model": 0-10,
    "traction": 0-10,
    "overall": 0-10
  },
  "suggestions": [
    {
      "category": "Narrative|Market|Team|Financials|Design|CTA|Problem|Solution",
      "priority": "high|medium|low",
      "title": "Short actionable title (max 8 words)",
      "description": "Detailed explanation of what needs improvement and why",
      "action": "Specific step to take right now"
    }
  ]
}
Focus on: story arc, problem/solution clarity, market sizing, business model viability, team strength, financial projections, and call-to-action. Return 5–8 suggestions ordered by priority.`,

  code_review: `You are a senior software engineer and open-source advocate reviewing a GitHub repository or code file.
Analyze the provided content and return a JSON object with this exact shape (no markdown fences, raw JSON only):
{
  "summary": "2–3 sentence summary of the codebase quality and main observations",
  "scores": {
    "code_quality": 0-10,
    "documentation": 0-10,
    "security": 0-10,
    "maintainability": 0-10,
    "overall": 0-10
  },
  "suggestions": [
    {
      "category": "Architecture|Security|Documentation|Testing|Performance|DX|Dependencies",
      "priority": "high|medium|low",
      "title": "Short actionable title (max 8 words)",
      "description": "Detailed explanation",
      "action": "Specific step to take"
    }
  ]
}
Return 5–8 suggestions ordered by priority.`,

  profile: `You are a professional profile and personal brand analyst.
Analyze the provided profile content and return a JSON object with this exact shape (no markdown fences, raw JSON only):
{
  "summary": "2–3 sentence assessment of profile strength and impression",
  "scores": {
    "completeness": 0-10,
    "engagement": 0-10,
    "clarity": 0-10,
    "overall": 0-10
  },
  "suggestions": [
    {
      "category": "Bio|Portfolio|Activity|Visibility|Branding",
      "priority": "high|medium|low",
      "title": "Short actionable title",
      "description": "Detailed explanation",
      "action": "Specific step to take"
    }
  ]
}
Return 4–6 suggestions ordered by priority.`,

  content: `You are a content strategist and analyst.
Analyze the provided content and return a JSON object with this exact shape (no markdown fences, raw JSON only):
{
  "summary": "2–3 sentence summary of the content, its themes, and quality",
  "scores": {
    "quality": 0-10,
    "depth": 0-10,
    "engagement": 0-10,
    "overall": 0-10
  },
  "suggestions": [
    {
      "category": "Content|Structure|Engagement|SEO|Clarity|Tone",
      "priority": "high|medium|low",
      "title": "Short actionable title",
      "description": "Detailed explanation",
      "action": "Specific step to take"
    }
  ]
}
Return 4–6 suggestions ordered by priority.`,

  general: `You are a versatile content and digital analyst.
Analyze the provided content and return a JSON object with this exact shape (no markdown fences, raw JSON only):
{
  "summary": "2–3 sentence summary and overall assessment",
  "scores": {
    "quality": 0-10,
    "overall": 0-10
  },
  "suggestions": [
    {
      "category": string,
      "priority": "high|medium|low",
      "title": "Short actionable title",
      "description": "Detailed explanation",
      "action": "Specific step to take"
    }
  ]
}
Return 3–5 suggestions ordered by priority.`,
};

interface ParsedResponse {
  summary: string;
  scores?: Record<string, number>;
  suggestions: Suggestion[];
}

function parseResponse(raw: string): ParsedResponse {
  const cleaned = raw.replace(/```(?:json)?\n?/g, '').replace(/```/g, '').trim();
  try {
    return JSON.parse(cleaned) as ParsedResponse;
  } catch {
    // Attempt to salvage a JSON block from inside the text
    const jsonMatch = cleaned.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      try { return JSON.parse(jsonMatch[0]) as ParsedResponse; } catch { /* fall through */ }
    }
    return { summary: cleaned.substring(0, 500), suggestions: [] };
  }
}

export async function analyzeContent(
  content: FetchedContent,
  analysisType: AnalysisType
): Promise<AnalysisResult> {
  const systemPrompt = SYSTEM_PROMPTS[analysisType];
  const userMessage = `Analyze this ${content.platform} content:\n\nURL: ${content.url}\nTitle: ${content.title}\n\n${content.text.substring(0, 6000)}`;

  const raw = await callLLM({
    systemPrompt,
    messages: [{ role: 'user', content: userMessage }],
    maxTokens: 2000,
  });

  const parsed = parseResponse(raw);

  return {
    platform: content.platform,
    url: content.url,
    title: content.title,
    analysisType,
    summary: parsed.summary || 'Analysis complete.',
    suggestions: (parsed.suggestions || []).slice(0, 10),
    scores: parsed.scores,
    metadata: content.metadata,
    canWrite: content.canWrite,
    timestamp: new Date().toISOString(),
  };
}
