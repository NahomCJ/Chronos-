// ============================================================
// Stocks & ETFs — paper trading.
// No live brokerage is connected (see root CLAUDE.md), so orders never
// leave this database: buys/sells move real cash between the user's own
// USD wallet ledger and a DB-backed StockHolding position, priced with
// live market data (stocks.market-data.ts). Mirrors the crypto module's
// PortfolioHolding pattern (src/modules/crypto/services/crypto.service.ts)
// but settles internally instead of through Paxos.
// ============================================================

import prisma from "../../../config/prisma";
import { StocksApiError } from "./stocks.errors";
import {
  SUPPORTED_STOCKS,
  getAllQuotes,
  getQuote,
  getQuotes,
  isSupportedSymbol,
} from "./stocks.market-data";

async function getPrimaryWallet(userId: string) {
  const account = await prisma.account.findFirst({
    where: { userId },
    include: {
      wallets: {
        where: { status: "ACTIVE", currency: "USD", type: "FIAT" },
        include: { ledger: { select: { direction: true, amount: true } } },
      },
    },
  });

  const wallet = account?.wallets[0];
  if (!wallet) {
    throw new StocksApiError(
      "NO_WALLET",
      "No active USD wallet found for this account.",
      400,
    );
  }

  const balance = wallet.ledger.reduce((sum, e) => {
    const amt = parseFloat(e.amount.toString());
    return e.direction === "CREDIT" ? sum + amt : sum - amt;
  }, 0);

  return { walletId: wallet.id, balance };
}

function requireSupportedSymbol(symbol: string): string {
  if (!isSupportedSymbol(symbol)) {
    throw new StocksApiError(
      "UNSUPPORTED_SYMBOL",
      `${symbol.toUpperCase()} is not a supported stock/ETF.`,
      400,
    );
  }
  return symbol.toUpperCase();
}

function requirePositiveShares(shares: unknown): number {
  if (typeof shares !== "number" || !Number.isFinite(shares) || shares <= 0) {
    throw new StocksApiError("INVALID_SHARES", "Shares must be a positive number.", 400);
  }
  return shares;
}

export async function listSupportedStocks() {
  const quotes = await getAllQuotes();
  return SUPPORTED_STOCKS.map((s) => ({
    symbol: s.symbol,
    name: s.name,
    kind: s.kind,
    price: quotes[s.symbol]?.price ?? null,
    changePct: quotes[s.symbol]?.changePct ?? null,
  }));
}

export async function getQuoteForSymbol(symbol: string) {
  const upper = requireSupportedSymbol(symbol);
  return getQuote(upper);
}

export async function getPortfolio(userId: string) {
  const holdings = await prisma.stockHolding.findMany({
    where: { userId },
    orderBy: { symbol: "asc" },
  });

  if (holdings.length === 0) {
    return { holdings: [], total_value_usd: 0, total_pnl: 0, total_pnl_pct: 0 };
  }

  const prices = await getQuotes(holdings.map((h) => h.symbol));

  let totalValueUsd = 0;
  let totalPnl = 0;
  let totalCostBasis = 0;

  const enriched = holdings.map((h) => {
    const shares = Number(h.shares);
    const avgPrice = Number(h.avgPrice);
    const currentPrice = prices[h.symbol]?.price ?? avgPrice;
    const currentValue = shares * currentPrice;
    const costBasis = shares * avgPrice;
    const pnl = currentValue - costBasis;
    const pnlPct = costBasis > 0 ? (pnl / costBasis) * 100 : 0;

    totalValueUsd += currentValue;
    totalPnl += pnl;
    totalCostBasis += costBasis;

    return {
      symbol: h.symbol,
      shares,
      avg_price: parseFloat(avgPrice.toFixed(4)),
      current_price: parseFloat(currentPrice.toFixed(4)),
      current_value: parseFloat(currentValue.toFixed(2)),
      unrealized_pnl: parseFloat(pnl.toFixed(2)),
      pnl_pct: parseFloat(pnlPct.toFixed(2)),
    };
  });

  return {
    holdings: enriched,
    total_value_usd: parseFloat(totalValueUsd.toFixed(2)),
    total_pnl: parseFloat(totalPnl.toFixed(2)),
    total_pnl_pct: totalCostBasis > 0 ? parseFloat(((totalPnl / totalCostBasis) * 100).toFixed(2)) : 0,
  };
}

/** Lightweight accessor for other modules (home net-worth, AI portfolio context). */
export async function getPortfolioValueUsd(userId: string): Promise<number> {
  const { total_value_usd } = await getPortfolio(userId);
  return total_value_usd;
}

