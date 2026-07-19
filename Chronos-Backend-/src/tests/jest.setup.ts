import prisma from "../config/prisma";

const shouldUseDatabase =
  process.env.SKIP_DB_TEST_SETUP !== "true" && Boolean(process.env.DATABASE_URL);

if (shouldUseDatabase) {
  beforeEach(async () => {
    // Delete all users before each test
    await prisma.user.deleteMany();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });
}
