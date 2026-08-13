import prisma from "../../../../config/prisma";
import { callLLMFast } from "../../../ai/panther/llm/llm.client";

export class LifeAiService {
  async getInsights(userId: string) {
    const [goals, habits, meditations, activities, healthMetrics] = await Promise.all([
      prisma.longTermGoal.findMany({ where: { userId }, take: 5, orderBy: { startDate: "desc" } }),
      prisma.habitTracker.findMany({ where: { userId } }),
      prisma.meditationSession.findMany({ where: { userId }, take: 10, orderBy: { recordedAt: "desc" } }),
      prisma.activityLog.findMany({ where: { userId }, take: 20, orderBy: { createdAt: "desc" } }),
      prisma.healthMetric.findMany({ where: { userId }, take: 5, orderBy: { recordedAt: "desc" } }),
    ]);

    const context = JSON.stringify({ goals, habits, meditations: meditations.length, activities: activities.length, healthMetrics });

    const prompt = `You are a personal life coach AI. Based on the user's data below, provide 3 concise, actionable insights to help them grow. Be encouraging and specific.\n\nUser data: ${context}`;
    const insights = await callLLMFast(
      "You are a compassionate, motivating personal life coach specializing in holistic wellness, goal achievement, and spiritual growth.",
      prompt
    );

    return { insights, dataSnapshot: { goals: goals.length, habits: habits.length, meditations: meditations.length, activities: activities.length } };
  }

  async coachReply(userId: string, message: string) {
    const [goals, habits, spiritualGoals] = await Promise.all([
      prisma.longTermGoal.findMany({ where: { userId }, take: 3 }),
      prisma.habitTracker.findMany({ where: { userId } }),
      prisma.spiritualGoal.findMany({ where: { userId } }),
    ]);

    const context = `Active goals: ${goals.map((g) => g.title).join(", ") || "none"}. Habits: ${habits.map((h) => h.habitName).join(", ") || "none"}. Spiritual goals: ${spiritualGoals.map((s) => s.title).join(", ") || "none"}.`;

    const reply = await callLLMFast(
      `You are a supportive life coach AI integrated into the Chronos LifeX app. You help users with personal development, health, wellness, and goal achievement. Context about this user: ${context}`,
      message
    );

    return { reply };
  }

  async weeklyPlan(userId: string) {
    const [goals, habits, spiritual] = await Promise.all([
      prisma.longTermGoal.findMany({ where: { userId, status: "ACTIVE" }, take: 3 }),
      prisma.habitTracker.findMany({ where: { userId, status: "ACTIVE" } }),
      prisma.spiritualGoal.findMany({ where: { userId, status: "ACTIVE" } }),
    ]);

    const prompt = `Create a simple 7-day plan to help the user make progress. Active goals: ${goals.map((g) => g.title).join(", ") || "none"}. Daily habits: ${habits.map((h) => h.habitName).join(", ") || "none"}. Spiritual goals: ${spiritual.map((s) => s.title).join(", ") || "none"}. Format as Day 1 through Day 7 with 1-2 tasks each.`;

    const plan = await callLLMFast(
      "You are a practical life coach helping users build a weekly action plan for personal growth.",
      prompt
    );

    return { plan };
  }
}
