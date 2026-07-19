import prisma from "../../../../config/prisma";

export interface WalletSummary {
  currency: string;
  type: string;
  balance: number;
}

export interface TransactionSummary {
  type: string;
  status: string;
  amount: number;
  currency: string;
  direction: string;
  createdAt: Date;
}

export interface TickPaySummary {
  creditLimit: number;
  outstandingBalance: number;
  available: number;
  status: string;
  recentPurchases: Array<{
    amount: number;
    currency: string;
    merchant: string | null;
    status: string;
    createdAt: Date;
  }>;
  upcomingInstallments: Array<{
    amount: number;
    dueDate: Date;
    status: string;
  }>;
  onboarding: {
    monthlySalary: number;
    monthlyObligations: number;
  } | null;
}

export interface UserFinancialContext {
  userId: string;
  firstName: string;
  userLevel: string;
  tier: string;
  wallets: WalletSummary[];
  recentTransactions: TransactionSummary[];
  tickPay: TickPaySummary | null;
  habits: Array<{ name: string; category: string; frequency: string }>;
  goals: Array<{ title: string; category: string; status: string }>;
}

export async function getUserFinancialContext(
  userId: string
): Promise<UserFinancialContext> {
  const [user, walletData, ledgerEntries, tickPayAccount, onboarding, habits] =
    await Promise.all([
      prisma.user.findUniqueOrThrow({
        where: { id: userId },
        select: {
          id: true,
          firstName: true,
          userLevel: true,
          tier: true,
        },
      }),

      prisma.wallet.findMany({
        where: { account: { userId } },
        select: {
          id: true,
          currency: true,
          type: true,
          ledger: {
            select: { direction: true, amount: true },
          },
        },
      }),

      prisma.ledgerEntry.findMany({
        where: { wallet: { account: { userId } } },
        orderBy: { createdAt: "desc" },
        take: 50,
        select: {
          direction: true,
          amount: true,
          currency: true,
          createdAt: true,
          transaction: { select: { type: true, status: true } },
        },
      }),

      prisma.tickPayAccount.findUnique({
        where: { userId },
        select: {
          creditLimit: true,
          balance: true,
          available: true,
          status: true,
          transactions: {
            orderBy: { createdAt: "desc" },
            take: 10,
            select: {
              amount: true,
              currency: true,
              merchant: true,
              status: true,
              createdAt: true,
            },
          },
          feeInstallments: {
            where: { status: { in: ["SCHEDULED", "DUE"] } },
            orderBy: { dueDate: "asc" },
            take: 5,
            select: { amount: true, dueDate: true, status: true },
          },
        },
      }),

      prisma.tickPayOnboarding.findUnique({
        where: { userId },
        select: { monthlySalary: true, otherObligations: true },
      }),

      prisma.habit.findMany({
        where: { userId },
        select: { title: true, type: true, frequency: true },
        take: 10,
      }),
    ]);

  // Compute per-wallet balances from ledger (CREDIT - DEBIT)
  const wallets: WalletSummary[] = walletData.map((w) => {
    const balance = w.ledger.reduce((sum, entry) => {
      const amt = parseFloat(entry.amount.toString());
      return entry.direction === "CREDIT" ? sum + amt : sum - amt;
    }, 0);
    return { currency: w.currency, type: w.type, balance };
  });

  const recentTransactions: TransactionSummary[] = ledgerEntries.map((e) => ({
    type: e.transaction.type,
    status: e.transaction.status,
    amount: parseFloat(e.amount.toString()),
    currency: e.currency,
    direction: e.direction,
    createdAt: e.createdAt,
  }));

  let tickPay: TickPaySummary | null = null;
  if (tickPayAccount) {
    const creditLimit = parseFloat(tickPayAccount.creditLimit.toString());
    const outstanding = parseFloat(tickPayAccount.balance.toString());
    const available = tickPayAccount.available
      ? parseFloat(tickPayAccount.available.toString())
      : creditLimit - outstanding;

    tickPay = {
      creditLimit,
      outstandingBalance: outstanding,
      available,
      status: tickPayAccount.status,
      recentPurchases: tickPayAccount.transactions.map((t) => ({
        amount: parseFloat(t.amount.toString()),
        currency: t.currency,
        merchant: t.merchant,
        status: t.status,
        createdAt: t.createdAt,
      })),
      upcomingInstallments: tickPayAccount.feeInstallments.map((f) => ({
        amount: parseFloat(f.amount.toString()),
        dueDate: f.dueDate,
        status: f.status,
      })),
      onboarding: onboarding
        ? {
            monthlySalary: onboarding.monthlySalary
              ? parseFloat(onboarding.monthlySalary.toString())
              : 0,
            monthlyObligations: onboarding.otherObligations
              ? parseFloat(onboarding.otherObligations.toString())
              : 0,
          }
        : null,
    };
  }

  return {
    userId: user.id,
    firstName: user.firstName,
    userLevel: user.userLevel,
    tier: user.tier,
    wallets,
    recentTransactions,
    tickPay,
    habits: habits.map((h) => ({
      name: h.title,
      category: h.type,
      frequency: String(h.frequency),
    })),
    goals: [],
  };
}

export function summarizeContextForLLM(ctx: UserFinancialContext): string {
  const lines: string[] = [
    `User: ${ctx.firstName} | Level: ${ctx.userLevel} | Tier: ${ctx.tier}`,
    "",
    "=== WALLETS ===",
  ];

  if (ctx.wallets.length === 0) {
    lines.push("No wallets found.");
  } else {
    ctx.wallets.forEach((w) =>
      lines.push(`${w.currency} (${w.type}): $${w.balance.toFixed(2)}`)
    );
  }

  lines.push("", "=== RECENT TRANSACTIONS (last 50) ===");
  if (ctx.recentTransactions.length === 0) {
    lines.push("No transactions found.");
  } else {
    const summary = ctx.recentTransactions.slice(0, 20).map((t) => {
      const sign = t.direction === "CREDIT" ? "+" : "-";
      return `${t.createdAt.toISOString().split("T")[0]} | ${sign}$${t.amount.toFixed(2)} ${t.currency} | ${t.type} | ${t.status}`;
    });
    lines.push(...summary);
    if (ctx.recentTransactions.length > 20) {
      lines.push(`... and ${ctx.recentTransactions.length - 20} more`);
    }
  }

  if (ctx.tickPay) {
    const tp = ctx.tickPay;
    lines.push(
      "",
      "=== TICKPAY (BNPL) ===",
      `Credit Limit: $${tp.creditLimit.toFixed(2)}`,
      `Outstanding: $${tp.outstandingBalance.toFixed(2)}`,
      `Available: $${tp.available.toFixed(2)}`,
      `Status: ${tp.status}`
    );
    if (tp.upcomingInstallments.length > 0) {
      lines.push("Upcoming installments:");
      tp.upcomingInstallments.forEach((i) =>
        lines.push(
          `  $${i.amount.toFixed(2)} due ${i.dueDate.toISOString().split("T")[0]} (${i.status})`
        )
      );
    }
    if (tp.onboarding) {
      lines.push(
        `Monthly salary: $${tp.onboarding.monthlySalary.toFixed(2)}`,
        `Monthly obligations: $${tp.onboarding.monthlyObligations.toFixed(2)}`
      );
    }
  }

  if (ctx.habits.length > 0) {
    lines.push("", "=== HABITS ===");
    ctx.habits.forEach((h) =>
      lines.push(`${h.name} (${h.category}, ${h.frequency})`)
    );
  }

  return lines.join("\n");
}
