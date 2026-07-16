// src/modules/core/kyc/kyc.routes.ts
import { Router } from "express";
import { kycController } from "./kyc.controller";
import { requireAuth, requireAdmin } from "../../auth/middlewares/auth.middleware";

const router = Router();

// ── Profile ──────────────────────────────────────────────────────────────────
router.get("/profile", requireAuth, kycController.getProfile.bind(kycController));
router.post("/profile", requireAuth, kycController.createProfile.bind(kycController));

// ── Identity Verification (KYC) ───────────────────────────────────────────────
// Step 1: create Plaid Link token for IDV
router.post("/session/create", requireAuth, kycController.createKycSession.bind(kycController));
// Step 2: after Plaid Link onSuccess, sync IDV status
router.post("/session/complete", requireAuth, kycController.completeKycSession.bind(kycController));
// Retry a failed/expired IDV session
router.post("/session/retry", requireAuth, kycController.retryKycSession.bind(kycController));
// Poll live IDV session status from Plaid
router.get("/session/:sessionId", requireAuth, kycController.getKycSessionStatus.bind(kycController));

// ── Bank Account Linking (Plaid Auth) ────────────────────────────────────────
// Step 1: create Plaid Link token for Auth product (requires KYC approved)
router.post("/bank/link", requireAuth, kycController.createAuthLinkToken.bind(kycController));
// Step 2: exchange public_token → access_token and store it
router.post("/bank/connect", requireAuth, kycController.exchangePublicToken.bind(kycController));
// Get linked bank account details
router.get("/bank/account", requireAuth, kycController.getLinkedAccount.bind(kycController));

// ── Plaid Webhook ─────────────────────────────────────────────────────────────
// No user auth — Plaid signs the request (see PLAID_VERIFY_WEBHOOKS in .env.example)
router.post("/webhook", kycController.handleWebhook.bind(kycController));

// ── Admin (requires ADMIN role) ───────────────────────────────────────────────
router.post("/approve/:userId", requireAuth, requireAdmin, kycController.approveKyc.bind(kycController));
router.post("/reject/:userId", requireAuth, requireAdmin, kycController.rejectKyc.bind(kycController));
router.post("/freeze/:userId", requireAuth, requireAdmin, kycController.freezeAccount.bind(kycController));
router.post("/unfreeze/:userId", requireAuth, requireAdmin, kycController.unfreezeAccount.bind(kycController));

export default router;
