import prisma from "../../../../config/prisma";

export class ExportService {
  async healthData(userId: string) {
    const [metrics, fitness, diet, medical, habits] = await Promise.all([
      prisma.healthMetric.findMany({ where: { userId }, orderBy: { recordedAt: "desc" } }),
      prisma.fitnessSession.findMany({ where: { userId }, orderBy: { recordedAt: "desc" } }),
      prisma.dietLog.findMany({ where: { userId }, orderBy: { loggedAt: "desc" } }),
      prisma.medicalRecord.findMany({ where: { userId }, orderBy: { recordedAt: "desc" } }),
      prisma.habit.findMany({ where: { userId } }),
    ]);
    return { exportedAt: new Date(), userId, metrics, fitness, diet, medical, habits };
  }

  async financeData(userId: string) {
    const [plans, transactions, loans, budgets, creditScores] = await Promise.all([
      prisma.financialPlan.findMany({ where: { userId } }),
      prisma.transaction.findMany({ where: { userId }, orderBy: { createdAt: "desc" } }),
      prisma.loan.findMany({ where: { userId } }),
      prisma.budget.findMany({ where: { userId } }),
      prisma.creditScore.findMany({ where: { userId }, orderBy: { checkedAt: "desc" } }),
    ]);
    return { exportedAt: new Date(), userId, plans, transactions, loans, budgets, creditScores };
  }

  async educationData(userId: string) {
    const [enrollments, studentLoans, sessions] = await Promise.all([
      prisma.enrollment.findMany({ where: { userId }, include: { course: true } }),
      prisma.studentLoan.findMany({ where: { userId } }),
      prisma.tutorSession.findMany({ where: { userId }, include: { tutor: true } }),
    ]);
    return { exportedAt: new Date(), userId, enrollments, studentLoans, tutorSessions: sessions };
  }

  async visionData(userId: string) {
    const [boards, goals, habits] = await Promise.all([
      prisma.visionBoard.findMany({ where: { userId } }),
      prisma.longTermGoal.findMany({ where: { userId }, include: { milestones: true } }),
      prisma.habitTracker.findMany({ where: { userId } }),
    ]);
    return { exportedAt: new Date(), userId, boards, goals, habits };
  }

  async fullExport(userId: string) {
    const [health, finance, education, vision, activities, spiritual] = await Promise.all([
      this.healthData(userId),
      this.financeData(userId),
      this.educationData(userId),
      this.visionData(userId),
      prisma.activityLog.findMany({ where: { userId }, orderBy: { createdAt: "desc" } }),
      prisma.meditationSession.findMany({ where: { userId }, orderBy: { recordedAt: "desc" } }),
    ]);
    return { exportedAt: new Date(), userId, health, finance, education, vision, activities, spiritual };
  }
}
