// src/modules/bnpl/services/tickpay.onboard.service.ts
import prisma from "../../../config/prisma";
import scoringService from "./tickpay.scoring.service"; // adjust import path if needed
import { auditLog } from "../utils/audit"; // adjust path if your audit util lives elsewhere
import { OnboardPayload } from "../middlewares/validate.middleware";

/**
 * Very small affordability calculator:
 * - If monthlySalary provided -> recommendedLimit = max(100, monthlySalary * 0.5)
 * - Reduce by obligations ratio
 * - Combine with scoringService score if available
 */
function computeRecommendedLimit(payload: OnboardPayload, externalScore?: number) {
  const salary = payload.monthlySalary ?? 0;
  let base = Math.max(100, salary * 0.5);

  const obligations = (payload.otherObligations ?? 0)
    + (payload.monthlyRent ?? 0)
    + (payload.monthlyUtilities ?? 0)
    + (payload.outstandingLoans ?? 0);

  // reduce base by obligations factor (simple)
  const reductionFactor = Math.min(0.9, obligations > 0 ? Math.max(0, obligations / Math.max(1, salary + obligations)) : 0);
  base = base * (1 - reductionFactor * 0.5);

  // adjust with external score (0-100)
  if (externalScore !== undefined && externalScore !== null) {
    const scoreFactor = Math.max(0.5, externalScore / 100); // don't go below 50%
    base = base * scoreFactor;
  }

  // round to 2 decimals
  return Number(base.toFixed(2));
}

class TickPayOnboardService {
  async createOnboarding(userId: string, payload: OnboardPayload) {
    // ensure user exists
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new Error("User not found. User must register and exist before TickPay onboarding.");

    // 1) call optional scoring service to compute user score (non-blocking fallback)
    let score: number | undefined = undefined;
    try {
      // scoringService.approvePurchase returns {score, ...} — reuse or call a dedicated method
      const decision = await scoringService.approvePurchase(userId, payload.monthlySalary ? Number(payload.monthlySalary) : 0);
      score = decision.score ?? undefined;
    } catch (err) {
      // log but continue with local logic
      console.warn("Scoring service failed or unavailable:", err);
    }

    // 2) compute recommended limit
    const recommendedLimit = computeRecommendedLimit(payload, score);

    // 3) upsert onboarding record
    const onboard = await (prisma as any).tickPayOnboarding.upsert({
      where: { userId },
      update: {
        ...payloadToPrisma(payload),
        score: score ?? null,
        recommendedLimit: recommendedLimit ?? null,
      },
      create: {
        userId,
        ...payloadToPrisma(payload),
        score: score ?? null,
        recommendedLimit: recommendedLimit ?? null,
      },
    });

    // 4) create TickPayAccount if not exists, set creditLimit to recommendedLimit
    const existingAcct = await prisma.tickPayAccount.findUnique({ where: { userId } });
    let account = existingAcct;
    if (!existingAcct) {
      account = await prisma.tickPayAccount.create({
        data: {
          userId,
          creditLimit: recommendedLimit.toString(), // prisma Decimal acceptance
          balance: "0",
          status: "ACTIVE",
        },
      });
    } else {
      // Optionally update creditLimit if lower/higher based on policy — here we set only if current is default or lower
      // Uncomment to update:
      // await prisma.tickPayAccount.update({ where: { userId }, data: { creditLimit: recommendedLimit.toString() } });
    }

    // 5) audit
    await auditLog?.({
      actorId: userId,
      accountId: account?.id,
      action: "TICKPAY_ONBOARD",
      metadata: { recommendedLimit, score },
    }).catch(() => null);

    return {
      onboarding: onboard,
      account,
      recommendedLimit,
      score,
    };
  }

  async getOnboarding(userId: string) {
    const onboard = await (prisma as any).tickPayOnboarding.findUnique({ where: { userId } });
    if (!onboard) throw new Error("No onboarding found");
    return onboard;
  }
}

function payloadToPrisma(p: OnboardPayload) {
  // convert numbers to string/Decimal-friendly format or null
  return {
    employmentStatus: p.employmentStatus,
    employerName: p.employerName ?? null,
    monthlySalary: p.monthlySalary !== undefined ? String(p.monthlySalary) : null,
    incomeFrequency: p.incomeFrequency ?? null,
    primaryIncomeSrc: p.primaryIncomeSrc ?? null,
    secondaryIncome: p.secondaryIncome !== undefined ? String(p.secondaryIncome) : null,
    bankName: p.bankName ?? null,
    accountType: p.accountType ?? null,
    monthlyRent: p.monthlyRent !== undefined ? String(p.monthlyRent) : null,
    monthlyUtilities: p.monthlyUtilities !== undefined ? String(p.monthlyUtilities) : null,
    otherObligations: p.otherObligations !== undefined ? String(p.otherObligations) : null,
    outstandingLoans: p.outstandingLoans !== undefined ? String(p.outstandingLoans) : null,
    avgMonthlySpending: p.avgMonthlySpending !== undefined ? String(p.avgMonthlySpending) : null,
    purpose: p.purpose ?? null,
    spendingPrefs: p.spendingPrefs ?? null,
    agreedTerms: p.agreedTerms,
    agreedDataSharing: p.agreedDataSharing,
    noRecentBankruptcy: p.noRecentBankruptcy ?? null,
  };
}

export default new TickPayOnboardService();
