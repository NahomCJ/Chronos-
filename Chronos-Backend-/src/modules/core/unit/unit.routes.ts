import { Router, Request, Response, NextFunction } from "express";
import { requireAuth } from "../../auth/middlewares/auth.middleware";
import {
  createCustomer,
  createAccount,
  listAccounts,
  getAccount,
  issueCard,
  listCards,
  freezeCard,
  unfreezeCard,
  createTransfer,
  listTransfers,
  listUnitTransactions,
} from "./unit.controller";
import {
  verifyUnitWebhookSignature,
  handleUnitWebhookEvent,
} from "../providers/unit/unit.module";

const router = Router();

// ── Customers ──────────────────────────────────────────────────────────────────
router.post("/customers", requireAuth, createCustomer);

// ── Accounts ───────────────────────────────────────────────────────────────────
router.post("/accounts", requireAuth, createAccount);
router.get("/accounts", requireAuth, listAccounts);
router.get("/accounts/:unitAccountId", requireAuth, getAccount);
router.get("/accounts/:unitAccountId/transactions", requireAuth, listUnitTransactions);

// ── Cards ──────────────────────────────────────────────────────────────────────
router.post("/cards", requireAuth, issueCard);
router.get("/cards", requireAuth, listCards);
router.post("/cards/:unitCardId/freeze", requireAuth, freezeCard);
router.post("/cards/:unitCardId/unfreeze", requireAuth, unfreezeCard);

// ── Transfers ──────────────────────────────────────────────────────────────────
router.post("/transfers", requireAuth, createTransfer);
router.get("/transfers", requireAuth, listTransfers);

// ── Webhook (no auth — verified by HMAC signature) ─────────────────────────────
router.post(
  "/webhook",
  (req: Request, res: Response, next: NextFunction) => {
    const signature = req.headers["x-unit-signature"] as string;
    const rawBody = (req as any).rawBody as Buffer | undefined;

    if (signature && rawBody) {
      const valid = verifyUnitWebhookSignature(rawBody, signature);
      if (!valid) {
        return res.status(401).json({ message: "Invalid webhook signature" });
      }
    }
    next();
  },
  async (req: Request, res: Response) => {
    try {
      await handleUnitWebhookEvent(req.body);
      return res.json({ received: true });
    } catch (err: any) {
      console.error("[Unit Webhook]", err.message);
      return res.status(500).json({ message: "Webhook processing failed" });
    }
  }
);

export default router;
