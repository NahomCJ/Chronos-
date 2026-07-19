import prisma from "../../../config/prisma";
import { createNotification } from "../notifications/notifications.service";

export async function cashOut(
  userId: string,
  walletId: string,
  amount: number,
  note?: string
) {
  if (amount <= 0) throw new Error("Amount must be greater than zero");

  const wallet = await prisma.wallet.findFirst({
    where: { id: walletId, account: { userId }, status: "ACTIVE" },
    include: { ledger: { select: { direction: true, amount: true } } },
  });
  if (!wallet) throw new Error("Wallet not found");

  // Compute current balance from ledger
  const balance = wallet.ledger.reduce((sum, e) => {
    const amt = parseFloat(e.amount.toString());
    return e.direction === "CREDIT" ? sum + amt : sum - amt;
  }, 0);

  if (balance < amount) throw new Error("Insufficient balance");

  const reference = `CO-${Date.now()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;

  const result = await prisma.$transaction(async (tx) => {
    const txn = await tx.coreTransaction.create({
      data: {
        userId,
        type: "WITHDRAWAL",
        status: "COMPLETED",
        reference,
        metadata: { note: note ?? "Cash out", walletId },
      },
    });

    const ledger = await tx.ledgerEntry.create({
      data: {
        transactionId: txn.id,
        walletId,
        direction: "DEBIT",
        category: "TRANSFER",
        amount,
        currency: wallet.currency,
        reference,
      },
    });

    return { txn, ledger };
  });

  // Fire-and-forget notification
  createNotification(
    userId,
    "CASHOUT",
    "Cash Out Successful",
    `${amount.toFixed(2)} ${wallet.currency} has been withdrawn from your wallet.`,
    { reference, amount, currency: wallet.currency }
  ).catch(() => {});

  return {
    reference,
    amount,
    currency: wallet.currency,
    balanceAfter: parseFloat((balance - amount).toFixed(2)),
    status: "COMPLETED",
  };
}
