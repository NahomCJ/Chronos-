import { Router } from "express";
import multer from "multer";
import { transcribe, synthesize, health } from "./voice.controller";

const router = Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
});

// Auth intentionally OFF during MVP testing so Chris voice works before sign-up.
// Restore requireAuth on all three routes before public launch — voice calls
// spend ElevenLabs/Whisper quota and shouldn't be reachable without a user.
router.post("/transcribe", upload.single("audio"), transcribe);
router.post("/synthesize", synthesize);
router.get("/health", health);

export default router;
