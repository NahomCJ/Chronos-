import prisma from "../../../models/prisma";

export class CryptoRiskService {
  // Simple allowlist/denylist; expand with your KYC provider
  async assertKycCleared(userId: string) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new Error("User not found");
    if (user.kycStatus !== "APPROVED") {
      throw new Error("KYC not approved");
    }
  }

  async assertAmlOk(userId: string, base: string, quote: string) {
    // Placeholder: call your AML provider. For now, block known privacy coins if policy requires.
    const blocked = ["XMR", "ZEC"];
    if (blocked.includes(base) || blocked.includes(quote)) {
      throw new Error("Asset restricted by AML policy");
    }
  }

  async checkVelocity(userId: string, quoteAmountInUsd: number) {
    const cfgDaily = Number(process.env.CRYPTO_DAILY_LIMIT_USD ?? 10000);
    const cfgMonthly = Number(process.env.CRYPTO_MONTHLY_LIMIT_USD ?? 50000);

    const now = new Date();
    const dayAgo = new Date(now.getTime() - 24 * 3600 * 1000);
    const monthAgo = new Date(now.getTime() - 30 * 24 * 3600 * 1000);

    const [daySum, monthSum] = await Promise.all([
      prisma.cryptoTransaction.aggregate({
        _sum: { amountUsd: true },
        where: { userId, createdAt: { gte: dayAgo }, status: "COMPLETED" },
      }),
      prisma.cryptoTransaction.aggregate({
        _sum: { amountUsd: true },
        where: { userId, createdAt: { gte: monthAgo }, status: "COMPLETED" },
      }),
    ]);

    const d = daySum._sum.amountUsd || 0;
    const m = monthSum._sum.amountUsd || 0;

    if (d + quoteAmountInUsd > cfgDaily) throw new Error("Daily limit exceeded");
    if (m + quoteAmountInUsd > cfgMonthly) throw new Error("Monthly limit exceeded");
  }
}

export default new CryptoRiskService();
