// src/modules/core-banking/fx/fx.types.ts

export type AmountType = "BUY" | "SELL";

export interface FxQuoteInput {
  fromWalletId: string;
  toWalletId: string;
  buyCurrency: string;
  sellCurrency: string;
  amount: number;       // amount user wants to buy or sell
  amountType: AmountType;
  meta?: Record<string, any>;
}

export interface FxExecuteInput {
  orderId: string;
  idempotencyKey?: string; // optional for retries
}

export interface FxQuoteOutput {
  orderId: string;
  rate: number;
  buyAmount: number;
  sellAmount: number;
  expiresAt?: Date;
  status: string;
}

export interface FxExecuteOutput {
  orderId: string;
  status: string;
}