import prisma from "../../../../config/prisma";
import type { LogMetricInput } from "./dto/logMetric.dto";
import type { CreateFitnessSessionInput } from "./dto/createFitnessSession.dto";
import type { LogDietInput } from "./dto/logDiet.dto";
import type { MedicalRecordInput } from "./dto/medicalRecord.dto";
import type { EnrollWellnessInput } from "./dto/wellnessProgram.dto";
import type { LogHabitInput } from "./dto/habit.dto";
import { debitWalletForHsa, creditWalletFromHsa } from "./health.payments";

export class HealthService {
  // ---------------- Dashboard ----------------
  async dashboard(userId: string) {
    const metrics = await prisma.healthMetric.findMany({ where: { userId }, orderBy: { recordedAt: "desc" } });
    const latestHsa = await prisma.hsaAccount.findFirst({ where: { userId }, orderBy: { updatedAt: "desc" } });
    const notifications = await prisma.notification.findMany({ where: { userId, status: "pending" } });
    const habits = await prisma.habit.findMany({ where: { userId }, orderBy: { completedAt: "desc" } });
    const fitness = await prisma.fitnessSession.findMany({ where: { userId }, orderBy: { recordedAt: "desc" } });
    const diet = await prisma.dietLog.findMany({ where: { userId }, orderBy: { loggedAt: "desc" } });

    return { metrics, hsa: latestHsa, notifications, habits, fitness, diet };
  }

  // ---------------- Health Metrics ----------------
  async createMetric(userId: string, data: LogMetricInput) {
    if (!userId) throw new Error("User ID is required");
    return prisma.healthMetric.create({ data: { ...data, userId } });
  }

  async listMetrics(userId: string) {
    return prisma.healthMetric.findMany({ where: { userId }, orderBy: { recordedAt: "desc" } });
  }

  // ---------------- Fitness ----------------
  async logFitness(userId: string, data: CreateFitnessSessionInput) {
    return prisma.fitnessSession.create({ data: { ...data, userId } });
  }

  async listFitness(userId: string) {
    return prisma.fitnessSession.findMany({ where: { userId }, orderBy: { recordedAt: "desc" } });
  }

  // ---------------- Diet ----------------
  async logDiet(userId: string, data: LogDietInput) {
    return prisma.dietLog.create({ data: { ...data, userId } });
  }

  async listDiet(userId: string) {
    return prisma.dietLog.findMany({ where: { userId }, orderBy: { loggedAt: "desc" } });
  }

  // ---------------- HSA ----------------
  async getHsa(userId: string) {
    return prisma.hsaAccount.findFirst({ where: { userId } });
  }

  // Deposits pull real money out of the user's main wallet into the HSA
  // sub-ledger; withdrawals pay it back out. Both use the same ledger the
  // rest of the app's money movement uses (see health.payments.ts).
  async depositHsa(userId: string, amount: number) {
    await debitWalletForHsa(userId, amount);
    const account = await prisma.hsaAccount.upsert({
      where: { userId },
      update: { balance: { increment: amount }, contributions: { increment: amount } },
      create: { userId, balance: amount, contributions: amount, withdrawals: 0 },
    });
    await prisma.hsaTransaction.create({ data: { hsaAccountId: account.id, type: "deposit", amount, currency: "USD", date: new Date() } });
    return account;
  }

  async withdrawHsa(userId: string, amount: number) {
    const account = await prisma.hsaAccount.findUnique({ where: { userId } });
    if (!account) throw new Error("HSA account not found");
    if (account.balance < amount) throw new Error("Insufficient balance");
    await creditWalletFromHsa(userId, amount);
    const updated = await prisma.hsaAccount.update({ where: { userId }, data: { balance: { decrement: amount }, withdrawals: { increment: amount } } });
    await prisma.hsaTransaction.create({ data: { hsaAccountId: updated.id, type: "withdrawal", amount, currency: "USD", date: new Date() } });
    return updated;
  }

  // ---------------- Medical ----------------
  async addMedical(userId: string, data: MedicalRecordInput) {
    return prisma.medicalRecord.create({ data: { ...data, userId } });
  }

  async listMedical(userId: string) {
    return prisma.medicalRecord.findMany({ where: { userId }, orderBy: { recordedAt: "desc" } });
  }

  // ---------------- Wellness ----------------
  async listWellness() {
    return prisma.wellnessProgram.findMany({ where: { status: "active" } });
  }

  async enrollWellness(userId: string, data: EnrollWellnessInput) {
    return prisma.wellnessEnrollment.create({ data: { userId, programId: data.programId, enrolledAt: new Date() } });
  }

  // ---------------- Habits ----------------
  async logHabit(userId: string, data: LogHabitInput) {
    return prisma.habit.create({ data: { ...data, userId } });
  }

  async listHabits(userId: string) {
    return prisma.habit.findMany({ where: { userId }, orderBy: { completedAt: "desc" } });
  }

  // ---------------- Gyms ----------------
  async listGyms(city?: string) {
    return prisma.gymPartner.findMany({ where: city ? { city } : undefined, orderBy: { name: "asc" } });
  }

