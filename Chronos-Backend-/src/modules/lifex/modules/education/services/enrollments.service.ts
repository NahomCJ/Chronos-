import prisma from "../models/prisma";
export const enrollUser = async ({ userId, courseId, autoEnrollExternal = false }: { userId: string; courseId: string; autoEnrollExternal?: boolean }) => {
const course = await prisma.course.findUnique({ where: { id: courseId } });
if (!course) throw new Error("Course not found");


const enrollment = await prisma.enrollment.create({
data: {
userId,
courseId,
status: autoEnrollExternal ? "IN_PROGRESS" : "PLANNED",
startedAt: autoEnrollExternal ? new Date() : null,
},
});


return enrollment;
};


export const listUserEnrollments = (userId: string) =>
prisma.enrollment.findMany({ where: { userId }, include: { course: true } });


export const updateProgress = async (enrollmentId: string, progress: number) => {
const data: any = { progress };
if (progress >= 100) {
data.status = "COMPLETED";
data.completedAt = new Date();
}
return prisma.enrollment.update({ where: { id: enrollmentId }, data });
};