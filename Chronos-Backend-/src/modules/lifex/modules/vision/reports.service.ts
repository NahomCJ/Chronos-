import  prisma  from "../../../../config/prisma";

export class ReportsService {
  async generate(userId: string) {
    const goals = await prisma.longTermGoal.findMany({
      where: { userId },
      include: { milestones: true }
    });

    return {
      totalGoals: goals.length,
      completedGoals: goals.filter(g => g.status === "COMPLETED").length
    };
  }
}
