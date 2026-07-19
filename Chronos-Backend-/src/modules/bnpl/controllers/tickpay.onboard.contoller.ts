// src/modules/bnpl/controllers/tickpay.onboard.controller.ts
import { Request, Response } from "express";
import OnboardService from "../services/tickpay.onboard.service";
import { validateOnboardPayload } from "../middlewares/validate.middleware";

class TickPayOnboardController {
  async createOnboarding(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id || req.body.userId || req.params.userId;
      if (!userId) return res.status(400).json({ error: "Missing userId (user must be authenticated or pass userId)" });

      const v = validateOnboardPayload(req.body);
      if (!v.ok) return res.status(400).json({ error: v.error });

      const result = await OnboardService.createOnboarding(userId, v.data);
      return res.json({ success: true, ...result });
    } catch (err: any) {
      console.error("Onboarding error:", err);
      return res.status(500).json({ error: err.message || "Failed to onboard" });
    }
  }

  async getOnboarding(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id || req.params.userId;
      if (!userId) return res.status(400).json({ error: "Missing userId" });

      const onboard = await OnboardService.getOnboarding(userId);
      return res.json({ success: true, onboarding: onboard });
    } catch (err: any) {
      return res.status(404).json({ error: err.message || "Not found" });
    }
  }
}

export default new TickPayOnboardController();
