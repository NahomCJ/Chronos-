// src/modules/core/kyc/kyc.controller.ts
import { Request, Response } from "express";
import { kycService } from "./kyc.service";
import {
  ApproveKycInput,
  RejectKycInput,
  CreateKycSessionInput,
  CompleteKycSessionInput,
  CreateAuthLinkTokenInput,
  ExchangePublicTokenInput,
} from "./kyc.types";
import { bankDepositService } from "../onboarding/bank-deposit.service";

const getUserId = (req: Request): string | undefined => (req as any).user?.id;

function handleError(res: Response, err: unknown) {
  const message = err instanceof Error ? err.message : "Internal server error";
  const status = message.includes("not found")
    ? 404
    : message.includes("already") || message.includes("must be")
      ? 400
      : 500;
  return res.status(status).json({ error: message });
}

export class KycController {
  // ─── Profile ────────────────────────────────────────────────────────────────

  async getProfile(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const profile = await kycService.getProfile(userId);
      return res.json(profile ?? { status: "not-found" });
    } catch (err) {
      return handleError(res, err);
    }
  }

  async createProfile(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const profile = await kycService.createProfile(userId);
      return res.status(201).json(profile);
    } catch (err) {
      return handleError(res, err);
    }
  }

  // ─── Plaid IDV (KYC) ────────────────────────────────────────────────────────

  /**
   * POST /kyc/session/create
   * Returns a Plaid Link token. Frontend passes this to Plaid Link to start IDV.
   */
  async createKycSession(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const input: CreateKycSessionInput = req.body;
      if (!input.email || !input.firstName || !input.lastName) {
        return res.status(400).json({ error: "email, firstName, and lastName are required" });
      }

      const session = await kycService.createKycSession(userId, input);
      return res.json(session);
    } catch (err) {
      return handleError(res, err);
    }
  }

  /**
   * POST /kyc/session/complete
   * Called after Plaid Link onSuccess. Syncs IDV status from Plaid into our DB.
   */
  async completeKycSession(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const { identityVerificationId }: CompleteKycSessionInput = req.body;
      if (!identityVerificationId) {
        return res.status(400).json({ error: "identityVerificationId is required" });
      }

      const result = await kycService.completeKycSession(userId, identityVerificationId);
      return res.json(result);
    } catch (err) {
      return handleError(res, err);
    }
  }

  /**
   * GET /kyc/session/:sessionId
   * Returns the live Plaid IDV session status directly from Plaid.
   */
  async getKycSessionStatus(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const data = await kycService.getKycSessionStatus(req.params.sessionId as string);
      return res.json(data);
    } catch (err) {
      return handleError(res, err);
    }
  }

  /**
   * POST /kyc/session/retry
   * Issues a fresh Plaid Link token to retry a failed or expired IDV session.
   */
  async retryKycSession(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const { email } = req.body;
      if (!email) return res.status(400).json({ error: "email is required" });

      const session = await kycService.retryKycSession(userId, email);
      return res.json(session);
    } catch (err) {
      return handleError(res, err);
    }
  }

  // ─── Plaid Auth (Bank Account Linking) ──────────────────────────────────────

  /**
   * POST /kyc/bank/link
   * Creates a Plaid Link token for the Auth product.
   * Frontend opens Plaid Link; user connects their external bank account.
   * Requires KYC to be approved first.
   */
  async createAuthLinkToken(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const input: CreateAuthLinkTokenInput = req.body;
      if (!input.email) return res.status(400).json({ error: "email is required" });

      const session = await kycService.createAuthLinkToken(userId, input);
      return res.json(session);
    } catch (err) {
      return handleError(res, err);
    }
  }

  /**
   * POST /kyc/bank/connect
   * Exchanges the public_token from Plaid Link for a permanent access_token.
   * Stores it on the banking profile so ACH deposits can be initiated later.
   */
  async exchangePublicToken(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const input: ExchangePublicTokenInput = req.body;
      if (!input.publicToken || !input.accountId) {
        return res.status(400).json({ error: "publicToken and accountId are required" });
      }

      await kycService.exchangePublicToken(userId, input);
      return res.json({ success: true, message: "Bank account linked successfully." });
    } catch (err) {
      return handleError(res, err);
    }
  }

  /**
   * GET /kyc/bank/account
   * Returns the linked bank account details (name, mask, routing/account numbers).
   * Guard carefully — account numbers are sensitive.
   */
  async getLinkedAccount(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ error: "Unauthorized" });

      const account = await kycService.getLinkedAccount(userId);
      if (!account) return res.status(404).json({ error: "No bank account linked." });

      return res.json(account);
    } catch (err) {
      return handleError(res, err);
    }
  }

  // ─── Plaid Webhook ──────────────────────────────────────────────────────────

  /**
   * POST /kyc/webhook
   * Receives Plaid webhook events. No user auth — Plaid signs the request.
   *
   * Set PLAID_VERIFY_WEBHOOKS=true in .env to enforce signature verification.
   * In sandbox, leave it false until PLAID_CLIENT_ID/PLAID_SECRET are set.
   */
  async handleWebhook(req: Request, res: Response) {
    try {
      if (process.env.PLAID_VERIFY_WEBHOOKS === "true") {
        const verificationToken = req.headers["plaid-verification"] as string | undefined;
        if (!verificationToken) {
          return res.status(400).json({ error: "Missing Plaid-Verification header" });
        }
        const valid = await kycService.verifyWebhookToken(verificationToken, (req as any).rawBody);
        if (!valid) {
          return res.status(401).json({ error: "Invalid webhook signature" });
        }
      }

      await kycService.handlePlaidWebhook(req.body);

      // Handle ACH Transfer events (pending -> settled)
      if (req.body.webhook_type === "TRANSFER") {
        await bankDepositService.handleTransferWebhook(req.body);
      }

      return res.sendStatus(200);
    } catch (err) {
      return handleError(res, err);
    }
  }

  // ─── Admin overrides ────────────────────────────────────────────────────────

  async approveKyc(req: Request, res: Response) {
    try {
      const { riskLevel }: ApproveKycInput = req.body;
      if (!riskLevel) return res.status(400).json({ error: "riskLevel is required" });

      const result = await kycService.approveKyc(req.params.userId as string, riskLevel);
      return res.json(result);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async rejectKyc(req: Request, res: Response) {
    try {
      const { reason }: RejectKycInput = req.body;
      if (!reason) return res.status(400).json({ error: "reason is required" });

      const result = await kycService.rejectKyc(req.params.userId as string, reason);
      return res.json(result);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async freezeAccount(req: Request, res: Response) {
    try {
      const result = await kycService.freezeAccount(req.params.userId as string);
      return res.json(result);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async unfreezeAccount(req: Request, res: Response) {
    try {
      const result = await kycService.unfreezeAccount(req.params.userId as string);
      return res.json(result);
    } catch (err) {
      return handleError(res, err);
    }
  }
}

export const kycController = new KycController();
