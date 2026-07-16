// src/modules/core/wallet/wallet.route.ts
import { Router } from "express";
import { walletController } from "./wallet.controller";
import { requireAuth } from '../../auth/middlewares/auth.middleware';
import { cashOut } from "./cashout.service";

const router = Router();

// Create wallet for specific account
router.post("/create", requireAuth, walletController.create);

// List wallets for specific account
router.get("/list/:accountId", requireAuth, walletController.listByAccount);

// Get single wallet
router.get("/get/:walletId", requireAuth, walletController.getById);

router.patch("/freeze/:walletId", requireAuth, walletController.freeze);
router.patch("/close/:walletId", requireAuth, walletController.close);

router.post("/cashout", requireAuth, async (req, res) => {
  const userId = (req as any).user?.id as string;
  const { walletId, amount, note } = req.body;
  if (!walletId || !amount) {
    return res.status(400).json({ error: "walletId and amount are required" });
  }
  try {
    const result = await cashOut(userId, walletId, Number(amount), note);
    res.status(200).json(result);
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Cash out failed";
    res.status(400).json({ error: msg });
  }
});

export default router;