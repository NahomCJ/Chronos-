const Groq = require('groq-sdk');
const Anthropic = require('@anthropic-ai/sdk').default;

// Lazy-init clients — reading keys at request time so a key added to Vercel
// after a cold start is picked up without waiting for a fresh container.
let groqClient = null;
let anthropicClient = null;

function getGroqClient() {
  if (!groqClient) {
    const apiKey = process.env.GROQ_API_KEY;
    if (!apiKey) return null;
    groqClient = new Groq({ apiKey });
  }
  return groqClient;
}

function getAnthropicClient() {
  if (!anthropicClient) {
    const apiKey = process.env.CHRIS_CLAUDE_API || process.env.ANTHROPIC_API_KEY;
    if (!apiKey) return null;
    anthropicClient = new Anthropic({ apiKey });
  }
  return anthropicClient;
}

const CHRIS_SYSTEM = `You are Chris, the AI assistant inside Chronos, a premium fintech super-app. \
You're knowledgeable about finance, but you're a genuinely helpful assistant, not a narrow bot that \
only answers money questions. Answer whatever the user asks: greetings, small talk, general \
questions, anything. Never refuse to answer or say you can't help unless the request is genuinely \
harmful. When the question is financial, lean on your expertise in spending, saving, investing, \
taxes, and credit.

Formatting rules (your reply is shown as plain text, with no markdown rendering):
- Never use markdown syntax: no asterisks for bold or italics, no # headers, no backticks.
- Never use em dashes or en dashes. Use a comma, a period, or "and"/"but" instead.
- Keep paragraphs short, and use a line break between distinct points instead of one dense block.
- For lists, put each item on its own line with a plain "-" or a number, not inline.
- Format numbers clearly (e.g. "$1,200/mo", "4.5% APR").

Be warm, direct, and confident. Keep responses concise (2-4 sentences) unless the user asks for \
more detail. Never say you can't access real account data, just give general advice based on what \
the user tells you. Never recommend specific stocks by ticker. Avoid filler phrases.`;

function sanitizeReply(text) {
  return text
    .replace(/\s*[—–]\s*/g, ', ')
    .replace(/\*\*(.*?)\*\*/g, '$1')
    .replace(/\*(.*?)\*/g, '$1')
    .replace(/[ \t]{2,}/g, ' ')
    .trim();
}

function inferDomain(message) {
  const m = message.toLowerCase();
  if (/tax|irs|deduct|filing|refund/.test(m)) return 'TAX';
  if (/invest|stock|crypto|portfolio|rebalanc|etf|fund/.test(m)) return 'INVESTMENT';
  if (/spend|budget|saving|expense|overspend/.test(m)) return 'BUDGET';
  if (/credit|loan|debt|mortgage|interest|bnpl/.test(m)) return 'CREDIT';
  if (/transfer|send|pay|bill|payment/.test(m)) return 'PAYMENT';
  if (/net worth|asset|liabilit|wealth/.test(m)) return 'NET_WORTH';
  return 'GENERAL';
}

async function chatWithGroq(message, priorTurns) {
  const client = getGroqClient();
  if (!client) throw new Error('GROQ_API_KEY not configured');

  const response = await client.chat.completions.create({
    model: 'llama-3.3-70b-versatile',
    max_tokens: 512,
    messages: [
      { role: 'system', content: CHRIS_SYSTEM },
      ...priorTurns,
      { role: 'user', content: message.trim() },
    ],
  });

  return response.choices[0]?.message?.content ?? '';
}

async function chatWithClaude(message, priorTurns) {
  const client = getAnthropicClient();
  if (!client) throw new Error('ANTHROPIC_API_KEY not configured');

  const response = await client.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 512,
    system: CHRIS_SYSTEM,
    messages: [...priorTurns, { role: 'user', content: message.trim() }],
  });

  const textBlock = response.content.find((block) => block.type === 'text');
  return textBlock?.text ?? '';
}

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { message, user_id, history } = req.body ?? {};
  if (!message?.trim()) {
    return res.status(400).json({ error: 'message is required' });
  }

  const priorTurns = Array.isArray(history)
    ? history
        .filter(
          (h) =>
            h &&
            (h.role === 'user' || h.role === 'assistant') &&
            typeof h.content === 'string' &&
            h.content.trim()
        )
        .slice(-10)
        .map((h) => ({ role: h.role, content: h.content.trim() }))
    : [];

  let rawReply = '';

  // Try Groq first, fall back to Claude if Groq fails or is unconfigured.
  try {
    rawReply = await chatWithGroq(message, priorTurns);
    console.log('[Chris chat] provider: groq');
  } catch (groqErr) {
    console.warn('[Chris chat] Groq failed, trying Claude:', groqErr?.message ?? groqErr);
    try {
      rawReply = await chatWithClaude(message, priorTurns);
      console.log('[Chris chat] provider: claude (fallback)');
    } catch (claudeErr) {
      console.error('[Chris chat] Both providers failed:', claudeErr?.message ?? claudeErr);
      return res.status(500).json({
        error: 'Chat failed',
        reply: 'Something went wrong on my end. Please try again in a moment.',
      });
    }
  }

  if (!rawReply) {
    return res.status(500).json({
      error: 'Empty response',
      reply: 'I could not generate a response. Please try again.',
    });
  }

  return res.status(200).json({
    reply: sanitizeReply(rawReply),
    domain: inferDomain(message),
    userLevel: 'BEGINNER',
    user_id: user_id ?? 'unknown',
  });
};
