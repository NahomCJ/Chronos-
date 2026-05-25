// src/core/deposit/deposit.service.ts
import Decimal from "decimal.js"
import prisma from "../../../config/prisma"
import { Prisma } from "@prisma/client"
import { CreateDepositDTO } from "./deposit.types"

const MIN_DEPOSIT = Number(process.env.DEPOSIT_MIN_AMOUNT ?? 1)

export class DepositService {
  // Idempotency check by reference
  async findByReference(reference?: string) {
    if (!reference) return null
    return prisma.coreTransaction.findFirst({ where: { reference } })
  }

  // Create a deposit
  async createDeposit(userId: string, dto: CreateDepositDTO) {
    const { walletId, amount, currency, reference, note, source } = dto

    if (new Decimal(amount).lt(MIN_DEPOSIT)) throw new Error("Amount below minimum threshold")

    // Idempotency
    if (reference) {
      const existing = await this.findByReference(reference)
      if (existing) {
        const wallet = await prisma.wallet.findUnique({ where: { id: walletId } })
        return { coreTx: existing, wallet }
      }
    }

    return prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      // Load wallet
      const wallet = await tx.wallet.findUnique({ where: { id: walletId } })
      if (!wallet) throw new Error("Wallet not found")
      if (wallet.status !== "ACTIVE") throw new Error("Wallet not active")
      if (wallet.currency !== currency) throw new Error("Currency mismatch")

      // Create CoreTransaction
      const coreTx = await tx.coreTransaction.create({
        data: {
          userId,
          type: "DEPOSIT",
          status: "COMPLETED",
          reference,
          metadata: { note, source }
        }
      })

      // Ledger entry (CREDIT)
      await tx.ledgerEntry.create({
        data: {
          transactionId: coreTx.id,
          walletId,
          direction: "CREDIT",
          category: "ADJUSTMENT",
          amount,
          currency,
          reference
        }
      })

      return { coreTx, wallet }
    })
  }

  async getDepositById(userId: string, id: string) {
    return prisma.coreTransaction.findFirst({
      where: { id, userId, type: "DEPOSIT" },
      include: { ledgerEntries: { include: { wallet: true } } }
    })
  }

  async listDeposits(userId: string, page = 1, limit = 20) {
    return prisma.coreTransaction.findMany({
      where: { userId, type: "DEPOSIT" },
      include: { ledgerEntries: { include: { wallet: true } } },
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * limit,
      take: limit
    })
  }
}

export const depositService = new DepositService()
