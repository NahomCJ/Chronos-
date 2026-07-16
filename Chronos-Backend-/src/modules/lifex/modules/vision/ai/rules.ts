import { AIRecommendation } from "./types";

export function goalRules(goals: any[]): AIRecommendation[] {
  const recs: AIRecommendation[] = [];

  const activeGoals = goals.filter(g => g.status === "ACTIVE");

  if (activeGoals.length === 0) {
    recs.push({
      type: "GOAL",
      title: "Define your first long-term goal",
      reason: "Users with at least one goal are 3x more likely to stay consistent"
    });
  }

  if (activeGoals.length > 3) {
    recs.push({
      type: "HABIT",
      title: "Daily planning habit",
      reason: "Too many active goals reduce completion rate"
    });
  }

  return recs;
}
