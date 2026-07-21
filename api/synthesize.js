// Read at request time, not module load — a key added on Vercel after this
// module's first cold start wouldn't be picked up by a top-level const on an
// already-warm container.
function getElevenApiKey() {
  return process.env.ELEVEN_LABS || process.env.ELEVENLABS_API_KEY || process.env.ELEVEN_API_KEY;
}
function getElevenVoiceId() {
  return process.env.ELEVENLABS_VOICE_ID || process.env.ELEVEN_VOICE_ID || '21m00Tcm4TlvDq8ikWAM';
}
function getElevenTtsModel() {
  return process.env.ELEVENLABS_TTS_MODEL || process.env.ELEVEN_TTS_MODEL || 'eleven_multilingual_v2';
}
function getElevenOutputFormat() {
  return process.env.ELEVENLABS_OUTPUT_FORMAT || 'mp3_44100_128';
}

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { text } = req.body ?? {};
  if (!text?.trim()) {
    return res.status(400).json({ error: 'text is required' });
  }
  const ELEVEN_API_KEY = getElevenApiKey();
  const ELEVEN_VOICE_ID = getElevenVoiceId();
  const ELEVEN_TTS_MODEL = getElevenTtsModel();
  const ELEVEN_OUTPUT_FORMAT = getElevenOutputFormat();
  if (!ELEVEN_API_KEY) {
    return res.status(503).json({ error: 'ElevenLabs API key is not configured on the server.' });
  }

  const trimmed = text.trim().slice(0, 500);

  try {
    const response = await fetch(
      `https://api.elevenlabs.io/v1/text-to-speech/${encodeURIComponent(ELEVEN_VOICE_ID)}?output_format=${encodeURIComponent(ELEVEN_OUTPUT_FORMAT)}`,
      {
        method: 'POST',
        headers: {
          'xi-api-key': ELEVEN_API_KEY,
          'Content-Type': 'application/json',
          Accept: 'audio/mpeg',
        },
        body: JSON.stringify({
          text: trimmed,
          model_id: ELEVEN_TTS_MODEL,
          voice_settings: { stability: 0.5, similarity_boost: 0.75 },
        }),
      }
    );

    if (!response.ok) {
      const detail = await response.text().catch(() => '');
      console.error('[TTS synthesize]', response.status, detail);
      return res.status(502).json({ error: 'Speech synthesis failed' });
    }

    const arrayBuffer = await response.arrayBuffer();
    res.setHeader('Content-Type', response.headers.get('content-type') || 'audio/mpeg');
    res.setHeader('Content-Length', arrayBuffer.byteLength.toString());
    return res.status(200).send(Buffer.from(arrayBuffer));
  } catch (err) {
    console.error('[TTS synthesize]', err?.message ?? err);
    return res.status(500).json({ error: 'Speech synthesis failed' });
  }
};
