import { json, Request, Response, Router } from 'express';
import { requireAuth } from "../../../auth/middlewares/auth.middleware";
import elevenLabsVoiceService from './elevenLabsVoice.service';
import { isElevenLabsConfigured } from '../../../ai/voice/elevenlabs.client';

const router = Router();
const jsonParser = json({ limit: process.env.CHRONOS_VOICE_JSON_LIMIT || '25mb' });

// Requires auth — previously public, leaking infra configuration state
// (whether ElevenLabs/agent keys are set) to unauthenticated callers.
router.get('/config', requireAuth, (_req: Request, res: Response) => {
  res.json({
    elevenLabsConfigured: isElevenLabsConfigured(),
    agentConfigured: Boolean(process.env.ELEVENLABS_AGENT_ID),
    signedWidgetEnabled: Boolean(process.env.ELEVENLABS_AGENT_ID),
    outputFormat: process.env.ELEVENLABS_OUTPUT_FORMAT || 'mp3_44100_128',
    sttModel: process.env.ELEVENLABS_STT_MODEL || 'scribe_v2',
    ttsModel: process.env.ELEVENLABS_TTS_MODEL || 'eleven_multilingual_v2',
  });
});

router.get('/signed-url', requireAuth, async (req: Request, res: Response) => {
  try {
    const result = await elevenLabsVoiceService.createSignedConversationUrl({
      branchId: typeof req.query.branchId === 'string' ? req.query.branchId : undefined,
      environment: typeof req.query.environment === 'string' ? req.query.environment : undefined,
      includeConversationId: req.query.includeConversationId === 'true',
    });

    res.json(result);
  } catch (error) {
    sendError(res, error);
  }
});

router.post('/text', jsonParser, requireAuth, async (req: any, res: Response) => {
  try {
    const result = await elevenLabsVoiceService.chatFromText({
      ...(req.body || {}),
      userId: req.user?.id,
    });
    res.json(result);
  } catch (error) {
    sendError(res, error);
  }
});

router.post('/audio', jsonParser, requireAuth, async (req: any, res: Response) => {
  try {
    const result = await elevenLabsVoiceService.chatFromAudio({
      ...(req.body || {}),
      userId: req.user?.id,
    });
    res.json(result);
  } catch (error) {
    sendError(res, error);
  }
});

function sendError(res: Response, error: unknown): void {
  const message = error instanceof Error ? error.message : 'Unknown voice chat error.';
  const status = /required|empty|did not return/i.test(message) ? 400 : 502;

  res.status(status).json({
    error: message,
  });
}

export default router;
