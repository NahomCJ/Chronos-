// src/core/transfer/controllers/transfer.controller.ts
import { Request, Response } from "express";
import transferService from "../services/transfer.service";

export class TransferController {
    async create(req: Request, res: Response) {
        try {
            //            const userId = (req as any).user?.id; // assume auth middleware sets req.user
            //            if (!userId) return res.status(401).json({ error: "Unauthorized" });

            const dto = req.body;
            const result = await transferService.createTransfer("96cbc6c4-a66b-468c-ab46-c87bee1f2bb6", dto);
            res.status(201).json(result);
        } catch (err: any) {
            res.status(400).json({ error: err.message || "Failed to create transfer" });
        }
    }

    async get(req: Request, res: Response) {
        try {
            const id = req.params.id;
            const transfer = await transferService.getTransferById(id);
            if (!transfer) return res.status(404).json({ error: "Not found" });
            res.json(transfer);
        } catch (err: any) {
            res.status(400).json({ error: err.message });
        }
    }

    async list(req: Request, res: Response) {
        try {
            const userId = (req as any).user?.id;
            if (!userId) return res.status(401).json({ error: "Unauthorized" });
            const { take = 50, skip = 0 } = req.query as any;
            const list = await transferService.listUserTransfers(userId, Number(take), Number(skip));
            res.json(list);
        } catch (err: any) {
            res.status(400).json({ error: err.message });
        }
    }

    async cancel(req: Request, res: Response) {
        try {
            const userId = (req as any).user?.id;
            const transferId = req.params.id;
            const out = await transferService.cancelTransfer(userId, transferId);
            res.json(out);
        } catch (err: any) {
            res.status(400).json({ error: err.message });
        }
    }

    // Admin retry endpoint (if needed)
    async retryExecution(req: Request, res: Response) {
        try {
            const id = req.params.id;
            const transfer = await transferService.executeInternalTransfer(id);
            res.json(transfer);
        } catch (err: any) {
            res.status(400).json({ error: err.message });
        }
    }
}

export default new TransferController();
