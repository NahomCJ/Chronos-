import { Router } from "express";
import { fxController } from "./fx.controller";
import { requireAuth } from '../../auth/middlewares/auth.middleware';

const router = Router();

router.post("/quote", requireAuth, fxController.quote.bind(fxController));
router.post("/execute", requireAuth, fxController.execute.bind(fxController));

export default router;
