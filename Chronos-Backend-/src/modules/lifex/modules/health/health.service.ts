import prisma from "../../../../config/prisma";
import type { LogMetricInput } from "./dto/logMetric.dto";
import type { CreateFitnessSessionInput } from "./dto/createFitnessSession.dto";
import type { LogDietInput } from "./dto/logDiet.dto";
import type { MedicalRecordInput } from "./dto/medicalRecord.dto";
import type { EnrollWellnessInput } from "./dto/wellnessProgram.dto";
import type { LogHabitInput } from "./dto/habit.dto";

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

  async depositHsa(userId: string, amount: number) {
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
  async listGyms() {
    return prisma.gymPartner.findMany();
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
    // Placeholder for AI engine
    return { message: "AI insights not implemented yet." };
  }
}
