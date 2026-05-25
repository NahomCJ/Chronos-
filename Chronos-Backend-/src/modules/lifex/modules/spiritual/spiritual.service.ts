import prisma from "../../../../config/prisma";

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
}
