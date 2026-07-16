import prisma from "../../../../config/prisma";

export class ActivityService {
  async log(userId: string, module: string, type: string, title: string, metadata?: any) {
    return prisma.activityLog.create({ data: { userId, module, type, title, metadata } });
  }

  async list(userId: string, module?: string) {
    return prisma.activityLog.findMany({
      where: { userId, ...(module ? { module } : {}) },
      orderBy: { createdAt: "desc" },
      take: 100,
    });
  }

  async stats(userId: string) {
    const logs = await prisma.activityLog.findMany({ where: { userId } });
    const byModule: Record<string, number> = {};
    for (const log of logs) {
      byModule[log.module] = (byModule[log.module] ?? 0) + 1;
    }
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayCount = logs.filter((l) => new Date(l.createdAt) >= today).length;
    return { total: logs.length, todayCount, byModule };
  }

  async streak(userId: string) {
    const logs = await prisma.activityLog.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      select: { createdAt: true },
    });

    const days = new Set(logs.map((l) => l.createdAt.toISOString().slice(0, 10)));
    let streak = 0;
    const cur = new Date();
    while (true) {
      const key = cur.toISOString().slice(0, 10);
      if (!days.has(key)) break;
      streak++;
      cur.setDate(cur.getDate() - 1);
    }
    return { streak };
  }
}
