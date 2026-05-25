import { Router } from "express";
import { requireAuth } from "../../auth/middlewares/auth.middleware";
import { listAlerts, dismiss, generateAlerts } from "./alerts.controller";

const router = Router();

router.get("/", requireAuth, listAlerts);
router.post("/generate", requireAuth, generateAlerts);
router.patch("/:id/dismiss", requireAuth, dismiss);

export default router;
