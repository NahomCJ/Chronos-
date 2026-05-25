import { Router } from "express";
import multer from "multer";
import { requireAuth } from "../../auth/middlewares/auth.middleware";
import { transcribe, synthesize } from "./voice.controller";

const router = Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
});

router.post("/transcribe", requireAuth, upload.single("audio"), transcribe);
router.post("/synthesize", requireAuth, synthesize);

export default router;
