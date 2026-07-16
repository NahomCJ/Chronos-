import { Router } from "express";
import { requireAuth } from "../../auth/middlewares/auth.middleware";
import { chrisChat } from "./chris.controller";

const router = Router();

router.post("/chat", requireAuth, chrisChat);

export default router;
