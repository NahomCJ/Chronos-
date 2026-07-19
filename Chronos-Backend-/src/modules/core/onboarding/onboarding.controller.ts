// src/modules/core/onboarding/onboarding.controller.ts

import { Request, Response } from "express";
import { onboardingService } from "./onboarding.service";

export const onboardingController = {

  /**
   * POST /onboarding/start
   *
   * Body: { email, password, firstName, lastName, dateOfBirth?, phoneNumber? }
   *
   * Returns:
   *   - JWT access + refresh tokens
   *   - Plaid link_token for Identity Verification (KYC)
   *   - Onboarding step so frontend knows what screen to show next
   *
   * Sandbox: set PLAID_CLIENT_ID, PLAID_SECRET, PLAID_IDV_TEMPLATE_ID in .env.
   *          If keys are missing the user is registered but plaidLinkToken will be null.
   */
  async start(req: Request, res: Response) {
    try {
      const { email, password, firstName, lastName, dateOfBirth, phoneNumber } = req.body;

      if (!email || !password || !firstName || !lastName) {
        return res.status(400).json({
          error: "email, password, firstName, and lastName are required.",
        });
      }
      if (password.length < 8) {
        return res.status(400).json({ error: "Password must be at least 8 characters." });
      }

      const result = await onboardingService.start({
        email,
        password,
        firstName,
        lastName,
        dateOfBirth,
        phoneNumber,
      });

      return res.status(201).json(result);
    } catch (err: any) {
      const status = err.message.includes("already exists") ? 409 : 400;
      return res.status(status).json({ error: err.message });
    }
  },

  /**
   * POST /onboarding/link-bank
   * Requires: Bearer token (user must be logged in + KYC approved)
   *
   * Returns a Plaid Link token for the Auth product.
   * Frontend passes this to Plaid Link → user selects their bank + account.
   * After success, frontend calls POST /kyc/bank/connect with { publicToken, accountId }.
   *
   * Sandbox credentials for Plaid Link:
   *   username: user_good
   *   password: pass_good
   *   institution: Chase (ins_109508)
   */
  async linkBank(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const result = await onboardingService.linkBank(userId);
      return res.status(200).json(result);
    } catch (err: any) {
      const status =
        err.message.includes("not found") ? 404 :
        err.message.includes("approved") ? 403 :
        err.message.includes("already linked") ? 409 : 400;
      return res.status(status).json({ error: err.message });
    }
  },

  /**
   * GET /onboarding/status
   * Requires: Bearer token
   *
   * Returns the current onboarding step so the frontend knows what screen to render:
   *   PROFILE_MISSING   → call POST /onboarding/start
   *   KYC_PENDING       → open Plaid Link for IDV
   *   BANK_LINK_PENDING → call POST /onboarding/link-bank then POST /kyc/bank/connect
   *   COMPLETE          → user can deposit and trade
   */
  async status(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const result = await onboardingService.getStatus(userId);
      return res.status(200).json(result);
    } catch (err: any) {
      return res.status(400).json({ error: err.message });
    }
  },
};
