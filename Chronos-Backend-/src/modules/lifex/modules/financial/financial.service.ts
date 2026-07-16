import prisma from '../../../../config/prisma';
import { buildMonthlySheet } from './utils/monthlySheet';
import { buildPlannedVsActualChart } from './utils/chartBuilder';
import { CreateBudgetDto } from './dto/createBudget.dto';
import { generateCSV, generatePDF } from './utils/taxReport';
import './utils/scheduler';
import { LoanStatus } from '@prisma/client';




export class FinancialService {

  /* ---------------- DASHBOARD ---------------- */

  async overview(userId: string) {
    const [plans, loans, transactions] = await Promise.all([
      prisma.financialPlan.findMany({ where: { userId } }),
      prisma.loan.findMany({ where: { userId } }),
      prisma.transaction.findMany({ where: { userId } }),
    ]);

    return {
      totalSavings: plans.reduce((s, p) => s + Number(p.savedAmount), 0),
      activeLoans: loans.filter(l => l.status === 'ACTIVE').length,
      totalExpenses: transactions
        .filter(t => t.type === 'EXPENSE')
        .reduce((s, t) => s + Number(t.amount), 0),
    };
  }

  /* ---------------- SAVINGS ---------------- */

  async createSavings(userId: string, data: any) {
    return prisma.financialPlan.create({
      data: {
        userId,
        goalName: data.name, 
        targetAmount: data.targetAmount,
        savedAmount: data.savedAmount,
        frequency: data.frequency ?? 'MONTHLY',
      },
    });
  }

  async listSavings(userId: string) {
    return prisma.financialPlan.findMany({ where: { userId } });
  }

  /* ---------------- BUDGET ---------------- */

  async createBudget(userId: string, data: CreateBudgetDto) {
    return prisma.budget.create({
      data: {
        userId,
        category: data.category,
        limit: data.limit,
        period: new Date().toISOString().slice(0, 7), // YYYY-MM
      },
    });
  }

  async listBudgets(userId: string) {
    return prisma.budget.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  /* ---------------- LOANS ---------------- */

  async listLoans(userId: string) {
  return prisma.loan.findMany({
    where: { userId },
    orderBy: { dueDate: 'asc' },
  });
}

async createLoan(userId: string, data: {
  name: string;             // friendly loan name
  principalAmount: number;
  interestRate: number;
  dueDate: string;
}) {
  const { name, principalAmount, interestRate, dueDate } = data;

  if (!name || name.trim() === "") {
    throw new Error("Loan name is required");
  }

  if (principalAmount <= 0) {
    throw new Error("Invalid principal amount");
  }

  return prisma.loan.create({
    data: {
      userId,
      name: name.trim(),             // store friendly name
      principalAmount,
      outstandingAmount: principalAmount, // initially full principal
      interestRate,
      dueDate: new Date(dueDate),
      status: "ACTIVE",
    },
  });
}


async payLoan(userId: string, loanId: string, amount: number) {
  return prisma.$transaction(async (tx) => {
    console.log("Pay loan attempt:", { userId, loanId, amount });

    // Step 1: Find loan by ID
    const loan = await tx.loan.findUnique({
      where: { id: loanId },
    });

    // Step 2: Check loan exists and belongs to the user
    if (!loan) {
      console.error("Loan not found with ID:", loanId);
      throw new Error("Loan not found");
    }
    if (loan.userId !== userId) {
      console.error("Loan does not belong to user:", userId);
      throw new Error("Loan not found for this user");
    }

    // Step 3: Validate payment amount
    if (amount <= 0) {
      throw new Error("Invalid payment amount");
    }
    if (amount > Number(loan.outstandingAmount)) {
      throw new Error("Payment exceeds outstanding balance");
    }

    // Step 4: Calculate remaining balance
    const remaining = Number(loan.outstandingAmount) - amount;

    // Step 5: Update loan
    const updatedLoan = await tx.loan.update({
      where: { id: loan.id },
      data: {
        outstandingAmount: remaining,
        status: remaining === 0 ? "PAID" : "ACTIVE",
      },
    });

    console.log("Loan updated:", updatedLoan);

    // Step 6: Record transaction
    await tx.transaction.create({
  data: {
    userId,
    accountId: loan.id,
    type: "EXPENSE",
    category: "LOAN_REPAYMENT",
    amount,
    currency: "ETB",
    metadata: {
      loanId: loan.id,
      loanName: loan.name,      // <-- add friendly name
      remainingBalance: remaining,
      paidAt: new Date(),
    },
  },
});


    console.log("Payment transaction recorded for loan:", loan.id);

    return updatedLoan;
  });
}



  /* ---------------- INVESTMENT ---------------- */

  async investmentAdvice(userId: string) {
    return prisma.investmentAdvice.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  /* ---------------- CREDIT SCORE ---------------- */

  async creditScore(userId: string) {
    return prisma.creditScore.findFirst({
      where: { userId },
      orderBy: { checkedAt: 'desc' },
    });
  }

  /* ---------------- ANALYTICS ---------------- */

async monthlyBudget(userId: string, period?: string) {
  const effectivePeriod = period ?? new Date().toISOString().slice(0, 7);
  const start = new Date(`${effectivePeriod}-01`);
  const end = new Date(start);
  end.setMonth(end.getMonth() + 1);

  // Fetch all data including loans
  const [plans, budgets, transactions, loans] = await Promise.all([
    prisma.financialPlan.findMany({ where: { userId } }),
    prisma.budget.findMany({ where: { userId, period: effectivePeriod } }),
    prisma.transaction.findMany({
      where: { userId, createdAt: { gte: start, lt: end } },
    }),
    prisma.loan.findMany({ where: { userId } }), // fetch loans
  ]);

  return buildMonthlySheet(transactions, plans, budgets, loans);
}





  async plannedVsActualChart(userId: string, period: string) {
    const plans = await prisma.budget.findMany({ where: { userId } });
    const transactions = await prisma.transaction.findMany({ where: { userId } });

    return buildPlannedVsActualChart(plans, transactions);
  }

  /* ---------------- TAX REPORT ---------------- */
  async taxReport(userId: string, format: 'csv' | 'pdf') {
  const transactions = await prisma.transaction.findMany({
    where: { userId },
    orderBy: { createdAt: 'asc' },
  });

  if (format === 'csv') {
    return {
      type: 'csv',
      data: generateCSV(transactions),
    };
  }

  const pdfPath = await generatePDF(transactions);
  return {
    type: 'pdf',
    path: pdfPath,
  };
}


async createExpense(
  userId: string,
  data: {
    amount: number;
    category: string;
    isBill?: boolean;
    note?: string;
  }
) {
  if (data.amount <= 0) {
    throw new Error("Invalid amount");
  }

  return prisma.transaction.create({
    data: {
      userId,
      accountId: "DEFAULT",
      type: "EXPENSE",
      category: data.category.toUpperCase(),
      amount: data.amount,
      currency: "ETB",
      metadata: {
        isBill: data.isBill ?? false,
        note: data.note ?? null,
      },
    },
  });
}


}
