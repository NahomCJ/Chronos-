import { Router } from "express";
import { ActivityController } from "./activity.controller";
import { requireAuth } from "../../../auth/middlewares/auth.middleware";

const router = Router();
const ctrl = new ActivityController();

router.get("/", requireAuth, ctrl.list);
router.post("/", requireAuth, ctrl.log);
router.get("/stats", requireAuth, ctrl.stats);
router.get("/streak", requireAuth, ctrl.streak);

export default router;
