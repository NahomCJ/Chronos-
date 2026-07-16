// src/modules/core/onboarding/onboarding.routes.ts

import { Router } from "express";
import { onboardingController } from "./onboarding.controller";
import { bankDepositController } from "./bank-deposit.controller";
import { requireAuth } from "../../auth/middlewares/auth.middleware";

const router = Router();

/**
 * ─── New User Onboarding Flow ─────────────────────────────────────────────────
 *
 * Step 1 — Register + start KYC (no auth needed — this creates the account)
 *   POST /onboarding/start
 *   Body: { email, password, firstName, lastName, dateOfBirth?, phoneNumber? }
 *   Returns: { user, accessToken, refreshToken, onboarding: { plaidLinkToken, step } }
 *
 * Step 2 — (Frontend) Open Plaid Link with plaidLinkToken → user completes IDV
 *   Then call: POST /kyc/session/complete { identityVerificationId }
 *   Plaid webhook also auto-updates KYC status.
 *
 * Step 3 — Link bank account (requires KYC approved)
 *   POST /onboarding/link-bank
 *   Returns: { plaidLinkToken, expiration }
 *
 * Step 4 — (Frontend) Open Plaid Link with plaidLinkToken → user selects bank
 *   Then call: POST /kyc/bank/connect { publicToken, accountId }
 *
 * Step 5 — Deposit funds from bank into Chronos (ACH pull via Plaid Transfer)
 *   POST /onboarding/deposit { amount: 500.00 }
 *   Returns: { depositId, plaidTransferId, status: "PENDING", estimatedSettlement }
 *   Funds credited to wallet when Plaid fires TRANSFER webhook (settled event).
 *
 * Step 6 — Check current onboarding progress
 *   GET /onboarding/status
 *   Returns: { step, kycVerified, bankLinked, message }
 *
 * ─── Sandbox Simulation ───────────────────────────────────────────────────────
 * After POST /onboarding/deposit, simulate ACH settlement instantly:
 *   POST https://sandbox.plaid.com/sandbox/transfer/simulate
 *   Headers: PLAID-CLIENT-ID: <your_id>, PLAID-SECRET: <your_secret>
 *   Body: { "transfer_id": "<plaidTransferId>", "event_type": "settled" }
 * This fires our /kyc/webhook endpoint and credits the user's USD wallet.
 */

// No auth — this is the registration + KYC kickoff endpoint
router.post("/start", onboardingController.start);

// Auth required — user must be logged in to link their bank
router.post("/link-bank", requireAuth, onboardingController.linkBank);

// Auth required — check where user is in the onboarding funnel
router.get("/status", requireAuth, onboardingController.status);

// Auth required — bank funding (ACH deposit)
router.post("/deposit", requireAuth, bankDepositController.initiate);
router.get("/deposits", requireAuth, bankDepositController.list);

export default router;
