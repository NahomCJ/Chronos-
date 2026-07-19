import prisma from "../../../../config/prisma";

interface FeedItem {
  id: string;
  type: string;
  module: string;
  title: string;
  description?: string;
  metadata?: any;
  createdAt: Date;
}

export class FeedService {
  async personalFeed(userId: string): Promise<FeedItem[]> {
    const [activities, posts, goals, meditations, fitnessLogs] = await Promise.all([
      prisma.activityLog.findMany({ where: { userId }, orderBy: { createdAt: "desc" }, take: 20 }),
      prisma.socialPost.findMany({ where: { userId }, orderBy: { createdAt: "desc" }, take: 10 }),
      prisma.longTermGoal.findMany({ where: { userId }, orderBy: { startDate: "desc" }, take: 5 }),
      prisma.meditationSession.findMany({ where: { userId }, orderBy: { recordedAt: "desc" }, take: 10 }),
      prisma.fitnessSession.findMany({ where: { userId }, orderBy: { recordedAt: "desc" }, take: 10 }),
    ]);

    const items: FeedItem[] = [
      ...activities.map((a) => ({ id: a.id, type: "activity", module: a.module, title: a.title, metadata: a.metadata, createdAt: a.createdAt })),
      ...posts.map((p) => ({ id: p.id, type: "post", module: "social", title: p.content, metadata: { likes: p.likes, postType: p.type }, createdAt: p.createdAt })),
      ...goals.map((g) => ({ id: g.id, type: "goal", module: "vision", title: `Goal: ${g.title}`, description: g.description, metadata: { status: g.status, category: g.category }, createdAt: g.startDate })),
      ...meditations.map((m) => ({ id: m.id, type: "meditation", module: "spiritual", title: `${m.type} session — ${m.durationMin} min`, metadata: { moodBefore: m.moodBefore, moodAfter: m.moodAfter }, createdAt: m.recordedAt })),
      ...fitnessLogs.map((f) => ({ id: f.id, type: "fitness", module: "health", title: `${f.type} — ${f.duration} min`, metadata: { caloriesBurned: f.caloriesBurned }, createdAt: f.recordedAt })),
    ];

    return items.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()).slice(0, 50);
  }

  async communityFeed(userId: string): Promise<FeedItem[]> {
    const followingList = await prisma.socialConnection.findMany({ where: { userId }, select: { followingId: true } });
    const ids = followingList.map((f) => f.followingId);
    if (ids.length === 0) return [];

    const posts = await prisma.socialPost.findMany({
      where: { userId: { in: ids } },
      orderBy: { createdAt: "desc" },
      take: 30,
    });

    return posts.map((p) => ({
      id: p.id,
      type: "post",
      module: "social",
      title: p.content,
      metadata: { likes: p.likes, postType: p.type, authorId: p.userId },
      createdAt: p.createdAt,
    }));
  }

  async summary(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [todayActivities, todayMeditation, todayFitness, activeGoals] = await Promise.all([
      prisma.activityLog.count({ where: { userId, createdAt: { gte: today } } }),
      prisma.meditationSession.aggregate({ where: { userId, recordedAt: { gte: today } }, _sum: { durationMin: true } }),
      prisma.fitnessSession.aggregate({ where: { userId, recordedAt: { gte: today } }, _sum: { caloriesBurned: true } }),
      prisma.longTermGoal.count({ where: { userId, status: "ACTIVE" } }),
    ]);

    return {
      date: today,
      todayActivities,
      meditationMinutesToday: todayMeditation._sum.durationMin ?? 0,
      caloriesBurnedToday: todayFitness._sum.caloriesBurned ?? 0,
      activeGoals,
    };
  }
}
