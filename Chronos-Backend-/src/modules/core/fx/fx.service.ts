// src/modules/core/fx/fx.service.ts
import { PrismaClient } from "@prisma/client";
import { FxQuoteInput, FxExecuteInput } from "./fx.types";
import { Decimal } from "@prisma/client/runtime/library";
import { NotificationService } from "../../notification/notificatoin.service";
import * as T from "../../notification/email.templates";
import { cached } from "../../core/cache";

const prisma = new PrismaClient();

// Fetch rate with 60-second cache
async function getRate(_fromCurrency: string, _toCurrency: string): Promise<number> {
  return cached(`fx:rate:${_fromCurrency}:${_toCurrency}`, 60, async () => 1.1);
}

class FxService {
  async quote(input: FxQuoteInput, userId: string) {
    if (!userId) throw new Error("Unauthorized");

    // From wallet must belong to user
    const fromWallet = await prisma.wallet.findFirst({
      where: { id: input.fromWalletId, account: { userId } },
    });
    if (!fromWallet) throw new Error("From wallet not found or not yours");

    // To wallet can belong to any user
    const toWallet = await prisma.wallet.findUnique({
      where: { id: input.toWalletId },
    });
    if (!toWallet) throw new Error("To wallet not found");

    const rate = await getRate(input.sellCurrency, input.buyCurrency);
    let buyAmount: number;
    let sellAmount: number;

    if (input.amountType === "BUY") {
      buyAmount = input.amount;
      sellAmount = input.amount * rate;
    } else {
      sellAmount = input.amount;
      buyAmount = input.amount / rate;
    }

    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    // Create FX order
    const order = await prisma.fxOrder.create({
      data: {
        userId,
        fromWalletId: fromWallet.id,
        toWalletId: toWallet.id,
        side: input.amountType,
        buyCurrency: input.buyCurrency,
        sellCurrency: input.sellCurrency,
        buyAmount,
        sellAmount,
        rate,
        provider: "MOCK_PROVIDER",
        providerRef: "MOCK_REF_" + Date.now(),
        status: "QUOTED",
        expiresAt,
        meta: input.meta || {},
      },
    });

    return order;
  }

  async execute(input: FxExecuteInput, userId: string) {
    if (!userId) throw new Error("Unauthorized");

    return prisma.$transaction(async (tx) => {
      const order = await tx.fxOrder.findUnique({
        where: { id: input.orderId },
      });

      if (!order) throw new Error("Order not found");
      if (order.userId !== userId) throw new Error("Forbidden");
      if (order.status !== "QUOTED") throw new Error("Order already processed");
      if (order.expiresAt && order.expiresAt < new Date())
        throw new Error("Quote expired");

      const fromWallet = await tx.wallet.findUnique({ where: { id: order.fromWalletId } });
      const toWallet = await tx.wallet.findUnique({ where: { id: order.toWalletId } });

      if (!fromWallet || !toWallet) throw new Error("Wallet not found");

      // Compute from wallet balance
      const ledgerSum = await tx.ledgerEntry.aggregate({
        _sum: { amount: true },
        where: { walletId: fromWallet.id },
      });
      const currentBalance = ledgerSum._sum.amount || new Decimal(0);

      if (currentBalance.lessThan(new Decimal(order.sellAmount!))) {
        throw new Error("Insufficient funds");
      }

      // Create CoreTransaction and ledger entries
      const coreTx = await tx.coreTransaction.create({
        data: {
          userId,
          type: "TRANSFER",
          status: "COMPLETED",
          reference: `FX-${order.id}`,
        },
      });

      await tx.ledgerEntry.createMany({
        data: [
          {
            transactionId: coreTx.id,
            walletId: fromWallet.id,
            direction: "DEBIT",
            category: "FX",
            amount: order.sellAmount!,
            currency: order.sellCurrency,
            reference: order.id,
          },
          {
            transactionId: coreTx.id,
            walletId: toWallet.id,
            direction: "CREDIT",
            category: "FX",
            amount: order.buyAmount!,
            currency: order.buyCurrency,
            reference: order.id,
          },
        ],
      });

      // Update FX order
      const executed = await tx.fxOrder.update({
        where: { id: order.id },
        data: { status: "EXECUTED" },
      });

      NotificationService.notifyUser(userId, {
        subject: `FX Order Executed — ${order.buyCurrency} ${Number(order.buyAmount).toFixed(2)}`,
        title: "FX Executed",
        message: T.fxExecuted(
          Number(order.sellAmount).toFixed(2), order.sellCurrency,
          Number(order.buyAmount).toFixed(2), order.buyCurrency,
          Number(order.rate).toFixed(4)
        ),
      }).catch(() => {});

      return executed;
    });
  }
}

export const fxService = new FxService();