// Read at request time, not module load — same reasoning as chat.js/
// synthesize.js: a key added on Vercel after this module's first cold start
// wouldn't be picked up by a top-level const on an already-warm container.
function getPexelsApiKey() {
  return process.env.PEXELS_API_KEY || process.env.PEXELS_KEY;
}

const PEXELS_BASE = 'https://api.pexels.com';

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const PEXELS_API_KEY = getPexelsApiKey();
  if (!PEXELS_API_KEY) {
    return res.status(503).json({ error: 'Pexels API key is not configured on the server.' });
  }

  const { type, query, per_page, orientation } = req.query ?? {};
  if (!query?.trim()) {
    return res.status(400).json({ error: 'query is required' });
  }

  const path = type === 'videos' ? '/videos/search' : '/v1/search';
  const params = new URLSearchParams({ query: query.trim() });
  if (per_page) params.set('per_page', per_page);
  if (orientation) params.set('orientation', orientation);

  try {
    const response = await fetch(`${PEXELS_BASE}${path}?${params.toString()}`, {
      headers: { Authorization: PEXELS_API_KEY },
    });

    if (!response.ok) {
      const detail = await response.text().catch(() => '');
      console.error('[Pexels proxy]', response.status, detail);
      return res.status(502).json({ error: 'Pexels request failed' });
    }

    const data = await response.json();
    return res.status(200).json(data);
  } catch (err) {
    console.error('[Pexels proxy]', err?.message ?? err);
    return res.status(500).json({ error: 'Pexels request failed' });
  }
};
