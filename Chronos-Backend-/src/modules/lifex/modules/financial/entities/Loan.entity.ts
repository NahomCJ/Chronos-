export interface LoanEntity {
  id: string;
  principalAmount: number;
  outstandingAmount: number;
  interestRate: number;
  dueDate: Date;
  status: string;
}