export async function buyStock(userId: string, symbolInput: string, sharesInput: number) {
  const symbol = requireSupportedSymbol(symbolInput);
  const shares = requirePositiveShares(sharesInput);

  const quote = await getQuote(symbol);
  const amountUsd = shares * quote.price;

  const { walletId, balance } = await getPrimaryWallet(userId);
  if (balance < amountUsd) {
    throw new StocksApiError(
      "INSUFFICIENT_FUNDS",
      "Insufficient balance to complete this purchase.",
      400,
    );
  }

  const reference = `STK-${Date.now()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;

  const order = await prisma.$transaction(async (tx) => {
    const txn = await tx.coreTransaction.create({
      data: {
        userId,
        type: "PURCHASE",
        status: "COMPLETED",
        reference,
        metadata: { kind: "STOCK_BUY", symbol, shares, price: quote.price },
      },
    });

    await tx.ledgerEntry.create({
      data: {
        transactionId: txn.id,
        walletId,
        direction: "DEBIT",
        category: "INVESTMENT",
        amount: amountUsd,
        currency: "USD",
        reference,
      },
    });

    const existing = await tx.stockHolding.findUnique({
      where: { userId_symbol: { userId, symbol } },
    });

    if (existing) {
      const existingShares = Number(existing.shares);
      const existingAvg = Number(existing.avgPrice);
      const newAvgPrice =
        (existingAvg * existingShares + quote.price * shares) / (existingShares + shares);
      await tx.stockHolding.update({
        where: { userId_symbol: { userId, symbol } },
        data: { shares: existingShares + shares, avgPrice: newAvgPrice },
      });
    } else {
      await tx.stockHolding.create({
        data: { userId, symbol, shares, avgPrice: quote.price },
      });
    }

    return tx.stockOrder.create({
      data: { userId, symbol, side: "BUY", shares, price: quote.price, amountUsd, status: "COMPLETED" },
    });
  });

  return {
    orderId: order.id,
    symbol,
    side: "BUY" as const,
    shares,
    price: quote.price,
    amountUsd: parseFloat(amountUsd.toFixed(2)),
  };
}

export async function sellStock(userId: string, symbolInput: string, sharesInput: number) {
  const symbol = requireSupportedSymbol(symbolInput);
  const shares = requirePositiveShares(sharesInput);

  const holding = await prisma.stockHolding.findUnique({
    where: { userId_symbol: { userId, symbol } },
  });
  if (!holding || Number(holding.shares) < shares) {
    throw new StocksApiError(
      "INSUFFICIENT_SHARES",
      "You do not own enough shares to sell.",
      400,
    );
  }

  const quote = await getQuote(symbol);
  const amountUsd = shares * quote.price;
  const { walletId } = await getPrimaryWallet(userId);
  const reference = `STK-${Date.now()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;

  const order = await prisma.$transaction(async (tx) => {
    const txn = await tx.coreTransaction.create({
      data: {
        userId,
        type: "INVESTMENT_SALE",
        status: "COMPLETED",
        reference,
        metadata: { kind: "STOCK_SELL", symbol, shares, price: quote.price },
      },
    });

    await tx.ledgerEntry.create({
      data: {
        transactionId: txn.id,
        walletId,
        direction: "CREDIT",
        category: "INVESTMENT",
        amount: amountUsd,
        currency: "USD",
        reference,
      },
    });

    const remaining = Number(holding.shares) - shares;
    if (remaining <= 0) {
      await tx.stockHolding.delete({ where: { userId_symbol: { userId, symbol } } });
    } else {
      await tx.stockHolding.update({
        where: { userId_symbol: { userId, symbol } },
        data: { shares: remaining },
      });
    }

    return tx.stockOrder.create({
      data: { userId, symbol, side: "SELL", shares, price: quote.price, amountUsd, status: "COMPLETED" },
    });
  });

  return {
    orderId: order.id,
    symbol,
    side: "SELL" as const,
    shares,
    price: quote.price,
    amountUsd: parseFloat(amountUsd.toFixed(2)),
  };
}

export async function getOrders(userId: string, limit = 25) {
  const orders = await prisma.stockOrder.findMany({
    where: { userId },
    orderBy: { createdAt: "desc" },
    take: Math.min(limit, 100),
  });

  return orders.map((o) => ({
    id: o.id,
    symbol: o.symbol,
    side: o.side,
    shares: Number(o.shares),
    price: Number(o.price),
    amountUsd: Number(o.amountUsd),
    status: o.status,
    createdAt: o.createdAt.toISOString(),
  }));
}
