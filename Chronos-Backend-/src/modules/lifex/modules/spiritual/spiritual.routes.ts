import { Router } from "express";
import { SpiritualController } from "./spiritual.controller";
import { requireAuth } from "../../../auth/middlewares/auth.middleware";

const router = Router();
const ctrl = new SpiritualController();

router.get("/dashboard", requireAuth, ctrl.dashboard);
router.get("/streak", requireAuth, ctrl.streak);

router.get("/meditation", requireAuth, ctrl.listMeditations);
router.post("/meditation", requireAuth, ctrl.logMeditation);
router.get("/meditation/stats", requireAuth, ctrl.meditationStats);

router.get("/gratitude", requireAuth, ctrl.listGratitude);
router.post("/gratitude", requireAuth, ctrl.addGratitude);

router.get("/goals", requireAuth, ctrl.listGoals);
router.post("/goals", requireAuth, ctrl.createGoal);
router.patch("/goals/:goalId/progress", requireAuth, ctrl.updateGoalProgress);

export default router;
