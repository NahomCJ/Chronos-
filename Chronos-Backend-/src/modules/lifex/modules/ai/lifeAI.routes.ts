import { Router } from "express";
import { LifeAiController } from "./lifeAi.controller";
import { requireAuth } from "../../../auth/middlewares/auth.middleware";

const router = Router();
const ctrl = new LifeAiController();

router.get("/insights", requireAuth, ctrl.insights);
router.post("/chat", requireAuth, ctrl.chat);
router.get("/weekly-plan", requireAuth, ctrl.weeklyPlan);

export default router;
