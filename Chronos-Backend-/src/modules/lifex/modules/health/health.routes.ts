import { Router } from "express";
import { HealthController } from "./health.controller";
import { requireAuth } from "../../../auth/middlewares/auth.middleware";

const router = Router();
const ctrl = new HealthController();

router.get("/dashboard", requireAuth, ctrl.dashboard);

router.get("/metrics", requireAuth, ctrl.listMetrics);
router.post("/metrics", requireAuth, ctrl.createMetric);

router.get("/fitness", requireAuth, ctrl.listFitness);
router.post("/fitness", requireAuth, ctrl.logFitness);

router.get("/diet", requireAuth, ctrl.listDiet);
router.post("/diet", requireAuth, ctrl.logDiet);

router.get("/hsa", requireAuth, ctrl.getHsa);
router.post("/hsa/deposit", requireAuth, ctrl.depositHsa);
router.post("/hsa/withdraw", requireAuth, ctrl.withdrawHsa);

router.get("/medical", requireAuth, ctrl.listMedical);
router.post("/medical", requireAuth, ctrl.addMedical);

// Wellness Programs
router.get("/wellness", requireAuth, ctrl.listWellness);
router.post("/wellness/enroll", requireAuth, ctrl.enrollWellness);

// Habits
router.get("/habits", requireAuth, ctrl.listHabits);
router.post("/habit", requireAuth, ctrl.logHabit);

router.get("/gyms", requireAuth, ctrl.gyms);

router.post("/insurance/enroll", requireAuth, ctrl.enrollInsurance);
router.get("/insurance/mine", requireAuth, ctrl.myInsurance);

router.post("/nutrition-partners/connect", requireAuth, ctrl.connectNutritionPartner);
router.get("/nutrition-partners/mine", requireAuth, ctrl.myNutritionConnections);

router.get("/wearables/providers", requireAuth, ctrl.wearableProviders);
router.post("/wearables/connect", requireAuth, ctrl.connectWearable);
router.get("/wearables/mine", requireAuth, ctrl.myWearableConnections);
router.post("/wearables/sync", requireAuth, ctrl.syncWearableMetrics);

router.get("/insights", requireAuth, ctrl.insights);

router.get("/notifications", requireAuth, ctrl.notifications);

export default router;
