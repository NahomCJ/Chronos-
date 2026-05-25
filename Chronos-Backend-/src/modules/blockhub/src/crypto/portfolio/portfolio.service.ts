// ============================================================
// PortfolioService — Module 4
// Holdings tracking, weighted average price, PnL calculation.
// updateHoldings() and reduceHoldings() are called by TradingService
// INSIDE an atomic Prisma transaction.
// ============================================================

import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';
import { MarketDataService } from './market-data.service';

@Injectable()
export class PortfolioService {
  private readonly logger = new Logger(PortfolioService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly marketData: MarketDataService,
  ) {}

  // ============================================================
  // Holdings Management (called from trading service TX)
  // ============================================================

  /**
   * Updates holdings and recalculates weighted average price after BUY.
   * Must be called INSIDE a Prisma $transaction — pass the tx client.
   */
  async updateHoldings(
    tx: Prisma.TransactionClient,
    userId: string,
    asset: string,
    amountReceived: number,
    buyPrice: number,
  ): Promise<void> {
    const existing = await tx.portfolioHolding.findUnique({
      where: { userId_asset: { userId: userId, asset: asset.toUpperCase() } },
    });

    if (!existing) {
      await tx.portfolioHolding.create({
        data: {
          userId: userId,
          asset: asset.toUpperCase(),
          amount: amountReceived,
          avgPrice: buyPrice,
        },
      });
      return;
    }

    const existingAmount = Number(existing.amount);
    const existingAvgPrice = Number(existing.avgPrice);

    // Weighted average price recalculation
    const newAvgPrice =
      (existingAvgPrice * existingAmount + buyPrice * amountReceived) /
      (existingAmount + amountReceived);

    await tx.portfolioHolding.update({
      where: { userId_asset: { userId: userId, asset: asset.toUpperCase() } },
      data: {
        amount: existingAmount + amountReceived,
        avgPrice: newAvgPrice,
      },
    });
  }

  /**
   * Reduces holdings after SELL.
   * avg_price is intentionally NOT changed on sells — only amount decreases.
   * Must be called INSIDE a Prisma $transaction — pass the tx client.
   */
  async reduceHoldings(
    tx: Prisma.TransactionClient,
    userId: string,
    asset: string,
    amountSold: number,
  ): Promise<void> {
    const existing = await tx.portfolioHolding.findUnique({
      where: { userId_asset: { userId: userId, asset: asset.toUpperCase() } },
    });

    if (!existing || Number(existing.amount) < amountSold) {
      // This should have been caught by balance check earlier — log and continue
      this.logger.error(`Portfolio mismatch: user ${userId} selling ${amountSold} ${asset} but holding ${existing?.amount ?? 0}`);
    }

    await tx.portfolioHolding.update({
      where: { userId_asset: { userId: userId, asset: asset.toUpperCase() } },
      data: { amount: { decrement: amountSold } },
    });
  }

  // ============================================================
  // Portfolio Read API
  // ============================================================

  /**
   * Returns full portfolio with live PnL for all holdings.
   */
  async getPortfolio(userId: string) {
    const holdings = await this.prisma.portfolioHolding.findMany({
      where: { userId: userId },
      orderBy: { asset: 'asc' },
    });

    const prices = await this.marketData.getAllPrices();

    let totalValueUsd = 0;
    let totalPnl = 0;
    let totalCostBasis = 0;

    const enrichedHoldings = holdings.map((h) => {
      const currentPrice = prices[h.asset] ?? 0;
      const amount = Number(h.amount);
      const avgPrice = Number(h.avgPrice);

      const currentValue = amount * currentPrice;
      const unrealizedPnl = (currentPrice - avgPrice) * amount;
      const pnlPct = avgPrice > 0 ? ((currentPrice - avgPrice) / avgPrice) * 100 : 0;
      const costBasis = amount * avgPrice;

      totalValueUsd += currentValue;
      totalPnl += unrealizedPnl;
      totalCostBasis += costBasis;

      return {
        asset: h.asset,
        amount,
        avg_price: avgPrice,
        current_price: currentPrice,
        current_value: parseFloat(currentValue.toFixed(2)),
        unrealized_pnl: parseFloat(unrealizedPnl.toFixed(2)),
        pnl_pct: parseFloat(pnlPct.toFixed(2)),
      };
    });

    const totalPnlPct = totalCostBasis > 0 ? (totalPnl / totalCostBasis) * 100 : 0;

    return {
      holdings: enrichedHoldings,
      total_value_usd: parseFloat(totalValueUsd.toFixed(2)),
      total_pnl: parseFloat(totalPnl.toFixed(2)),
      total_pnl_pct: parseFloat(totalPnlPct.toFixed(2)),
    };
  }

  /**
   * Returns a single asset holding with live PnL.
   * Used for WebSocket push after trade completion.
   */
  async getHolding(userId: string, asset: string) {
    const holding = await this.prisma.portfolioHolding.findUnique({
      where: { userId_asset: { userId: userId, asset: asset.toUpperCase() } },
    });

    if (!holding) return null;

    const currentPrice = await this.marketData.getPrice(asset);
    const amount = Number(holding.amount);
    const avgPrice = Number(holding.avgPrice);
    const currentValue = amount * currentPrice;
    const pnl = (currentPrice - avgPrice) * amount;
    const pnlPct = avgPrice > 0 ? ((currentPrice - avgPrice) / avgPrice) * 100 : 0;

    return {
      asset: holding.asset,
      amount,
      current_value: parseFloat(currentValue.toFixed(2)),
      pnl: parseFloat(pnl.toFixed(2)),
      pnl_pct: parseFloat(pnlPct.toFixed(2)),
    };
  }

  // ============================================================
  // Transaction History
  // ============================================================

  async getTransactions(
    userId: string,
    page = 1,
    limit = 25,
    _type?: string,
    asset?: string,
    from?: Date,
    to?: Date,
  ) {
    const skip = (page - 1) * limit;

    const where: Prisma.TradeWhereInput = { userId: userId };
    if (asset) where.asset = asset.toUpperCase();
    if (from || to) where.createdAt = { gte: from, lte: to };

    const [trades, total] = await Promise.all([
      this.prisma.trade.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip,
      }),
      this.prisma.trade.count({ where }),
    ]);

    return {
      transactions: trades.map((t) => ({
        id: t.id,
        type: 'trade',
        side: t.side,
        asset: t.asset,
        amount_crypto: Number(t.amountCrypto),
        amount_usd: Number(t.amountUsd),
        fee: Number(t.fee),
        execution_price: Number(t.executionPrice),
        status: t.status.toLowerCase(),
        created_at: t.createdAt,
      })),
      page,
      limit,
      total,
    };
  }
}
