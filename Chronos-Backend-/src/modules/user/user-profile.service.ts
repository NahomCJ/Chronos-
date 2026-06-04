import prisma from "../../core/prisma";

export async function getUserProfile(userId: string) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      firstName: true,
      middleName: true,
      lastName: true,
      email: true,
      phone: true,
      tier: true,
      userLevel: true,
      createdAt: true,
    },
  });

  if (!user) throw new Error("User not found");

  const [txCount, account] = await Promise.all([
    prisma.coreTransaction.count({ where: { userId } }),
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
  ]);

  let balance = 0;
  if (account) {
    for (const wallet of account.wallets) {
      for (const entry of wallet.ledger) {
        const amt = parseFloat(entry.amount.toString());
        balance += entry.direction === "CREDIT" ? amt : -amt;
      }
    }
  }

  return {
    id: user.id,
    firstName: user.firstName,
    middleName: user.middleName ?? null,
    lastName: user.lastName,
    email: user.email,
    phone: user.phone ?? null,
    tier: user.tier,
    userLevel: user.userLevel,
    memberSince: user.createdAt.toISOString(),
    stats: {
      balance: Math.max(balance, 0),
      transactionCount: txCount,
    },
  };
}

export async function updateUserProfile(
  userId: string,
  data: { firstName?: string; lastName?: string; phone?: string }
) {
  const updated = await prisma.user.update({
    where: { id: userId },
    data: {
      ...(data.firstName && { firstName: data.firstName }),
      ...(data.lastName && { lastName: data.lastName }),
      ...(data.phone !== undefined && { phone: data.phone }),
    },
    select: {
      id: true,
      firstName: true,
      middleName: true,
      lastName: true,
      email: true,
      phone: true,
      tier: true,
      userLevel: true,
      createdAt: true,
    },
  });
  return updated;
}
