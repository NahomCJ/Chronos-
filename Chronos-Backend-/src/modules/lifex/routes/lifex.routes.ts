import { Router } from "express";
import educationRoutes from "../../lifex/modules/education/routes";
import financial from "../../lifex/modules/financial/financial.routes";
import healthRoutes from "../modules/health/health.routes";
import visionRoutes from "../modules/vision/vision.routes";
import activityRoutes from "../modules/activity/activity.routes";
import lifeAiRoutes from "../modules/ai/lifeAI.routes";
import exportRoutes from "../modules/export/export.routes";
import familyRoutes from "../modules/family/family.routes";
import socialRoutes from "../modules/social/social.routes";
import spiritualRoutes from "../modules/spiritual/spiritual.routes";
import feedRoutes from "../modules/feed/feed.routes";

const router = Router();

router.use("/education", educationRoutes);
router.use("/health", healthRoutes);
router.use("/finance", financial);
router.use("/vision", visionRoutes);
router.use("/activity", activityRoutes);
router.use("/ai", lifeAiRoutes);
router.use("/export", exportRoutes);
router.use("/family", familyRoutes);
router.use("/social", socialRoutes);
router.use("/spiritual", spiritualRoutes);
router.use("/feed", feedRoutes);

export default router;
