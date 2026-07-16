import prisma from "../../../config/prisma"
import { TransactionQuery } from "./transactions.types"

export class TransactionsService {

  async getUserTransactions(userId: string, query: TransactionQuery) {
    const page = Math.max(1, Number(query.page ?? 1))
    const limit = Math.min(100, Math.max(1, Number(query.limit ?? 20)))

    const where: any = { userId }

    if (query.type)   where.type   = query.type
    if (query.status) where.status = query.status
    if (query.search) where.reference = { contains: query.search, mode: "insensitive" }

    if (query.fromDate || query.toDate) {
      where.createdAt = {}
      if (query.fromDate) where.createdAt.gte = new Date(query.fromDate)
      if (query.toDate)   where.createdAt.lte = new Date(query.toDate)
    }

    // Amount and direction filters live on LedgerEntry — filter via nested some
    const ledgerFilter: any = {}
    if (query.direction) ledgerFilter.direction = query.direction
    if (query.currency)  ledgerFilter.currency  = query.currency
    if (query.minAmount !== undefined || query.maxAmount !== undefined) {
      ledgerFilter.amount = {}
      if (query.minAmount !== undefined) ledgerFilter.amount.gte = query.minAmount
      if (query.maxAmount !== undefined) ledgerFilter.amount.lte = query.maxAmount
    }
    if (Object.keys(ledgerFilter).length > 0) {
      where.ledgerEntries = { some: ledgerFilter }
    }

    const [total, transactions] = await Promise.all([
      prisma.coreTransaction.count({ where }),
      prisma.coreTransaction.findMany({
        where,
        include: { transfer: true, ledgerEntries: true },
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * limit,
        take: limit,
      }),
    ])

    return {
      data: transactions,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasNext: page * limit < total,
      },
    }
  }

  async getTransactionById(userId: string, transactionId: string) {
    const tx = await prisma.coreTransaction.findFirst({
      where: { id: transactionId, userId },
      include: { transfer: true, ledgerEntries: true },
    })
    if (!tx) throw new Error("Transaction not found")
    return tx
  }

  async getWalletActivity(walletId: string) {
    return prisma.ledgerEntry.findMany({
      where: { walletId },
      include: { transaction: true },
      orderBy: { createdAt: "desc" },
    })
  }
}

export const transactionsService = new TransactionsService()
