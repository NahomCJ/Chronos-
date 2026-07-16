export function buildMonthlySheet(
  transactions: any[],
  plans: any[],
  budgets: any[],
  loans: any[]
) {
  const sheet: any = {
    totals: {
      savingsPlanned: 0,
      savingsActual: 0,
      expenseActual: 0,
      billActual: 0,
      debtActual: 0,
    },
    savings: [],
    expenses: [],
    bills: [],
    debt: [],
  };

  // --------- Savings ---------
  for (const plan of plans) {
    const planned = Number(plan.targetAmount);
    const actual = Number(plan.savedAmount);

    sheet.savings.push({
      name: plan.goalName,
      planned,
      actual,
      progress: planned ? (actual / planned) * 100 : 0,
    });

    sheet.totals.savingsPlanned += planned;
    sheet.totals.savingsActual += actual;
  }

  // --------- Expenses & Bills ---------
  const expenseMap: Record<string, number> = {};
  const billMap: Record<string, number> = {};

  for (const tx of transactions) {
    const amount = Number(tx.amount);
    const isBill = tx.metadata?.isBill === true || tx.metadata?.isBill === "true";
    const isLoanRepayment = tx.category === "LOAN_REPAYMENT";

    // Skip loan repayments — handled in debt
    if (isLoanRepayment) continue;

    if (isBill) {
      billMap[tx.category] = (billMap[tx.category] || 0) + amount;
      sheet.totals.billActual += amount;
    } else {
      expenseMap[tx.category] = (expenseMap[tx.category] || 0) + amount;
      sheet.totals.expenseActual += amount;
    }
  }

  // Push aggregated expenses
  sheet.expenses = Object.entries(expenseMap).map(([category, actual]) => {
    const planned = budgets.find(b => b.category === category)?.limit || 0;
    return {
      category,
      planned,
      actual,
      progress: planned ? (actual / planned) * 100 : 0,
    };
  });

  // Push aggregated bills
  sheet.bills = Object.entries(billMap).map(([category, actual]) => {
    const planned = budgets.find(b => b.category === category)?.limit || 0;
    return {
      category,
      planned,
      actual,
      progress: planned ? (actual / planned) * 100 : 0,
    };
  });

  // --------- Debt from loans ---------
  for (const loan of loans) {
    const planned = Number(loan.principalAmount);
    const actual = planned - Number(loan.outstandingAmount);

    sheet.debt.push({
      category: loan.name || loan.id, // friendly name if exists
      planned,
      actual,
      progress: planned ? (actual / planned) * 100 : 0,
    });

    sheet.totals.debtActual += actual;
  }

  return sheet;
}
