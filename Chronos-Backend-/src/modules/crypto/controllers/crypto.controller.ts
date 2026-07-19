import { Request, Response } from "express";
import { ZodError } from "zod";
import cryptoService from "../services/crypto.service";
import { BuyRequestSchema, HistoryQuerySchema, SellRequestSchema } from "../services/crypto.validation";
import { isCryptoApiError } from "../services/crypto.errors";

function getUserId(req: Request): string | undefined {
  return (req as any).user?.id || (req as any).user?.userId || (req as any).user?.sub;
}

function handleError(res: Response, err: unknown) {
  if (err instanceof ZodError) {
    return res.status(400).json({
      code: "VALIDATION_ERROR",
      message: "Invalid crypto request.",
      issues: err.issues,
    });
  }

  if (isCryptoApiError(err)) {
    return res.status(err.status).json({
      code: err.code,
      message: err.message,
      details: err.details,
    });
  }

  const message = err instanceof Error ? err.message : "Internal server error";
  return res.status(500).json({ code: "CRYPTO_ERROR", message });
}

export class CryptoController {
  async dashboard(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const dashboard = await cryptoService.getDashboard(userId);
      return res.json(dashboard);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async account(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const account = await cryptoService.provisionAccount(userId);
      return res.status(account.created ? 201 : 200).json(account);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async buy(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const input = BuyRequestSchema.parse(req.body);
      const result = await cryptoService.buy(userId, input);
      return res.json(result);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async sell(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const input = SellRequestSchema.parse(req.body);
      const result = await cryptoService.sell(userId, input);
      return res.json(result);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async history(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const query = HistoryQuerySchema.parse(req.query);
      const history = await cryptoService.getHistory(userId, query);
      return res.json(history);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async price(req: Request, res: Response) {
    try {
      const asset = String(req.params.asset || "");
      const price = await cryptoService.getPrice(asset);
      return res.json(price);
    } catch (err) {
      return handleError(res, err);
    }
  }
}

export const cryptoController = new CryptoController();
export default cryptoController;
