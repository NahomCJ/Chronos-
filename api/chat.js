const Anthropic = require('@anthropic-ai/sdk').default;

// Lazy init: constructing eagerly at module load means a single cold start
// with a missing/not-yet-propagated key permanently breaks this module for
// every request on that warm container until the next deploy, even after
// the key is added. Build the client on first use instead.
let client = null;
function getClient() {
  if (!client) {
    const apiKey = process.env.CHRIS_CLAUDE_API || process.env.ANTHROPIC_API_KEY;
    client = new Anthropic({ apiKey });
  }
  return client;
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

// Belt-and-suspenders for the system prompt's formatting rules: the model
// doesn't always follow them exactly, and the app renders replies as plain
// text with no markdown support, so strip anything that would leak through
// as literal asterisks or an em/en dash.
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
    const response = await getClient().messages.create({
      model: 'claude-sonnet-5',
      max_tokens: 512,
      system: CHRIS_SYSTEM,
      messages: [...priorTurns, { role: 'user', content: message.trim() }],
    });

    // claude-sonnet-5 sometimes reasons with an extended-thinking block before
    // the actual reply, so content[0] isn't reliably the text block -- find
    // it by type instead of assuming position. This was the real cause of
    // "I could not generate a response": thinking-block runs (more common on
    // complex/financial questions) silently hit the fallback below.
    const textBlock = response.content.find((block) => block.type === 'text');
    const rawReply = textBlock?.text ?? 'I could not generate a response. Please try again.';
    const reply = sanitizeReply(rawReply);

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
