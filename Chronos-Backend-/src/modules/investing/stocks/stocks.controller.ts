import { Request, Response } from "express";
import * as stocksService from "./stocks.service";
import { isStocksApiError } from "./stocks.errors";

function getUserId(req: Request): string | undefined {
  return (req as any).user?.id || (req as any).user?.userId || (req as any).user?.sub;
}

function handleError(res: Response, err: unknown) {
  if (isStocksApiError(err)) {
    return res.status(err.status).json({ code: err.code, message: err.message, details: err.details });
  }
  const message = err instanceof Error ? err.message : "Internal server error";
  return res.status(500).json({ code: "STOCKS_ERROR", message });
}

export class StocksController {
  async listSupported(_req: Request, res: Response) {
    try {
      const stocks = await stocksService.listSupportedStocks();
      return res.json({ stocks });
    } catch (err) {
      return handleError(res, err);
    }
  }

  async quote(req: Request, res: Response) {
    try {
      const symbol = String(req.params.symbol ?? "");
      const quote = await stocksService.getQuoteForSymbol(symbol);
      return res.json(quote);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async portfolio(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const portfolio = await stocksService.getPortfolio(userId);
      return res.json(portfolio);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async buy(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const { symbol, shares } = req.body ?? {};
      const order = await stocksService.buyStock(userId, String(symbol ?? ""), Number(shares));
      return res.status(201).json(order);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async sell(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const { symbol, shares } = req.body ?? {};
      const order = await stocksService.sellStock(userId, String(symbol ?? ""), Number(shares));
      return res.status(201).json(order);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async orders(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const limit = req.query.limit ? Number(req.query.limit) : 25;
      const orders = await stocksService.getOrders(userId, limit);
      return res.json({ orders });
    } catch (err) {
      return handleError(res, err);
    }
  }
}

export default new StocksController();
