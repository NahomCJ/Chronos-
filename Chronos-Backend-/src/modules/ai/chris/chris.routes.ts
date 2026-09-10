import { Router } from "express";
import { chrisChat } from "./chris.controller";

const router = Router();

// Auth intentionally OFF during MVP testing so Chris chat works before sign-up.
// Restore requireAuth before public launch — this endpoint spends LLM quota
// and pulls per-user financial context, so it shouldn't be anonymous long-term.
router.post("/chat", chrisChat);

export default router;
