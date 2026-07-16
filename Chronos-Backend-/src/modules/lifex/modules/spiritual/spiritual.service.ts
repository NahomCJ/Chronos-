import prisma from "../../../../config/prisma";
import { debitWalletForSpend } from "./spiritual.payments";

export class SpiritualService {
  async dashboard(userId: string) {
    const [sessions, gratitude, goals] = await Promise.all([
      prisma.meditationSession.findMany({ where: { userId }, orderBy: { recordedAt: "desc" }, take: 10 }),
      prisma.gratitudeEntry.findMany({ where: { userId }, orderBy: { createdAt: "desc" }, take: 5 }),
      prisma.spiritualGoal.findMany({ where: { userId, status: "ACTIVE" } }),
    ]);
    const totalMinutes = sessions.reduce((sum, s) => sum + s.durationMin, 0);
    const streak = await this.streak(userId);
    return { sessions: sessions.slice(0, 5), recentGratitude: gratitude, activeGoals: goals, totalMeditationMinutes: totalMinutes, streak };
  }

  async logMeditation(userId: string, data: { durationMin: number; type: string; notes?: string; moodBefore?: string; moodAfter?: string }) {
    return prisma.meditationSession.create({ data: { ...data, userId } });
  }

  async listMeditations(userId: string) {
    return prisma.meditationSession.findMany({ where: { userId }, orderBy: { recordedAt: "desc" } });
  }

  async meditationStats(userId: string) {
    const sessions = await prisma.meditationSession.findMany({ where: { userId } });
    const totalMinutes = sessions.reduce((s, m) => s + m.durationMin, 0);
    const byType: Record<string, number> = {};
    for (const s of sessions) byType[s.type] = (byType[s.type] ?? 0) + 1;
    return { totalSessions: sessions.length, totalMinutes, byType };
  }

  async addGratitude(userId: string, content: string) {
    return prisma.gratitudeEntry.create({ data: { userId, content } });
  }

  async listGratitude(userId: string) {
    return prisma.gratitudeEntry.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
  }

  async createGoal(userId: string, data: { title: string; description?: string; frequency: string }) {
    return prisma.spiritualGoal.create({ data: { ...data, userId } });
  }

  async listGoals(userId: string) {
    return prisma.spiritualGoal.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
  }

  async updateGoalProgress(goalId: string, progress: number) {
    const status = progress >= 100 ? "COMPLETED" : "ACTIVE";
    return prisma.spiritualGoal.update({ where: { id: goalId }, data: { progress, status } });
  }

  async streak(userId: string) {
    const sessions = await prisma.meditationSession.findMany({
      where: { userId },
      orderBy: { recordedAt: "desc" },
      select: { recordedAt: true },
    });
    const days = new Set(sessions.map((s) => s.recordedAt.toISOString().slice(0, 10)));
    let streak = 0;
    const cur = new Date();
    while (true) {
      const key = cur.toISOString().slice(0, 10);
      if (!days.has(key)) break;
      streak++;
      cur.setDate(cur.getDate() - 1);
    }
    return streak;
  }

  // ── Giving: donations to charities ──────────────────────────────────────
  async donate(
    userId: string,
    data: { charityName: string; category?: string; amount: number; currency?: string; recurring?: boolean; frequency?: string }
  ) {
    const currency = data.currency ?? "USD";
    const transactionId = await debitWalletForSpend(userId, data.amount, currency, "DONATION");
    return prisma.donation.create({
      data: {
        userId,
        charityName: data.charityName,
        category: data.category,
        amount: data.amount,
        currency,
        recurring: data.recurring ?? false,
        frequency: data.frequency,
        transactionId,
        status: "SUCCESS",
      },
    });
  }

  async listDonations(userId: string) {
    return prisma.donation.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
  }

  // ── Crowdfunding: contributions to campaigns ────────────────────────────
  async contribute(
    userId: string,
    data: { campaignTitle: string; campaignCategory?: string; amount: number; currency?: string }
  ) {
    const currency = data.currency ?? "USD";
    const transactionId = await debitWalletForSpend(userId, data.amount, currency, "DONATION");
    return prisma.campaignContribution.create({
      data: {
        userId,
        campaignTitle: data.campaignTitle,
        campaignCategory: data.campaignCategory,
        amount: data.amount,
        currency,
        transactionId,
        status: "SUCCESS",
      },
    });
  }

  async listContributions(userId: string) {
    return prisma.campaignContribution.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
  }

  // ── Spiritual trips ──────────────────────────────────────────────────────
  async bookTrip(
    userId: string,
    data: { tripTitle: string; destination?: string; travelers?: number; totalAmount: number; currency?: string }
  ) {
    const currency = data.currency ?? "USD";
    const transactionId = await debitWalletForSpend(userId, data.totalAmount, currency, "PURCHASE");
    return prisma.tripBooking.create({
      data: {
        userId,
        tripTitle: data.tripTitle,
        destination: data.destination,
        travelers: data.travelers ?? 1,
        totalAmount: data.totalAmount,
        currency,
        transactionId,
        status: "SUCCESS",
      },
    });
  }

  async listTripBookings(userId: string) {
    return prisma.tripBooking.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
  }

  // ── Spiritual shop (ecommerce) ───────────────────────────────────────────
  async checkout(
    userId: string,
    data: { items: Array<{ name: string; price: number; qty: number }>; currency?: string }
  ) {
    const currency = data.currency ?? "USD";
    const totalAmount = data.items.reduce((sum, i) => sum + i.price * i.qty, 0);
    const transactionId = await debitWalletForSpend(userId, totalAmount, currency, "PURCHASE");
    return prisma.spiritualOrder.create({
      data: {
        userId,
        items: data.items,
        totalAmount,
        currency,
        transactionId,
        status: "SUCCESS",
      },
    });
  }

  async listOrders(userId: string) {
    return prisma.spiritualOrder.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
  }

  // ── Faith (captured at onboarding, drives event/product filtering) ──────
  async getFaith(userId: string) {
    const user = await prisma.user.findUnique({ where: { id: userId }, select: { faith: true } });
    return { faith: user?.faith ?? null };
  }

  async setFaith(userId: string, faith: string) {
    const user = await prisma.user.update({ where: { id: userId }, data: { faith }, select: { faith: true } });
    return user;
  }
}
