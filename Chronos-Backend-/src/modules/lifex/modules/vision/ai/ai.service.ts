import  prisma from "../../../../../config/prisma";

import { goalRules } from "./rules";

export class AIService {
  async generate(userId: string) {
    const goals = await prisma.longTermGoal.findMany({
      where: { userId }
    });

    return {
      generatedAt: new Date(),
      recommendations: [
        ...goalRules(goals)
      ]
    };
  }
}
