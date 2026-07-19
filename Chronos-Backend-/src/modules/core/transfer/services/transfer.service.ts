import Decimal from "decimal.js";
import prisma from "../../../../config/prisma";
import { CreateTransferDto } from "../dto/create-transfer.dto";
import { calculateFee, validatePositiveAmount } from "../utils/transfer.helper";

const DEFAULT_FEE_RATE = Number(process.env.TRANSFER_DEFAULT_FEE_RATE ?? 0.005);
const MIN_AMOUNT = Number(process.env.TRANSFER_MIN_AMOUNT ?? 1);

export class TransferService {
  async findByReference(reference?: string) {
    if (!reference) return null;
    return prisma.transfer.findFirst({ where: { reference } });
  }

  async getTransferById(id: string) {
    return prisma.transfer.findUnique({
      where: { id },
      include: { transaction: true, fromWallet: true, toWallet: true }
    });
  }

  async listUserTransfers(userId: string, take = 50, skip = 0) {
    return prisma.transfer.findMany({
      where: { userId },
      include: { transaction: true, fromWallet: true, toWallet: true },
      orderBy: { createdAt: "desc" },
      take,
      skip
    });
  }

  async createTransfer(userId: string, dto: CreateTransferDto) {
    if (!validatePositiveAmount(dto.amount)) throw new Error("Invalid amount");
    if (new Decimal(dto.amount).lt(new Decimal(MIN_AMOUNT))) {
      throw new Error("Amount below minimum threshold");
    }

    if (dto.reference) {
      const existing = await this.findByReference(dto.reference);
      if (existing) return existing;
    }

    const fromWallet = await prisma.wallet.findFirst({
      where: { accountId: dto.fromAccountId, currency: dto.currency, status: "ACTIVE" }
    });
    if (!fromWallet) throw new Error("Source wallet not found");

    const toWallet = dto.toAccountId
      ? await prisma.wallet.findFirst({
          where: { accountId: dto.toAccountId, currency: dto.currency, status: "ACTIVE" }
        })
      : null;

    if (!toWallet && !dto.toExternal) {
      throw new Error("Provide destination account or external destination");
    }

    const fee = calculateFee(dto.amount, DEFAULT_FEE_RATE);
    const amount = new Decimal(dto.amount).toFixed(8);

    return prisma.$transaction(async (tx) => {
      const coreTx = await tx.coreTransaction.create({
        data: {
          userId,
          type: "TRANSFER",
          status: "INITIATED",
          reference: dto.reference
        }
      });

      const transfer = await tx.transfer.create({
        data: {
          userId,
          transactionId: coreTx.id,
          fromWalletId: fromWallet.id,
          // toWalletId is required in current schema, so for external transfers we keep it on source wallet.
          toWalletId: toWallet?.id ?? fromWallet.id,
          toExternal: dto.toExternal ?? undefined,
          amount,
          currency: dto.currency,
          fee,
          status: toWallet ? "COMPLETED" : "PENDING",
          note: dto.note,
          reference: dto.reference,
          metadata: dto.metadata ?? undefined
        }
      });

      await tx.ledgerEntry.create({
        data: {
          transactionId: coreTx.id,
          walletId: fromWallet.id,
          direction: "DEBIT",
          category: "TRANSFER",
          amount,
          currency: dto.currency,
          reference: dto.reference
        }
      });

      if (toWallet) {
        await tx.ledgerEntry.create({
          data: {
            transactionId: coreTx.id,
            walletId: toWallet.id,
            direction: "CREDIT",
            category: "TRANSFER",
            amount,
            currency: dto.currency,
            reference: dto.reference
          }
        });
      }

      return transfer;
    });
  }

  async executeInternalTransfer(transferId: string) {
    return prisma.$transaction(async (tx) => {
      const transfer = await tx.transfer.findUnique({ where: { id: transferId } });
      if (!transfer) throw new Error("Transfer not found");
      if (transfer.status === "COMPLETED") return transfer;

      const creditExists = await tx.ledgerEntry.findFirst({
        where: {
          transactionId: transfer.transactionId,
          walletId: transfer.toWalletId,
          direction: "CREDIT"
        }
      });

      if (!creditExists) {
        await tx.ledgerEntry.create({
          data: {
            transactionId: transfer.transactionId,
            walletId: transfer.toWalletId,
            direction: "CREDIT",
            category: "TRANSFER",
            amount: transfer.amount,
            currency: transfer.currency,
            reference: transfer.reference ?? undefined
          }
        });
      }

      return tx.transfer.update({
        where: { id: transferId },
        data: { status: "COMPLETED" }
      });
    });
  }

  async sendToExternalProvider(transferId: string) {
    await prisma.transfer.update({
      where: { id: transferId },
      data: { status: "COMPLETED" }
    });
    return true;
  }

  async cancelTransfer(userId: string, transferId: string) {
    const transfer = await prisma.transfer.findUnique({ where: { id: transferId } });
    if (!transfer) throw new Error("Transfer not found");
    if (transfer.userId !== userId) throw new Error("Unauthorized");
    if (!["PENDING", "INITIATED"].includes(transfer.status)) {
      throw new Error("Transfer cannot be canceled at this stage");
    }

    await prisma.transfer.update({
      where: { id: transferId },
      data: { status: "CANCELLED" }
    });

    return { success: true };
  }
}

export default new TransferService();
