// src/core/transfer/transfer.controller.ts
import { Request, Response } from "express";
import { transferService } from "./transfer.service";

export class TransferController {
  // Create transfer
  async create(req: Request, res: Response) {
    try {
      const userId = req.user.id;
      const result = await transferService.createTransfer(userId, req.body);
      res.status(201).json(result);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }

  // List transfers
  async list(req: Request, res: Response) {
    try {
      const userId = req.user.id;
      const page = Number(req.query.page ?? 1);
      const limit = Number(req.query.limit ?? 20);
      const transfers = await transferService.listTransfers(userId, page, limit);
      res.json(transfers);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }

  // Get single transfer
  async get(req: Request, res: Response) {
    try {
      const userId = req.user.id;
      const transfer = await transferService.getTransferById(userId, req.params.id);
      if (!transfer) return res.status(404).json({ error: "Transfer not found" });
      res.json(transfer);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }

  // Cancel transfer
  async cancel(req: Request, res: Response) {
    try {
      const userId = req.user.id;
      const transferId = req.params.id;
      const result = await transferService.cancelTransfer(userId, transferId);
      res.json(result);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }
}

export const transferController = new TransferController();