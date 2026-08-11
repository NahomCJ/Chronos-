import { RequestHandler, Router } from "express";
import controller from "./auto-invest.controller";
import { requireAuth } from "../../../middlewares/auth.middleware";

const router = Router();
const auth = requireAuth as unknown as RequestHandler;

router.post("/allocation-preview", auth, controller.allocationPreview.bind(controller));
router.post("/plans", auth, controller.createPlan.bind(controller));

// Literal routes before the "/plans/:id" param routes so "active" isn't swallowed as an id.
router.get("/plans/active", auth, controller.getActivePlan.bind(controller));
router.get("/plans/:id", auth, controller.getPlanById.bind(controller));

router.post("/plans/:id/confirm", auth, controller.confirmPlan.bind(controller));
router.post("/plans/:id/rounds", auth, controller.triggerNextRound.bind(controller));
router.patch("/plans/:id/pause", auth, controller.pausePlan.bind(controller));
router.patch("/plans/:id/resume", auth, controller.resumePlan.bind(controller));
router.delete("/plans/:id", auth, controller.cancelPlan.bind(controller));
router.get("/plans/:id/executions", auth, controller.listExecutions.bind(controller));

export default router;
