const Anthropic = require('@anthropic-ai/sdk').default;

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

const CHRIS_SYSTEM = `You are Chris, the AI financial advisor inside Chronos — a premium fintech super-app. \
You help users understand their finances, spending, savings, investments, taxes, and credit. \
You have access to the user's context through their questions. \
Keep responses concise (2–4 sentences unless detail is asked for). \
Be warm, direct, and confident. Never say you can't access real account data — just give general \
advice based on what the user tells you. Never recommend specific stocks by ticker. \
Format numbers clearly (e.g. "$1,200/mo", "4.5% APR"). Avoid filler phrases.`;

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

  // Prior turns from this voice/chat session, for multi-turn memory.
  // Capped and sanitized — only well-formed {role, content} pairs survive.
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

  try {
    const response = await client.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 512,
      system: CHRIS_SYSTEM,
      messages: [...priorTurns, { role: 'user', content: message.trim() }],
    });

    const reply = response.content[0]?.text ?? 'I could not generate a response. Please try again.';

    return res.status(200).json({
      reply,
      domain: inferDomain(message),
      userLevel: 'BEGINNER',
      user_id: user_id ?? 'unknown',
    });
  } catch (err) {
    console.error('[Chris chat]', err?.message ?? err);
    return res.status(500).json({
      error: 'Chat failed',
      reply: 'Something went wrong on my end. Please try again in a moment.',
    });
  }
};
