import { Router } from "express";
import chrisRoutes from "./chris/chris.routes";
import voiceRoutes from "./voice/voice.routes";
import alertsRoutes from "./alerts/alerts.routes";
import userLevelRoutes from "./user-level/user-level.routes";
import { requireAuth } from "../auth/middlewares/auth.middleware";
import { runAffordabilityCheck } from "./panther/agents/tickpay/affordability.agent";
import { runMarketplaceSearch } from "./panther/agents/tickpay/marketplace-search.agent";
import { getUserFinancialContext } from "./panther/core/data-retrieval.service";
import { Request, Response } from "express";

const router = Router();

router.use("/chris", chrisRoutes);
router.use("/voice", voiceRoutes);
router.use("/alerts", alertsRoutes);
router.use("/user-level", userLevelRoutes);

router.post(
  "/tickpay/affordability",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    const userId = (req as any).user?.id as string;
    const { amount, merchant = "Unknown" } = req.body as {
      amount?: number;
      merchant?: string;
    };

    if (!amount || typeof amount !== "number" || amount <= 0) {
      res.status(400).json({ error: "amount must be a positive number" });
      return;
    }

    try {
      const ctx = await getUserFinancialContext(userId);
      const result = await runAffordabilityCheck(ctx, amount, merchant, "text");
      res.status(200).json(result);
    } catch (err) {
      const msg =
        err instanceof Error ? err.message : "Affordability check failed";
      res.status(500).json({ error: msg });
    }
  }
);

router.post(
  "/tickpay/search",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    const userId = (req as any).user?.id as string;
    const { query, maxBudget } = req.body as {
      query?: string;
      maxBudget?: number;
    };

    if (!query || typeof query !== "string") {
      res.status(400).json({ error: "query is required" });
      return;
    }

    try {
      const ctx = await getUserFinancialContext(userId);
      const result = await runMarketplaceSearch(
        ctx,
        query,
        maxBudget ?? null,
        "text"
      );
      res.status(200).json(result);
    } catch (err) {
      const msg =
        err instanceof Error ? err.message : "Marketplace search failed";
      res.status(500).json({ error: msg });
    }
  }
);

router.get(
  "/blockhub/portfolio",
  requireAuth,
  async (_req: Request, res: Response): Promise<void> => {
    res.status(503).json({
      message:
        "BlockHub AI is not yet available. The crypto module is being deployed — portfolio analysis will be live soon.",
    });
  }
);

export default router;
