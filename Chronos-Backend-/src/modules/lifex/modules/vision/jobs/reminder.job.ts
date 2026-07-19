import cron from "node-cron";
import  prisma  from "../../../../../config/prisma";

cron.schedule("0 9 * * *", async () => {
  const milestones = await prisma.milestone.findMany({
    where: { status: "PENDING" }
  });

  console.log("Reminder job ran:", milestones.length);
});
