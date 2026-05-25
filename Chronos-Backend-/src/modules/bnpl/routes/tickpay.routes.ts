// src/routes/tickpay.routes.ts
import { Router } from "express";
import TickPayController from "../controllers/tickpay.controller";
import TickPayAdminController from "../controllers/tickpay.admin.controller";
import TickPayOnboardController from "../controllers/tickpay.onboard.contoller";
import { requireAuth, requireAdmin } from "../middlewares/auth.middleware";

const router = Router();

// user endpoints
router.post("/accounts", requireAuth,TickPayController.createAccount.bind(TickPayController));
router.post("/accounts/:userId/issue-card", requireAuth, TickPayController.issueCard.bind(TickPayController));

router.post("/accounts/purchases", requireAuth, TickPayController.createPurchase.bind(TickPayController));
router.post("/accounts/repayments", requireAuth, TickPayController.createRepayment.bind(TickPayController));
router.post("/accounts/refund", requireAuth, TickPayController.refundPurchase.bind(TickPayController));
router.get("/accounts/transactions", requireAuth, TickPayController.listTransactions.bind(TickPayController));
router.get("/accounts/fees", requireAuth, TickPayController.listFees.bind(TickPayController));
router.get("/accounts", requireAuth, TickPayController.getAccount.bind(TickPayController));

// admin endpoints
router.get("/admin/accounts", requireAuth, requireAdmin, TickPayAdminController.listAccounts.bind(TickPayAdminController));
router.post("/admin/accounts/:userId/suspend", requireAuth, requireAdmin, TickPayAdminController.suspend.bind(TickPayAdminController));
router.post("/admin/accounts/:userId/resume", requireAuth, requireAdmin, TickPayAdminController.resume.bind(TickPayAdminController));
router.post("/admin/accounts/:userId/set-limit", requireAuth, requireAdmin, TickPayAdminController.setCreditLimit.bind(TickPayAdminController));
router.post("/admin/fees/:feeId/waive", requireAuth, requireAdmin, TickPayAdminController.waiveFee.bind(TickPayAdminController));
router.post("/admin/fees/:feeId/cancel", requireAuth, requireAdmin, TickPayAdminController.cancelFee.bind(TickPayAdminController));
router.post("/onboard", requireAuth, TickPayOnboardController.createOnboarding.bind(TickPayOnboardController));
router.get("/onboard/:userId", requireAuth, TickPayOnboardController.getOnboarding.bind(TickPayOnboardController));

export default router;
