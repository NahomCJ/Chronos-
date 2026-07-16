import prisma from "../../../../config/prisma";

export class FamilyService {
  // ---------------- Groups ----------------
  async createGroup(ownerId: string, name: string) {
    const group = await prisma.familyGroup.create({ data: { name, ownerId } });
    await prisma.familyMember.create({ data: { familyGroupId: group.id, userId: ownerId, role: "owner" } });
    return group;
  }

  async getMyGroups(userId: string) {
    const memberships = await prisma.familyMember.findMany({
      where: { userId },
      include: { familyGroup: { include: { members: true, goals: true, budgets: true } } },
    });
    return memberships.map((m) => m.familyGroup);
  }

  async getGroup(groupId: string) {
    return prisma.familyGroup.findUnique({
      where: { id: groupId },
      include: { members: true, goals: true, budgets: true },
    });
  }

  // ---------------- Members ----------------
  async addMember(groupId: string, userId: string) {
    return prisma.familyMember.upsert({
      where: { familyGroupId_userId: { familyGroupId: groupId, userId } },
      update: {},
      create: { familyGroupId: groupId, userId, role: "member" },
    });
  }

  async removeMember(groupId: string, userId: string) {
    return prisma.familyMember.deleteMany({ where: { familyGroupId: groupId, userId } });
  }

  // ---------------- Goals ----------------
  async listGoals(groupId: string) {
    return prisma.familyGoal.findMany({ where: { familyGroupId: groupId } });
  }

  async createGoal(groupId: string, data: { title: string; description?: string; targetAmount?: number; dueDate?: string }) {
    return prisma.familyGoal.create({
      data: {
        familyGroupId: groupId,
        title: data.title,
        description: data.description,
        targetAmount: data.targetAmount,
        dueDate: data.dueDate ? new Date(data.dueDate) : undefined,
      },
    });
  }

  async contributeGoal(goalId: string, amount: number) {
    return prisma.familyGoal.update({ where: { id: goalId }, data: { savedAmount: { increment: amount } } });
  }

  // ---------------- Budgets ----------------
  async listBudgets(groupId: string) {
    return prisma.familyBudget.findMany({ where: { familyGroupId: groupId } });
  }

  async createBudget(groupId: string, data: { category: string; limit: number; period: string }) {
    return prisma.familyBudget.create({ data: { familyGroupId: groupId, ...data } });
  }
}