  // ---------------- Insurance Marketplace ----------------
  // The plan catalog itself is mock/curated content on the client; this just
  // records which plan the user picked.
  async enrollInsurance(
    userId: string,
    data: { provider: string; planName: string; coverageType: string; monthlyPremium: number }
  ) {
    return prisma.insuranceEnrollment.create({ data: { userId, ...data } });
  }

  async myInsurance(userId: string) {
    return prisma.insuranceEnrollment.findMany({ where: { userId, status: "ACTIVE" }, orderBy: { enrolledAt: "desc" } });
  }

  // ---------------- Nutrition Partners ----------------
  // Same as above — the partner catalog (MyFitnessPal-style apps) is
  // mock/curated content on the client; this records the connection.
  async connectNutritionPartner(userId: string, data: { partnerName: string; category?: string }) {
    return prisma.nutritionConnection.upsert({
      where: { userId_partnerName: { userId, partnerName: data.partnerName } },
      update: { status: "CONNECTED" },
      create: { userId, partnerName: data.partnerName, category: data.category },
    });
  }

  async myNutritionConnections(userId: string) {
    return prisma.nutritionConnection.findMany({ where: { userId }, orderBy: { connectedAt: "desc" } });
  }

  // ---------------- Wearable Integrations ----------------
  static wearableProviders = [
    { id: "apple_health", name: "Apple Health" },
    { id: "fitbit", name: "Fitbit" },
    { id: "garmin", name: "Garmin" },
    { id: "google_fit", name: "Google Fit" },
  ];

  listWearableProviders() {
    return HealthService.wearableProviders;
  }

  async connectWearable(userId: string, provider: string) {
    return prisma.wearableConnection.upsert({
      where: { userId_provider: { userId, provider } },
      update: { status: "CONNECTED" },
      create: { userId, provider },
    });
  }

  async myWearableConnections(userId: string) {
    return prisma.wearableConnection.findMany({ where: { userId } });
  }

  // Wearables push metrics through the same HealthMetric table manual entries
  // use, tagged with their source so the dashboard/insights can tell them apart.
  async syncWearableMetrics(
    userId: string,
    provider: string,
    metrics: Array<{ metricType: string; value: number; unit: string; recordedAt?: string }>
  ) {
    await prisma.wearableConnection.updateMany({ where: { userId, provider }, data: { lastSyncAt: new Date() } });
    return prisma.healthMetric.createMany({
      data: metrics.map((m) => ({
        userId,
        metricType: m.metricType,
        value: m.value,
        unit: m.unit,
        source: provider,
        recordedAt: m.recordedAt ? new Date(m.recordedAt) : new Date(),
      })),
    });
  }

  // ---------------- Tailored Guidance ----------------
  async getInsights(userId: string) {
    const [metrics, hsa, insurance, wearables] = await Promise.all([
      prisma.healthMetric.findMany({ where: { userId }, orderBy: { recordedAt: "desc" }, take: 20 }),
      prisma.hsaAccount.findFirst({ where: { userId } }),
      prisma.insuranceEnrollment.findFirst({ where: { userId, status: "ACTIVE" } }),
      prisma.wearableConnection.findMany({ where: { userId } }),
    ]);

    const insights: Array<{ type: string; severity: "info" | "warning" | "good"; message: string }> = [];

    const steps = metrics.find((m) => m.metricType === "steps");
    if (steps && steps.value < 5000) {
      insights.push({ type: "activity", severity: "warning", message: "Your recent step count is below 5,000/day — a short daily walk goes a long way." });
    } else if (steps) {
      insights.push({ type: "activity", severity: "good", message: "You're hitting a healthy step count — keep it up." });
    }

    const sleep = metrics.find((m) => m.metricType === "sleep");
    if (sleep && sleep.value < 6) {
      insights.push({ type: "sleep", severity: "warning", message: "Recent sleep is under 6 hours — recovery and mood both suffer below that." });
    }

    if (!hsa || hsa.balance <= 0) {
      insights.push({ type: "hsa", severity: "info", message: "You haven't funded your HSA yet — even small recurring contributions add up tax-free." });
    }

    if (!insurance) {
      insights.push({ type: "insurance", severity: "info", message: "You don't have an active insurance plan on file — browse the marketplace to compare coverage." });
    }

    if (wearables.length === 0) {
      insights.push({ type: "wearable", severity: "info", message: "Connect a wearable so Chris can track your metrics automatically instead of manual logging." });
    }

    return insights;
  }

  // ---------------- Notifications ----------------
  async notifications(userId: string) {
    return prisma.notification.findMany({ where: { userId, status: "pending" }, orderBy: { scheduledAt: "asc" } });
  }

  // ---------------- Reports & AI ----------------
  async generateReports(userId: string) {
    // Placeholder for analytics/reporting engine
    return { message: "Reports generation not implemented yet." };
  }

  async aiInsights(userId: string) {
    return this.getInsights(userId);
  }
}
