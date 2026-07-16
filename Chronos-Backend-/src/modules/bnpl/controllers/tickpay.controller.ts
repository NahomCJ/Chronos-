// src/controllers/tickpay.controller.ts
import { Request, Response } from "express";
import TickPayService from "../services/tickpay.service";



class TickPayController {
  async createAccount(req: Request, res: Response) {
    try {
      // ✅ get userId from JWT payload
      const userId = (req as any).user?.id;
      if (!userId) return res.status(400).json({ error: "Missing userId" });

      // create account (service will fetch onboarding and set credit limit)
      const acct = await TickPayService.createAccount(userId);
      res.status(201).json(acct);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }

  async createPurchase(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      if (!userId) return res.status(400).json({ error: "Missing userId" });

      const result = await TickPayService.createPurchase(userId, req.body);
      res.status(201).json(result);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }

  async createRepayment(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      if (!userId) return res.status(400).json({ error: "Missing userId" });

      const result = await TickPayService.createRepayment(userId, req.body);
      res.json(result);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }

  async refundPurchase(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      if (!userId) return res.status(400).json({ error: "Missing userId" });

      const { purchaseTxId, amount } = req.body;
      const result = await TickPayService.refundPurchase(userId, purchaseTxId, amount);
      res.json(result);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }

  async getAccount(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      if (!userId) return res.status(400).json({ error: "Missing userId" });

      const acct = await TickPayService.getAccount(userId);
      res.json(acct);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }
async listTransactions(req: Request, res: Response) {
  const userId = (req as any).user?.id;
  if (!userId) return res.status(400).json({ error: "Missing userId" });

  const txs = await TickPayService.listTransactions(userId);
  res.json(txs);  // <-- returns array only
}


  async listFees(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      if (!userId) return res.status(400).json({ error: "Missing userId" });

      const fees = await TickPayService.listFees(userId);
      res.json({ fees }); // wrap in key
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }}

  async issueCard(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      if (!userId) return res.status(400).json({ error: "Missing userId" });

      const card = await TickPayService.issueTickPayCard(userId);
      res.status(201).json(card);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }
}

export default new TickPayController();
