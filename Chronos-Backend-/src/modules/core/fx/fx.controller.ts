import { Request, Response } from "express";
import { fxService } from "./fx.service";
import { FxQuoteInput, FxExecuteInput } from "./fx.types";

class FxController {
  async quote(req: Request, res: Response) {
    try {
      const userId = req.user?.id; // extracted from JWT
      if (!userId) throw new Error("Unauthorized");

      const input: FxQuoteInput = req.body;
      const order = await fxService.quote(input, userId);

      return res.json(order);
    } catch (err: any) {
      return res.status(400).json({ message: err.message });
    }
  }

  async execute(req: Request, res: Response) {
    try {
      const userId = req.user?.id; // extracted from JWT
      if (!userId) throw new Error("Unauthorized");

      const input: FxExecuteInput = req.body;
      const result = await fxService.execute(input, userId);

      return res.json(result);
    } catch (err: any) {
      return res.status(400).json({ message: err.message });
    }
  }
}

export const fxController = new FxController();