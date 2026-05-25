import { Router } from "express";
import { ExportController } from "./export.controller";
import { requireAuth } from "../../../auth/middlewares/auth.middleware";

const router = Router();
const ctrl = new ExportController();

router.get("/health", requireAuth, ctrl.health);
router.get("/finance", requireAuth, ctrl.finance);
router.get("/education", requireAuth, ctrl.education);
router.get("/vision", requireAuth, ctrl.vision);
router.get("/full", requireAuth, ctrl.full);

export default router;
