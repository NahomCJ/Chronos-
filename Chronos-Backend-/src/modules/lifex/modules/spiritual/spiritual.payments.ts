import Decimal from "decimal.js";
import prisma from "../../../../config/prisma";

const MIN_AMOUNT = Number(process.env.TRANSFER_MIN_AMOUNT ?? 1);

// Debits the user's wallet for a spiritual-section spend (donation, campaign
// contribution, trip booking, shop checkout) using the same ledger mechanism
// TransferService uses for P2P transfers. Returns the CoreTransaction id so
// the caller can attach it to its own record for an audit trail.
export async function debitWalletForSpend(
  userId: string,
  amount: number,
  currency: string,
  category: "DONATION" | "PURCHASE"
): Promise<string> {
  if (new Decimal(amount).lte(0)) throw new Error("Amount must be greater than zero");
  if (new Decimal(amount).lt(MIN_AMOUNT)) throw new Error("Amount below minimum threshold");

  return prisma.$transaction(async (tx) => {
    const wallet = await tx.wallet.findFirst({
      where: { account: { userId }, currency, status: "ACTIVE" },
      orderBy: { createdAt: "asc" },
    });
    if (!wallet) throw new Error(`No active ${currency} wallet found`);

    const credits = await tx.ledgerEntry.aggregate({
      _sum: { amount: true },
      where: { walletId: wallet.id, direction: "CREDIT" },
    });
    const debits = await tx.ledgerEntry.aggregate({
      _sum: { amount: true },
      where: { walletId: wallet.id, direction: "DEBIT" },
    });
    const available = Number(credits._sum.amount ?? 0) - Number(debits._sum.amount ?? 0);
    if (new Decimal(available).lt(amount)) throw new Error("Insufficient funds");

    const coreTx = await tx.coreTransaction.create({
      data: { userId, type: "PAYMENT", status: "COMPLETED" },
    });

    await tx.ledgerEntry.create({
      data: {
        transactionId: coreTx.id,
        walletId: wallet.id,
        direction: "DEBIT",
        category,
        amount,
        currency,
      },
    });

    return coreTx.id;
  });
}
