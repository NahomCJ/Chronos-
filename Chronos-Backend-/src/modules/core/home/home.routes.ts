import { Router } from "express";
import { requireAuth } from "../../auth/middlewares/auth.middleware";
import { homeSummary, spendingAnalysis, offers } from "./home.controller";

const router = Router();

router.get("/summary", requireAuth, homeSummary);
router.get("/spending-analysis", requireAuth, spendingAnalysis);
router.get("/offers", requireAuth, offers);

export default router;
