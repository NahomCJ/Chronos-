// src/integrations/integrations.controller.ts
import { Request, Response } from "express";
import IntegrationsService from "./integrations.service";

class IntegrationsController {
  async callIntegration(req: Request, res: Response) {
    try {
      const { service, method, params } = req.body;

      if (!service || !method) {
        return res.status(400).json({ error: "Missing service or method" });
      }

      const result = await IntegrationsService.dispatch(service, method, params);
      return res.json({ success: true, data: result });
    } catch (error: any) {
      console.error("Integration call error:", error);
      return res.status(500).json({ success: false, error: error.message });
    }
  }
}

export default new IntegrationsController();
