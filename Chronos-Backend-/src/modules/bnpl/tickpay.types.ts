export type TickPayAccountStatus = "ACTIVE" | "SUSPENDED" | "CLOSED";
export type TickPayTransactionType = "PURCHASE" | "REPAYMENT" | "REFUND";
export type TickPayTransactionStatus = "PENDING" | "COMPLETED" | "FAILED";
export type TickPayFeeStatus = "SCHEDULED" | "DUE" | "PAID" | "WAIVED" | "CANCELED";

export interface CreatePurchaseInput {
  amount: number;
  currency?: string;
  merchant?: string;
  meta?: Record<string, any>;
}

export interface CreateRepaymentInput {
  amount: number;
  currency?: string;
  source?: "AKOYA" | "MORALIS" | "MANUAL";
  meta?: Record<string, any>;
}
