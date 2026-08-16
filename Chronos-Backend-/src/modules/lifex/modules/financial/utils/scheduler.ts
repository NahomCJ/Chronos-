import cron from 'node-cron';
import prisma from '../../../../../config/prisma';

/* ---------- AUTO SAVINGS ---------- */
cron.schedule('0 0 * * *', async () => {
  // Single batched UPDATE instead of one per active plan (was also writing a
  // no-op increment:0 to every non-daily plan).
  await prisma.financialPlan.updateMany({
    where: { status: 'ACTIVE', frequency: 'DAILY' },
    data: {
      savedAmount: { increment: 10 }, // demo logic
    },
  });
});

/* ---------- LOAN REMINDERS ---------- */
cron.schedule('0 9 * * *', async () => {
  const upcoming = await prisma.loan.findMany({
    where: {
      dueDate: {
        lte: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
      },
      status: 'ACTIVE',
    },
  });

  upcoming.forEach(loan => {
    console.log(`Reminder: Loan ${loan.id} is due soon`);
  });
});

/* ---------- INVESTMENT REFRESH ---------- */
cron.schedule('0 1 * * *', async () => {
  console.log('Refreshing investment advice...');
});

/* ---------- CREDIT SCORE POLLING ---------- */
cron.schedule('0 2 * * 1', async () => {
  console.log('Polling credit bureau API...');
});
