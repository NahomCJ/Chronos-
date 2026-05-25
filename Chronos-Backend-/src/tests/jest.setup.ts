import  prisma from "../config/prisma";

beforeEach(async () => {
  // Delete all users before each test
  await prisma.user.deleteMany();
});

afterAll(async () => {
  await prisma.$disconnect();
});
