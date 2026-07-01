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

router.get("/donations", requireAuth, ctrl.listDonations);
router.post("/donations", requireAuth, ctrl.donate);

router.get("/campaigns/contributions", requireAuth, ctrl.listContributions);
router.post("/campaigns/contribute", requireAuth, ctrl.contribute);

router.get("/trips/bookings", requireAuth, ctrl.listTripBookings);
router.post("/trips/book", requireAuth, ctrl.bookTrip);

router.get("/shop/orders", requireAuth, ctrl.listOrders);
router.post("/shop/checkout", requireAuth, ctrl.checkout);

router.get("/faith", requireAuth, ctrl.getFaith);
router.patch("/faith", requireAuth, ctrl.setFaith);

export default router;
