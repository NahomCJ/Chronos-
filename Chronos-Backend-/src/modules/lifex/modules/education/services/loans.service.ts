import prisma from "../models/prisma";


export const linkLoanManual = (data: any) => prisma.studentLoan.create({ data });


export const listLoansForUser = (userId: string) => prisma.studentLoan.findMany({ where: { userId } });


export const recordRepayment = async (loanId: string, amount: number) => {
const loan = await prisma.studentLoan.findUnique({ where: { id: loanId } });
if (!loan) throw new Error("Loan not found");
const outstanding = Number(loan.outstanding) - amount;
const status = outstanding <= 0 ? "PAID" : loan.status;
return prisma.studentLoan.update({ where: { id: loanId }, data: { outstanding: outstanding < 0 ? 0 : outstanding, status, updatedAt: new Date() } });
};


export const getAmortizationSchedule = (loanId: string) => ({ message: "Implement amortization calculation" });