// src/modules/core/onboarding/bank-deposit.controller.ts

import { Request, Response } from "express";
import { bankDepositService } from "./bank-deposit.service";

export const bankDepositController = {

  /**
   * POST /onboarding/deposit
   * Auth: Bearer token required
   *
   * Body: { amount: number, description?: string }
   *
   * Initiates an ACH pull from the user's linked bank account.
   * Funds arrive in 1-3 business days (instantly in Plaid sandbox).
   *
   * Prerequisites:
   *   1. KYC approved  (POST /kyc/session/create → POST /kyc/session/complete)
   *   2. Bank linked   (POST /onboarding/link-bank → POST /kyc/bank/connect)
   *
   * Sandbox simulation (after deposit initiated):
   *   POST https://sandbox.plaid.com/sandbox/transfer/simulate
   *   Headers: PLAID-CLIENT-ID, PLAID-SECRET
   *   Body: { "transfer_id": "<plaidTransferId>", "event_type": "settled" }
   *   → This fires our webhook and credits the wallet immediately.
   */
  async initiate(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const { amount, description } = req.body;

      if (!amount || typeof amount !== "number" || isNaN(amount)) {
        return res.status(400).json({ error: "amount must be a valid number (e.g. 500.00)" });
      }

      const result = await bankDepositService.initiate(userId, { amount, description });
      return res.status(202).json(result); // 202 Accepted — async ACH, not yet settled
    } catch (err: any) {
      const status =
        err.message.includes("Minimum") || err.message.includes("Maximum") ? 422 :
        err.message.includes("KYC")     ? 403 :
        err.message.includes("No bank") ? 403 :
        err.message.includes("declined") ? 422 : 400;
      return res.status(status).json({ error: err.message });
    }
  },

  /**
   * GET /onboarding/deposits
   * Auth: Bearer token required
   *
   * Lists all bank deposits for the current user with status.
   * Query params: page, limit
   */
  async list(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;

      const deposits = await bankDepositService.listDeposits(userId, page, limit);
      return res.status(200).json({ data: deposits, page, limit });
    } catch (err: any) {
      return res.status(400).json({ error: err.message });
    }
  },
};
