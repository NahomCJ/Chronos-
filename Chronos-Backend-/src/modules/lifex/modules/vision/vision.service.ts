import  prisma  from "../../../../config/prisma";

export class VisionService {

async dashboard(userId: string) {
  const [
    boards,
    goals,
    milestones,
    habits,
    mentorships,
    courses,
    communities,
    
  ] = await Promise.all([
    prisma.visionBoard.findMany({ where: { userId } }),
    prisma.longTermGoal.findMany({ where: { userId } }),
    prisma.milestone.findMany({
      where: { goal: { userId } }
    }),
    prisma.habitTracker.findMany({ where: { userId } }),
    prisma.mentorshipProgram.findMany({
      where: { status: "UPCOMING" }
    }),
   
    prisma.communityGroup.findMany(),
    prisma.notification.findMany({
      where: { userId, status: "pending" }
    })
  ]);

  return {
    visionBoards: boards,
    goals,
    milestones,
    habits,
    mentorships,
    courses,
    communities,
 
    
  };
}

  getBoards(userId: string) {
    return prisma.visionBoard.findMany({ where: { userId } });
  }

  createBoard(userId: string, data: any) {
    return prisma.visionBoard.create({
      data: { ...data, userId }
    });
  }

  getGoals(userId: string) {
    return prisma.longTermGoal.findMany({
      where: { userId },
      include: { milestones: true }
    });
  }

  createGoal(userId: string, data: any) {
    return prisma.longTermGoal.create({
      data: { ...data, userId }
    });
  }

  updateGoal(id: string, data: any) {
    return prisma.longTermGoal.update({ where: { id }, data });
  }

  getMilestones(goalId: string) {
    return prisma.milestone.findMany({ where: { goalId } });
  }

  createMilestone(data: any) {
    return prisma.milestone.create({ data });
  }

  updateMilestone(id: string, data: any) {
    return prisma.milestone.update({ where: { id }, data });
  }

  getHabits(userId: string) {
    return prisma.habitTracker.findMany({ where: { userId } });
  }

  createHabit(userId: string, data: any) {
    return prisma.habitTracker.create({
      data: { ...data, userId }
    });
  }

  updateHabit(id: string, data: any) {
    return prisma.habitTracker.update({ where: { id }, data });
  }

  getMentorships() {
    return prisma.mentorshipProgram.findMany();
  }

  getCourses() {
    return prisma.course.findMany();
  }

  getCommunities() {
    return prisma.communityGroup.findMany();
  }
}
