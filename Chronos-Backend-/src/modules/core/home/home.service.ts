import prisma from "../../../config/prisma";

export async function getHomeSummary(userId: string) {
  const [account, tickPay, coreTransactions] = await Promise.all([
    prisma.account.findFirst({
      where: { userId },
      include: {
        wallets: {
          where: { status: "ACTIVE" },
          include: {
            ledger: { select: { direction: true, amount: true } },
          },
        },
      },
    }),
    prisma.tickPayAccount.findUnique({
      where: { userId },
      select: { creditLimit: true, balance: true, available: true, status: true },
    }),
    prisma.coreTransaction.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      take: 5,
      include: {
        ledgerEntries: {
          where: { wallet: { account: { userId } } },
          take: 1,
          select: { direction: true, amount: true, currency: true },
        },
      },
    }),
  ]);

  const wallets = (account?.wallets ?? []).map((w) => {
    const balance = w.ledger.reduce((sum, e) => {
      const amt = parseFloat(e.amount.toString());
      return e.direction === "CREDIT" ? sum + amt : sum - amt;
    }, 0);
    return { currency: w.currency, type: w.type, balance };
  });

  const accountBalance = wallets.reduce((sum, w) => sum + w.balance, 0);
  const tickPayUsed = tickPay ? parseFloat(tickPay.balance.toString()) : 0;

  // Map recent transactions — positive amount = credit, negative = debit
  const recentTransactions = coreTransactions.map((tx) => {
    const ledger = tx.ledgerEntries[0];
    const amt = ledger ? parseFloat(ledger.amount.toString()) : 0;
    const isCredit = ledger?.direction === "CREDIT";
    return {
      id: tx.id,
      type: tx.type,
      amount: isCredit ? amt : -amt,
      currency: ledger?.currency ?? "USD",
      status: tx.status,
      createdAt: tx.createdAt.toISOString(),
      description: (tx as any).reference ?? null,
    };
  });

  // Spending by category — current calendar month debits
  const now = new Date();
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
  const ledgerDebits = await prisma.ledgerEntry.findMany({
    where: {
      wallet: { account: { userId } },
      direction: "DEBIT",
      createdAt: { gte: startOfMonth },
    },
    select: {
      amount: true,
      category: true,
      transaction: { select: { type: true } },
    },
  });

  const txTypeLabel: Record<string, string> = {
    PURCHASE: "Shopping",
    PAYMENT: "Bills",
    WITHDRAWAL: "Cash Out",
    REPAYMENT: "Repayments",
    TRANSFER: "Transfers",
  };
  const categoryLabel: Record<string, string> = {
    TRANSFER: "Transfers",
    FEE: "Fees",
    FX: "Exchange",
    ADJUSTMENT: "Adjustments",
  };

  const byCategory: Record<string, number> = {};
  let totalSpent = 0;
  for (const entry of ledgerDebits) {
    const txType = (entry.transaction as any)?.type ?? "";
    const label =
      txTypeLabel[txType] ??
      categoryLabel[(entry as any).category] ??
      "Other";
    const amt = parseFloat(entry.amount.toString());
    byCategory[label] = (byCategory[label] ?? 0) + amt;
    totalSpent += amt;
  }

  return {
    accountBalance,
    totalSpent: parseFloat(totalSpent.toFixed(2)),
    recentTransactions,
    byCategory,
    currency: "USD",
    wallets,
    netWorth: {
      cash: accountBalance,
      tickPay: tickPayUsed,
      aiPortfolio: 0,
      blockHub: 0,
      investments: 0,
      total: accountBalance - tickPayUsed,
    },
  };
}

export async function getSpendingAnalysis(userId: string) {
  const now = new Date();
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

  const [ledgerDebits, billPayments] = await Promise.all([
    prisma.ledgerEntry.findMany({
      where: {
        wallet: { account: { userId } },
        direction: "DEBIT",
        createdAt: { gte: startOfMonth },
      },
      select: {
        amount: true,
        category: true,
        transaction: { select: { type: true } },
      },
    }),
    prisma.billPayment.findMany({
      where: {
        userId,
        createdAt: { gte: startOfMonth },
      },
      select: {
        amount: true,
        provider: { select: { category: true } },
      },
    }),
  ]);

  // Accumulate by display category
  const totals: Record<string, number> = {};

  const categoryLabel: Record<string, string> = {
    TRANSFER: "Transfers",
    FEE: "Fees",
    FX: "Currency Exchange",
    ADJUSTMENT: "Adjustments",
  };

  const txTypeLabel: Record<string, string> = {
    PURCHASE: "Shopping",
    PAYMENT: "Bills & Subscriptions",
    WITHDRAWAL: "Cash Out",
    REPAYMENT: "Repayments",
  };

  for (const entry of ledgerDebits) {
    const txType = entry.transaction?.type ?? "";
    const label =
      txTypeLabel[txType] ?? categoryLabel[entry.category] ?? "Other";
    const amt = parseFloat(entry.amount.toString());
    totals[label] = (totals[label] ?? 0) + amt;
  }

  // Bill payments contribute to "Bills & Subscriptions" broken down by provider category
  for (const bill of billPayments) {
    const label = bill.provider.category || "Bills & Subscriptions";
    totals[label] = (totals[label] ?? 0) + bill.amount;
  }

  const totalSpent = Object.values(totals).reduce((s, v) => s + v, 0);

  const breakdown = Object.entries(totals)
    .map(([category, amount]) => ({
      category,
      amount: parseFloat(amount.toFixed(2)),
      percentage:
        totalSpent > 0
          ? parseFloat(((amount / totalSpent) * 100).toFixed(1))
          : 0,
    }))
    .sort((a, b) => b.amount - a.amount);

  return {
    month: startOfMonth.toISOString().slice(0, 7),
    totalSpent: parseFloat(totalSpent.toFixed(2)),
    currency: "USD",
    breakdown,
  };
}

export async function getOffers() {
  // Static offers — connect to a real offers system later
  return [
    {
      id: "offer_1",
      title: "Cashback Boost",
      description: "Get 5% cashback on all dining this weekend",
      category: "Dining",
      expiresAt: (() => {
        const d = new Date();
        d.setDate(d.getDate() + 3);
        return d.toISOString();
      })(),
      imageUrl: null,
    },
    {
      id: "offer_2",
      title: "Zero FX Fees",
      description: "Exchange currency with no fees until end of month",
      category: "Exchange",
      expiresAt: (() => {
        const d = new Date();
        d.setDate(d.getDate() + 8);
        return d.toISOString();
      })(),
      imageUrl: null,
    },
    {
      id: "offer_3",
      title: "TickPay Limit Boost",
      description: "Get a 20% credit limit increase — apply today",
      category: "TickPay",
      expiresAt: (() => {
        const d = new Date();
        d.setDate(d.getDate() + 14);
        return d.toISOString();
      })(),
      imageUrl: null,
    },
  ];
}
