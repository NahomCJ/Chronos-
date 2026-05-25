import prisma from "../src/config/prisma";
import bcrypt from "bcrypt";

async function main() {
  const hashedPassword = await bcrypt.hash("password123", 10);

  await prisma.user.upsert({
    where: { email: "natget21@gmail.com" },
    update: {},
    create: {
      email: "natget21@gmail.com",
      firstName: "Admin",
      middleName: "Admin",
      lastName: "Admin",
      password: hashedPassword,
    },
  });

  console.log("Seed completed");

  await prisma.exchangeRate.createMany({
  data: [
    { baseCurrency: "USD", quoteCurrency: "EUR", rate: 0.92, provider: "MockFX", createdAt: new Date() },
    { baseCurrency: "USD", quoteCurrency: "GBP", rate: 0.80, provider: "MockFX", createdAt: new Date() },
  ],
});

}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
