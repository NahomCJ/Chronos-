import Decimal from "decimal.js";
import prisma from "../../../../config/prisma";

const MIN_AMOUNT = Number(process.env.TRANSFER_MIN_AMOUNT ?? 1);

async function findActiveWallet(userId: string, currency: string) {
  const wallet = await prisma.wallet.findFirst({
    where: { account: { userId }, currency, status: "ACTIVE" },
    orderBy: { createdAt: "asc" },
  });
  if (!wallet) throw new Error(`No active ${currency} wallet found`);
  return wallet;
}

// Moves money from the user's main wallet into a sub-ledger balance (e.g. HSA).
export async function debitWalletForHsa(userId: string, amount: number, currency = "USD"): Promise<string> {
  if (new Decimal(amount).lte(0)) throw new Error("Amount must be greater than zero");
  if (new Decimal(amount).lt(MIN_AMOUNT)) throw new Error("Amount below minimum threshold");

  return prisma.$transaction(async (tx) => {
    const wallet = await findActiveWallet(userId, currency);

    const credits = await tx.ledgerEntry.aggregate({ _sum: { amount: true }, where: { walletId: wallet.id, direction: "CREDIT" } });
    const debits = await tx.ledgerEntry.aggregate({ _sum: { amount: true }, where: { walletId: wallet.id, direction: "DEBIT" } });
    const available = Number(credits._sum.amount ?? 0) - Number(debits._sum.amount ?? 0);
    if (new Decimal(available).lt(amount)) throw new Error("Insufficient funds");

    const coreTx = await tx.coreTransaction.create({ data: { userId, type: "PAYMENT", status: "COMPLETED" } });
    await tx.ledgerEntry.create({
      data: { transactionId: coreTx.id, walletId: wallet.id, direction: "DEBIT", category: "HSA", amount, currency },
    });
    return coreTx.id;
  });
}

// Moves money back out of the sub-ledger balance into the user's main wallet.
export async function creditWalletFromHsa(userId: string, amount: number, currency = "USD"): Promise<string> {
  if (new Decimal(amount).lte(0)) throw new Error("Amount must be greater than zero");

  return prisma.$transaction(async (tx) => {
    const wallet = await findActiveWallet(userId, currency);
    const coreTx = await tx.coreTransaction.create({ data: { userId, type: "PAYMENT", status: "COMPLETED" } });
    await tx.ledgerEntry.create({
      data: { transactionId: coreTx.id, walletId: wallet.id, direction: "CREDIT", category: "HSA", amount, currency },
    });
    return coreTx.id;
  });
}
