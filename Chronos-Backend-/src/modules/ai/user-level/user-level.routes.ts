import { Router } from "express";
import { requireAuth } from "../../auth/middlewares/auth.middleware";
import { getLevel, setLevel, submitQuiz } from "./user-level.controller";

const router = Router();

router.get("/", requireAuth, getLevel);
router.post("/set", requireAuth, setLevel);
router.post("/quiz", requireAuth, submitQuiz);

export default router;
