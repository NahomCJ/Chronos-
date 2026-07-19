// src/core/deposit/deposit.controller.ts
import { Request, Response } from "express"
import { depositService } from "./deposit.services"

export const depositController = {
  async create(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const result = await depositService.createDeposit(userId, req.body)
      res.status(201).json(result)
    } catch (err: any) {
      res.status(400).json({ error: err.message })
    }
  },

  async get(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const deposit = await depositService.getDepositById(userId, req.params.id)
      if (!deposit) return res.status(404).json({ error: "Deposit not found" })
      res.json(deposit)
    } catch (err: any) {
      res.status(400).json({ error: err.message })
    }
  },

  async list(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const page = Number(req.query.page ?? 1)
      const limit = Number(req.query.limit ?? 20)
      const deposits = await depositService.listDeposits(userId, page, limit)
      res.json(deposits)
    } catch (err: any) {
      res.status(400).json({ error: err.message })
    }
  }
}