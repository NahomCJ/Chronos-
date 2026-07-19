import cron from 'node-cron';
import prisma from '../../../../../config/prisma';

/* ---------- AUTO SAVINGS ---------- */
cron.schedule('0 0 * * *', async () => {
  const plans = await prisma.financialPlan.findMany({
    where: { status: 'ACTIVE' },
  });

  for (const plan of plans) {
    await prisma.financialPlan.update({
      where: { id: plan.id },
      data: {
        savedAmount: {
          increment: String(plan.frequency).toLowerCase() === 'daily' ? 10 : 0, // demo logic
        },
      },
    });
  }
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
