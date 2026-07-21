const assert = require('node:assert/strict');
const { afterEach, beforeEach, describe, test } = require('node:test');

const handlers = [
  ['root Vercel function', require('../api/synthesize')],
  ['chronos-root Vercel function', require('../chronos/api/synthesize')],
];

const ENV_KEYS = [
  'ELEVEN_LABS',
  'ELEVENLABS_API_KEY',
  'ELEVEN_API_KEY',
  'ELEVENLABS_VOICE_ID',
  'ELEVEN_VOICE_ID',
  'ELEVENLABS_TTS_MODEL',
  'ELEVEN_TTS_MODEL',
  'ELEVENLABS_OUTPUT_FORMAT',
];

function responseRecorder() {
  return {
    statusCode: 200,
    headers: {},
    body: undefined,
    setHeader(name, value) {
      this.headers[name.toLowerCase()] = value;
    },
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(value) {
      this.body = value;
      return this;
    },
    send(value) {
      this.body = value;
      return this;
    },
    end() {
      return this;
    },
  };
}

describe('Chris Vercel voice synthesis contract', () => {
  const originalFetch = global.fetch;
  const originalEnv = Object.fromEntries(ENV_KEYS.map((key) => [key, process.env[key]]));

  beforeEach(() => {
    for (const key of ENV_KEYS) delete process.env[key];
  });

  afterEach(() => {
    global.fetch = originalFetch;
    for (const key of ENV_KEYS) {
      if (originalEnv[key] === undefined) delete process.env[key];
      else process.env[key] = originalEnv[key];
    }
  });

  for (const [label, handler] of handlers) {
    test(`${label} reports missing server credentials`, async () => {
      const res = responseRecorder();
      await handler({ method: 'POST', body: { text: 'Hello' } }, res);
      assert.equal(res.statusCode, 503);
      assert.match(res.body.error, /not configured/i);
    });

    test(`${label} uses the supported Chris voice defaults`, async () => {
      process.env.ELEVENLABS_API_KEY = 'test-key';
      let request;
      global.fetch = async (url, options) => {
        request = { url, options };
        return new Response(Uint8Array.from([0x49, 0x44, 0x33]), {
          status: 200,
          headers: { 'content-type': 'audio/mpeg' },
        });
      };

      const res = responseRecorder();
      await handler({ method: 'POST', body: { text: 'Hello, I am Chris.' } }, res);

      assert.equal(res.statusCode, 200);
      assert.equal(res.headers['content-type'], 'audio/mpeg');
      assert.ok(Buffer.isBuffer(res.body));
      assert.match(request.url, /21m00Tcm4TlvDq8ikWAM/);
      assert.match(request.url, /output_format=mp3_44100_128/);
      const payload = JSON.parse(request.options.body);
      assert.equal(payload.model_id, 'eleven_multilingual_v2');
      assert.equal(payload.text, 'Hello, I am Chris.');
    });

    test(`${label} honors model, voice, and output overrides`, async () => {
      process.env.ELEVEN_LABS = 'test-key';
      process.env.ELEVENLABS_VOICE_ID = 'custom voice/id';
      process.env.ELEVENLABS_TTS_MODEL = 'eleven_flash_v2_5';
      process.env.ELEVENLABS_OUTPUT_FORMAT = 'mp3_44100_192';
      let request;
      global.fetch = async (url, options) => {
        request = { url, options };
        return new Response(Uint8Array.from([1]), { status: 200 });
      };

      const res = responseRecorder();
      await handler({ method: 'POST', body: { text: 'Test' } }, res);

      assert.match(request.url, /custom%20voice%2Fid/);
      assert.match(request.url, /output_format=mp3_44100_192/);
      assert.equal(JSON.parse(request.options.body).model_id, 'eleven_flash_v2_5');
    });
  }
});
