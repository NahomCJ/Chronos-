import { checkHealth, synthesizeSpeech } from './elevenlabs.client';

const ENV_KEYS = [
  'ELEVENLABS_API_KEY',
  'XI_API_KEY',
  'ELEVENLABS_VOICE_ID',
  'ELEVENLABS_TTS_MODEL',
  'ELEVENLABS_OUTPUT_FORMAT',
];

describe('shared ElevenLabs client', () => {
  const originalFetch = global.fetch;
  const originalEnv = Object.fromEntries(ENV_KEYS.map((key) => [key, process.env[key]]));

  beforeEach(() => {
    for (const key of ENV_KEYS) delete process.env[key];
    global.fetch = jest.fn() as unknown as typeof fetch;
  });

  afterAll(() => {
    global.fetch = originalFetch;
    for (const key of ENV_KEYS) {
      if (originalEnv[key] === undefined) delete process.env[key];
      else process.env[key] = originalEnv[key];
    }
  });

  it('fails clearly when credentials are missing', async () => {
    await expect(synthesizeSpeech('hello')).rejects.toThrow(/not configured/i);
  });

  it('uses Chris voice defaults and caps unbounded replies', async () => {
    process.env.ELEVENLABS_API_KEY = 'test-key';
    const fetchMock = global.fetch as jest.MockedFunction<typeof fetch>;
    fetchMock.mockResolvedValue(
      new Response(Uint8Array.from([0x49, 0x44, 0x33]), {
        status: 200,
        headers: { 'content-type': 'audio/mpeg' },
      })
    );

    const result = await synthesizeSpeech('x'.repeat(900));

    expect(result.buffer).toEqual(Buffer.from([0x49, 0x44, 0x33]));
    expect(result.mimeType).toBe('audio/mpeg');
    const [url, init] = fetchMock.mock.calls[0];
    expect(String(url)).toContain('21m00Tcm4TlvDq8ikWAM');
    expect(String(url)).toContain('output_format=mp3_44100_128');
    const payload = JSON.parse(String(init?.body));
    expect(payload.model_id).toBe('eleven_multilingual_v2');
    expect(payload.text).toHaveLength(600);
  });

  it('checks credentials and quota without synthesizing audio', async () => {
    process.env.XI_API_KEY = 'alias-key';
    const fetchMock = global.fetch as jest.MockedFunction<typeof fetch>;
    fetchMock.mockResolvedValue(
      new Response(JSON.stringify({ character_count: 25, character_limit: 100 }), {
        status: 200,
        headers: { 'content-type': 'application/json' },
      })
    );

    await expect(checkHealth()).resolves.toEqual({
      configured: true,
      ok: true,
      detail: undefined,
      charactersUsed: 25,
      charactersLimit: 100,
    });
    expect(String(fetchMock.mock.calls[0][0])).toMatch(/\/user\/subscription$/);
  });
});
