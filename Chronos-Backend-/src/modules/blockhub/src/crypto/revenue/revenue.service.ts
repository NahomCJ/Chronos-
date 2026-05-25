// ============================================================
// RevenueService — Module 5
// Records trading fees and spread revenue.
// MUST be called INSIDE the same DB transaction as the trade record.
// A rollback on trade also rolls back revenue — always atomic.
// ============================================================

import { Prisma } from "@prisma/client";

export interface FeeCalculation {
  feeAmount: number;
  spreadAmount: number;
  executionPrice: number; // market_price + spread
  netUsd: number;         // amount_usd - feeAmount
}

export class RevenueService {
  /**
   * Calculates trading fee and spread for a BUY order.
   * Called BEFORE Paxos order submission.
   */
  calculateBuyFees(
    amountUsd: number,
    marketPrice: number,
    feeRate: number,
    spreadRate: number,
  ): FeeCalculation {
    const feeAmount = amountUsd * feeRate;
    const spread = marketPrice * spreadRate;
    const executionPrice = marketPrice + spread;
    const netUsd = amountUsd - feeAmount;

    return { feeAmount, spreadAmount: spread, executionPrice, netUsd };
  }

  /**
   * Calculates trading fee and spread for a SELL order.
   */
  calculateSellFees(
    amountCrypto: number,
    marketPrice: number,
    feeRate: number,
    spreadRate: number,
  ): FeeCalculation & { grossUsd: number } {
    const spread = marketPrice * spreadRate;
    const executionPrice = marketPrice - spread; // lower fill price on SELL
    const grossUsd = amountCrypto * executionPrice;
    const feeAmount = grossUsd * feeRate;
    const netUsd = grossUsd - feeAmount;

    return { feeAmount, spreadAmount: spread, executionPrice, netUsd, grossUsd };
  }

  /**
   * Persists a revenue record.
   * MUST be called inside a Prisma $transaction — pass the tx client.
   */
  async record(
    tx: Prisma.TransactionClient,
    userId: string,
    tradeId: string,
    feeAmount: number,
    spreadAmount: number,
    asset: string,
  ): Promise<void> {
    await tx.revenue.createMany({
      data: [
        { userId, tradeId, type: "TRADE_FEE" as const, amount: feeAmount, asset },
        { userId, tradeId, type: "SPREAD" as const,    amount: spreadAmount, asset },
      ],
    });
  }
}

export const revenueService = new RevenueService();
