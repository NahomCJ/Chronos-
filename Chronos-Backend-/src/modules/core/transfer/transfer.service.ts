// src/core/transfer/transfer.service.ts
import Decimal from "decimal.js";
import prisma from "../../../config/prisma";
import { CreateTransferDTO } from "./transfer.types";
import { NotificationService } from "../../notification/notificatoin.service";
import * as T from "../../notification/email.templates";

const DEFAULT_FEE_RATE = Number(process.env.TRANSFER_DEFAULT_FEE_RATE ?? 0.005);
const MIN_AMOUNT = Number(process.env.TRANSFER_MIN_AMOUNT ?? 1);

export class TransferService {
  // Find by reference for idempotency
  async findByReference(reference?: string) {
    if (!reference) return null;
    return prisma.transfer.findFirst({ where: { reference } });
  }

  // Create a transfer (internal, external, or P2P)
  async createTransfer(userId: string, dto: CreateTransferDTO) {
    const { fromWalletId, toWalletId, toExternal, amount, currency, note, reference } = dto;

    if (!toWalletId && !toExternal) throw new Error("Must provide either toWalletId or toExternal");

    if (new Decimal(amount).lt(MIN_AMOUNT)) throw new Error("Amount below minimum threshold");

    // Idempotency check
    if (reference) {
      const existing = await this.findByReference(reference);
      if (existing) return existing;
    }

    const fee = new Decimal(amount).mul(DEFAULT_FEE_RATE).toFixed(8);
    const totalDebit = new Decimal(amount).add(fee);

    // Prisma transaction for atomicity
    return prisma.$transaction(async (tx) => {
      const fromWallet = await tx.wallet.findUnique({ where: { id: fromWalletId } });
      if (!fromWallet) throw new Error("From wallet not found");
      if (fromWallet.status !== "ACTIVE") throw new Error("From wallet not active");

      // Compute available balance from ledger
      const credits = await tx.ledgerEntry.aggregate({ _sum: { amount: true }, where: { walletId: fromWalletId, direction: "CREDIT" } });
      const debits = await tx.ledgerEntry.aggregate({ _sum: { amount: true }, where: { walletId: fromWalletId, direction: "DEBIT" } });
      const available = Number(credits._sum.amount ?? 0) - Number(debits._sum.amount ?? 0);
      if (new Decimal(available).lt(totalDebit)) throw new Error("Insufficient funds");

      // Create CoreTransaction
      const coreTx = await tx.coreTransaction.create({
        data: {
          userId,
          type: "TRANSFER",
          status: "INITIATED",
          reference,
        }
      });

      // Create Transfer record
      const transfer = await tx.transfer.create({
        data: {
          userId,
          transactionId: coreTx.id,
          fromWalletId,
          toWalletId: toWalletId ?? "",
          toExternal: toExternal ?? undefined,
          amount,
          currency,
          fee,
          status: "PENDING",
          note,
          reference
        }
      });

      // Ledger debit (fromWallet)
      await tx.ledgerEntry.create({
        data: {
          transactionId: coreTx.id,
          walletId: fromWalletId,
          direction: "DEBIT",
          category: "TRANSFER",
          amount,
          currency,
          reference
        }
      });

      // Ledger credit (toWallet)
      if (toWalletId) {
        await tx.ledgerEntry.create({
          data: {
            transactionId: coreTx.id,
            walletId: toWalletId,
            direction: "CREDIT",
            category: "TRANSFER",
            amount,
            currency,
            reference
          }
        });
      }

      // Update status and audit
      await tx.transfer.update({ where: { id: transfer.id }, data: { status: toWalletId ? "COMPLETED" : "PENDING" } });

      if (toWalletId) {
        NotificationService.notifyUser(userId, {
          subject: `Transfer Completed — ${currency} ${amount}`,
          title: "Transfer Completed",
          message: T.transferCompleted(String(amount), currency, note),
        }).catch(() => {});
      }

      // Async external processing
      if (!toWalletId) {
        this.sendToExternalProvider(transfer.id).catch(async () => {
          await prisma.transfer.update({ where: { id: transfer.id }, data: { status: "FAILED" } });
          NotificationService.notifyUser(userId, {
            subject: `Transfer Failed — ${currency} ${amount}`,
            title: "Transfer Failed",
            message: T.transferFailed(String(amount), currency),
          }).catch(() => {});
        });
      }

      return { coreTx, transfer };
    });
  }

  // Get transfer by ID
  async getTransferById(userId: string, id: string) {
    return prisma.transfer.findFirst({
      where: { id, userId },
      include: { transaction: true, fromWallet: true, toWallet: true }
    });
  }

  // List transfers for a user
  async listTransfers(userId: string, page = 1, limit = 20) {
    return prisma.transfer.findMany({
      where: { userId },
      include: { transaction: true, fromWallet: true, toWallet: true },
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * limit,
      take: limit
    });
  }

  // Simulate sending to external provider
  async sendToExternalProvider(transferId: string) {
    await prisma.transfer.update({ where: { id: transferId }, data: { status: "COMPLETED" } });
  }
  async cancelTransfer(userId: string, transferId: string) {
  const transfer = await prisma.transfer.findUnique({ where: { id: transferId } })
  if (!transfer) throw new Error("Transfer not found")
  if (transfer.userId !== userId) throw new Error("Unauthorized")
  if (!["PENDING"].includes(transfer.status))
    throw new Error("Only pending transfers can be cancelled")

  // Mark transfer as cancelled
  await prisma.transfer.update({ where: { id: transferId }, data: { status: "CANCELLED" } })

  NotificationService.notifyUser(userId, {
    subject: "Transfer Cancelled",
    title: "Transfer Cancelled",
    message: T.transferCancelled(String(transfer.amount), transfer.currency),
  }).catch(() => {});

  return { success: true }
}
}

export const transferService = new TransferService();
