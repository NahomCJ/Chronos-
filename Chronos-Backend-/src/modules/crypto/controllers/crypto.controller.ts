import { Request, Response } from "express";
import cryptoService from "../services/crypto.service";
import { QuoteRequestSchema, ExecuteRequestSchema } from "../services/crypto.validation";

export class CryptoController {
  async quote(req: Request, res: Response) {
    const parsed = QuoteRequestSchema.parse({ ...req.body, userId: req.user.id });
    const q = await cryptoService.quote(parsed);
    res.json(q);
  }

  async execute(req: Request, res: Response) {
    const idempotencyKey = req.header("Idempotency-Key");
    if (!idempotencyKey) return res.status(400).json({ error: "Missing Idempotency-Key header" });

    const parsed = ExecuteRequestSchema.parse({
      ...req.body,
      userId: req.user.id,
      idempotencyKey,
    });

    const tx = await cryptoService.execute(parsed);
    res.json(tx);
  }
}

export default new CryptoController();
