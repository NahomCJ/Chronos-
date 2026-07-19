import prisma from "../models/prisma";


export const listTutors = async (filter: any = {}) => {
const where: any = {};
if (filter.subject) where.subjects = { has: filter.subject };
if (filter.minRating) where.rating = { gte: filter.minRating };
return prisma.tutor.findMany({ where });
};


export const getTutor = (id: string) => prisma.tutor.findUnique({ where: { id } });


export const createTutor = (payload: any) => prisma.tutor.create({ data: payload });


export const scheduleSession = async (tutorId: string, userId: string, scheduledAt: Date, durationMinutes: number) => {
const session = await prisma.tutorSession.create({
data: {
tutorId,
userId,
scheduledAt,
durationMinutes,
status: "SCHEDULED",
},
});
return session;
};


export const getUserSessions = (userId: string) => prisma.tutorSession.findMany({ where: { userId }, include: { tutor: true } });