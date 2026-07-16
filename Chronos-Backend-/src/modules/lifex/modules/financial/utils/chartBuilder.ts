export function buildPlannedVsActualChart(plans: any[], transactions: any[]) {
  const planned = plans.reduce((s, p) => s + Number(p.targetAmount), 0);
  const actualSavings = plans.reduce((s, p) => s + Number(p.savedAmount), 0);
  const actualExpenses = transactions.reduce((s, t) => s + Number(t.amount), 0);

  return {
    labels: ['Savings', 'Expenses'],
    planned: [planned, actualExpenses],
    actual: [actualSavings, actualExpenses]
  };
}
