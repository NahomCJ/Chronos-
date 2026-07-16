import { Request, Response } from "express"
import { transactionsService } from "./transaction.service"

export class TransactionsController {

  async list(req: Request, res: Response) {

    const userId = req.user!.id

    const transactions = await transactionsService.getUserTransactions(
      userId,
      req.query
    )

    res.json(transactions)
  }

  async get(req: Request, res: Response) {

    const userId = req.user!.id
    const { id } = req.params

    const tx = await transactionsService.getTransactionById(userId, id)

    res.json(tx)
  }

  async walletActivity(req: Request, res: Response) {

    const { walletId } = req.params

    const tx = await transactionsService.getWalletActivity(walletId)

    res.json(tx)
  }
}

export const transactionsController = new TransactionsController()