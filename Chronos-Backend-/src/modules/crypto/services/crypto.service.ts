import Decimal from "decimal.js";
import { randomUUID } from "crypto";
import { Prisma } from "@prisma/client";
import prisma from "../../../models/prisma";
import audit from "./crypto.audit.service";
import paxos, {
  MarketPrice,
  PaxosOrder,
  SUPPORTED_CRYPTO_ASSETS,
  SupportedCryptoAsset,
} from "./crypto.paxos.service";
import { CryptoApiError } from "./crypto.errors";
import { BuyRequest, HistoryQuery, SellRequest } from "./crypto.validation";

type TxClient = Prisma.TransactionClient;

const DEFAULT_FEE_RATE = 0.005;
const DEFAULT_SPREAD_RATE = 0.002;

interface NormalizedOrderFill {
  fillPrice?: Decimal;
  baseAmount?: Decimal;
  quoteAmount?: Decimal;
  filledAt?: Date;
}

interface CryptoWalletRecord {
  id: string;
  paxosCustomerId: string;
  paxosWalletId: string;
  createdAt: Date;
}

export class CryptoService {
  async getDashboard(userId: string) {
    const lazyProvision = await this.tryLazyProvisionWallet(userId);
    const wallet = await prisma.cryptoWallet.findUnique({ where: { userId } });
    const prices = await paxos.getAllMarketPrices();
    const holdings = await this.getPortfolio(userId, prices);

    let balances: Array<{ asset: string; available: number; trading?: number }> = [];
    let transfersAvailable = false;
    if (wallet && paxos.isConfigured()) {
      balances = (await paxos.getBalances(wallet.paxosWalletId)).map((item) => ({
        asset: item.asset,
        available: Number(item.available),
        trading: item.trading === undefined ? undefined : Number(item.trading),
      }));
      transfersAvailable = true;
    }

    return {
      paxos: {
        configured: paxos.isConfigured(),
        environment: process.env.PAXOS_ENV || process.env.NODE_ENV || "sandbox",
      },
      wallet: wallet
        ? {
            status: "ready",
            id: wallet.id,
            paxosCustomerId: wallet.paxosCustomerId,
            paxosWalletId: wallet.paxosWalletId,
            createdAt: wallet.createdAt,
          }
        : {
            status: lazyProvision.status,
            error: lazyProvision.error,
          },
      supported_assets: SUPPORTED_CRYPTO_ASSETS,
      balances,
      transfers_available: transfersAvailable,
      portfolio: holdings,
      prices: Object.fromEntries(
        Object.values(prices).map((price) => [
          price.asset,
          {
            price: price.price,
            source: price.source,
            updated_at: price.updated_at,
          },
        ]),
      ),
    };
  }

  async buy(userId: string, input: BuyRequest) {
    const asset = paxos.normalizeAsset(input.asset);
    const amountUsd = new Decimal(input.amount_usd);
    const tradeId = randomUUID();

    await this.assertPaxosTradingReady();
    const wallet = await this.assertTradeAllowed(userId, amountUsd);

    const usdBalance = await paxos.getBalance(wallet.paxosWalletId, "USD");
    if (new Decimal(usdBalance).lt(amountUsd)) {
      throw new CryptoApiError(
        "INSUFFICIENT_BALANCE",
        `Insufficient USD balance. Available: $${usdBalance.toFixed(2)}`,
        422,
      );
    }

    const market = await paxos.getMarketPrice(asset);
    const fees = this.calculateBuyFees(amountUsd, market.price);

    let order: PaxosOrder;
    try {
      order = await paxos.placeOrder({
        profileId: wallet.paxosWalletId,
        side: "BUY",
        asset,
        quoteAmount: fees.netUsd.toFixed(2),
        clientOrderId: tradeId,
      });
      order = await paxos.pollOrderUntilTerminal(wallet.paxosWalletId, order.id);
    } catch (err) {
      await audit.log({
        action: `BUY_${asset}_FAILED`,
        userId,
        amount: amountUsd.toNumber(),
        asset,
        metadata: this.errorMetadata(err, { tradeId }),
      });
      throw err;
    }

    const fill = this.normalizeOrderFill(order);
    const fillPrice = fill.fillPrice || fees.executionPrice;
    const cryptoReceived = fill.baseAmount || fees.netUsd.div(fillPrice);
    const quoteAmount = fill.quoteAmount || fees.netUsd;
    const spreadRevenue = fees.spreadPerUnit.mul(cryptoReceived);

    await prisma.$transaction(async (tx) => {
      const trade = await tx.trade.create({
        data: {
          id: tradeId,
          userId,
          asset,
          side: "BUY",
          amountUsd: amountUsd.toFixed(2),
          amountCrypto: cryptoReceived.toFixed(8),
          fee: fees.feeAmount.toFixed(2),
          executionPrice: fillPrice.toFixed(2),
          paxosOrderId: order.id,
          status: "FILLED",
          filledAt: fill.filledAt || new Date(),
        },
      });

      await this.increaseHolding(tx, userId, asset, cryptoReceived, fillPrice);
      await this.recordRevenue(tx, userId, trade.id, fees.feeAmount, spreadRevenue, asset);
    });

    await audit.log({
      action: `BUY_${asset}`,
      userId,
      amount: amountUsd.toNumber(),
      asset,
      metadata: {
        trade_id: tradeId,
        paxos_order_id: order.id,
        quote_amount: quoteAmount.toFixed(2),
        fee: fees.feeAmount.toFixed(2),
        spread_revenue: spreadRevenue.toFixed(2),
        crypto_received: cryptoReceived.toFixed(8),
        execution_price: fillPrice.toFixed(2),
      },
    });

    return {
      trade_id: tradeId,
      asset,
      amount_usd: amountUsd.toNumber(),
      fee: fees.feeAmount.toDecimalPlaces(2).toNumber(),
      crypto_received: cryptoReceived.toDecimalPlaces(8).toNumber(),
      execution_price: fillPrice.toDecimalPlaces(2).toNumber(),
      paxos_order_id: order.id,
      status: "filled",
      filled_at: fill.filledAt || new Date(),
    };
  }

  async sell(userId: string, input: SellRequest) {
    const asset = paxos.normalizeAsset(input.asset);
    const amountCrypto = new Decimal(input.amount_crypto);
    const tradeId = randomUUID();

    await this.assertPaxosTradingReady();
    const market = await paxos.getMarketPrice(asset);
    const fees = this.calculateSellFees(amountCrypto, market.price);
    const wallet = await this.assertTradeAllowed(userId, fees.grossUsd);

    const cryptoBalance = await paxos.getBalance(wallet.paxosWalletId, asset);
    if (new Decimal(cryptoBalance).lt(amountCrypto)) {
      throw new CryptoApiError(
        "INSUFFICIENT_CRYPTO_BALANCE",
        `Insufficient ${asset} balance. Available: ${cryptoBalance}`,
        422,
      );
    }

    let order: PaxosOrder;
    try {
      order = await paxos.placeOrder({
        profileId: wallet.paxosWalletId,
        side: "SELL",
        asset,
        baseAmount: amountCrypto.toFixed(8),
        clientOrderId: tradeId,
      });
      order = await paxos.pollOrderUntilTerminal(wallet.paxosWalletId, order.id);
    } catch (err) {
      await audit.log({
        action: `SELL_${asset}_FAILED`,
        userId,
        amount: fees.grossUsd.toNumber(),
        asset,
        metadata: this.errorMetadata(err, { tradeId }),
      });
      throw err;
    }

    const fill = this.normalizeOrderFill(order);
    const fillPrice = fill.fillPrice || fees.executionPrice;
    const grossUsd = fill.quoteAmount || amountCrypto.mul(fillPrice);
    const feeAmount = grossUsd.mul(this.feeRate);
    const netUsd = grossUsd.minus(feeAmount);
    const spreadRevenue = fees.spreadPerUnit.mul(amountCrypto);

    await prisma.$transaction(async (tx) => {
      const trade = await tx.trade.create({
        data: {
          id: tradeId,
          userId,
          asset,
          side: "SELL",
          amountUsd: grossUsd.toFixed(2),
          amountCrypto: amountCrypto.toFixed(8),
          fee: feeAmount.toFixed(2),
          executionPrice: fillPrice.toFixed(2),
          paxosOrderId: order.id,
          status: "FILLED",
          filledAt: fill.filledAt || new Date(),
        },
      });

      await this.decreaseHolding(tx, userId, asset, amountCrypto);
      await this.recordRevenue(tx, userId, trade.id, feeAmount, spreadRevenue, asset);
    });

    await audit.log({
      action: `SELL_${asset}`,
      userId,
      amount: grossUsd.toNumber(),
      asset,
      metadata: {
        trade_id: tradeId,
        paxos_order_id: order.id,
        amount_crypto: amountCrypto.toFixed(8),
        gross_usd: grossUsd.toFixed(2),
        fee: feeAmount.toFixed(2),
        net_usd: netUsd.toFixed(2),
        execution_price: fillPrice.toFixed(2),
      },
    });

    return {
      trade_id: tradeId,
      asset,
      amount_crypto: amountCrypto.toDecimalPlaces(8).toNumber(),
      gross_usd: grossUsd.toDecimalPlaces(2).toNumber(),
      fee: feeAmount.toDecimalPlaces(2).toNumber(),
      net_usd: netUsd.toDecimalPlaces(2).toNumber(),
      execution_price: fillPrice.toDecimalPlaces(2).toNumber(),
      paxos_order_id: order.id,
      status: "filled",
      filled_at: fill.filledAt || new Date(),
    };
  }

  async getHistory(userId: string, query: HistoryQuery) {
    const where: Prisma.TradeWhereInput = { userId };
    if (query.asset) where.asset = query.asset;
    if (query.from || query.to) {
      where.createdAt = {
        ...(query.from && { gte: query.from }),
        ...(query.to && { lte: query.to }),
      };
    }

    const skip = (query.page - 1) * query.limit;
    const [trades, total, wallet] = await Promise.all([
      prisma.trade.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip,
        take: query.limit,
      }),
      prisma.trade.count({ where }),
      prisma.cryptoWallet.findUnique({ where: { userId } }),
    ]);

    let transfers: unknown[] = [];
    let nextTransferCursor: string | undefined;
    if (wallet && paxos.isConfigured()) {
      const transferResponse = await paxos.listTransfers(wallet.paxosWalletId, query.limit, query.cursor);
      transfers = transferResponse.items || [];
      nextTransferCursor = transferResponse.next_page_cursor;
    }

    return {
      page: query.page,
      limit: query.limit,
      total,
      transactions: trades.map((trade) => ({
        id: trade.id,
        type: "trade",
        side: trade.side,
        asset: trade.asset,
        amount_usd: Number(trade.amountUsd),
        amount_crypto: Number(trade.amountCrypto),
        fee: Number(trade.fee),
        execution_price: Number(trade.executionPrice),
        paxos_order_id: trade.paxosOrderId,
        status: trade.status.toLowerCase(),
        created_at: trade.createdAt,
        filled_at: trade.filledAt,
      })),
      transfers,
      next_transfer_cursor: nextTransferCursor,
    };
  }

  async getPrice(asset: string) {
    const price = await paxos.getMarketPrice(asset);
    return {
      asset: price.asset,
      market: price.market,
      price: price.price,
      source: price.source,
      updated_at: price.updated_at,
    };
  }

  async provisionAccount(userId: string) {
    const existing = await prisma.cryptoWallet.findUnique({ where: { userId } });
    if (existing) {
      return {
        created: false,
        paxos: this.paxosStatus(),
        wallet: this.publicWallet(existing),
      };
    }

    paxos.assertConfigured();
    await this.assertCryptoAccountProvisionAllowed(userId);

    const wallet = await this.ensureWalletForUser(userId);
    return {
      created: true,
      paxos: this.paxosStatus(),
      wallet: this.publicWallet(wallet),
    };
  }

  async ensureWalletForUser(userId: string) {
    const existing = await prisma.cryptoWallet.findUnique({ where: { userId } });
    if (existing) return existing;

    paxos.assertConfigured();

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new CryptoApiError("USER_NOT_FOUND", "User not found", 404);

    try {
      const identity = await paxos.createIdentity({
        userId,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
      });
      const profile = await paxos.createProfile(
        `${userId}-crypto`,
        `Chronos crypto profile for ${user.email}`,
      );

      const wallet = await prisma.cryptoWallet.create({
        data: {
          userId,
          paxosCustomerId: identity.id,
          paxosWalletId: profile.id,
        },
      });

      await audit.log({
        action: "WALLET_CREATED",
        userId,
        metadata: {
          paxos_identity_id: identity.id,
          paxos_profile_id: profile.id,
        },
      });

      return wallet;
    } catch (err: any) {
      if (err?.code === "P2002") {
        const wallet = await prisma.cryptoWallet.findUnique({ where: { userId } });
        if (wallet) return wallet;
      }

      await audit.log({
        action: "WALLET_PROVISION_FAILED",
        userId,
        metadata: this.errorMetadata(err),
      });
      throw err;
    }
  }

  private publicWallet(wallet: CryptoWalletRecord) {
    return {
      status: "ready",
      id: wallet.id,
      paxosCustomerId: wallet.paxosCustomerId,
      paxosWalletId: wallet.paxosWalletId,
      createdAt: wallet.createdAt,
    };
  }

  private paxosStatus() {
    return {
      configured: paxos.isConfigured(),
      environment: process.env.PAXOS_ENV || process.env.NODE_ENV || "sandbox",
    };
  }

  private async assertCryptoAccountProvisionAllowed(userId: string) {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (profile?.frozen || profile?.status === "SUSPENDED") {
      await this.auditComplianceRejection(userId, "ACCOUNT_SUSPENDED");
      throw new CryptoApiError(
        "ACCOUNT_SUSPENDED",
        "This account is suspended for crypto account provisioning.",
        403,
      );
    }
    if (!profile || !profile.kycVerified || profile.status !== "APPROVED") {
      await this.auditComplianceRejection(userId, "KYC_NOT_VERIFIED");
      throw new CryptoApiError(
        "KYC_NOT_VERIFIED",
        "KYC approval is required before creating a Paxos crypto account.",
        403,
      );
    }
  }

  private async tryLazyProvisionWallet(userId: string): Promise<{ status: string; error?: string }> {
    const existing = await prisma.cryptoWallet.findUnique({ where: { userId } });
    if (existing) return { status: "ready" };

    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile?.kycVerified || profile.status !== "APPROVED") return { status: "not_provisioned" };
    if (!paxos.isConfigured()) return { status: "not_configured" };

    try {
      await this.ensureWalletForUser(userId);
      return { status: "ready" };
    } catch (err) {
      const message = err instanceof Error ? err.message : "Wallet provisioning failed";
      return { status: "provision_failed", error: message };
    }
  }

  private async assertPaxosTradingReady() {
    paxos.assertConfigured();
  }

  private async assertTradeAllowed(userId: string, incomingNotionalUsd: Decimal) {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (profile?.frozen || profile?.status === "SUSPENDED") {
      await this.auditComplianceRejection(userId, "ACCOUNT_SUSPENDED");
      throw new CryptoApiError("ACCOUNT_SUSPENDED", "This account is suspended for trading.", 403);
    }
    if (!profile || !profile.kycVerified || profile.status !== "APPROVED") {
      await this.auditComplianceRejection(userId, "KYC_NOT_VERIFIED");
      throw new CryptoApiError("KYC_NOT_VERIFIED", "KYC approval is required before crypto trading.", 403);
    }

    const wallet = await prisma.cryptoWallet.findUnique({ where: { userId } });
    if (!wallet) {
      await this.auditComplianceRejection(userId, "WALLET_NOT_FOUND");
      throw new CryptoApiError("WALLET_NOT_FOUND", "No Paxos trading wallet is provisioned for this account.", 403);
    }

    const flagged = await prisma.auditLog.findFirst({
      where: { userId, action: "ACCOUNT_FLAGGED" },
      orderBy: { createdAt: "desc" },
    });
    if (flagged) {
      await this.auditComplianceRejection(userId, "ACCOUNT_FLAGGED");
      throw new CryptoApiError("ACCOUNT_FLAGGED", "This account is flagged for review.", 403);
    }

    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const user = await prisma.user.findUnique({ where: { id: userId }, select: { tier: true } });
    const dailyLimit = this.dailyLimitForTier(user?.tier || "standard");
    const today = await prisma.trade.aggregate({
      where: {
        userId,
        status: "FILLED",
        createdAt: { gte: startOfDay },
      },
      _sum: { amountUsd: true },
    });
    const todayVolume = new Decimal(today._sum.amountUsd?.toString() || 0);
    if (todayVolume.plus(incomingNotionalUsd).gt(dailyLimit)) {
      await this.auditComplianceRejection(userId, "DAILY_LIMIT_EXCEEDED", {
        today_volume: todayVolume.toFixed(2),
        incoming_notional_usd: incomingNotionalUsd.toFixed(2),
        limit: dailyLimit,
      });
      throw new CryptoApiError("DAILY_LIMIT_EXCEEDED", "Daily crypto trading limit exceeded.", 403);
    }

    return wallet;
  }

  private async getPortfolio(
    userId: string,
    prices: Record<SupportedCryptoAsset, MarketPrice>,
  ) {
    const holdings = await prisma.portfolioHolding.findMany({
      where: { userId },
      orderBy: { asset: "asc" },
    });

    let totalValueUsd = new Decimal(0);
    let totalPnl = new Decimal(0);
    let totalCostBasis = new Decimal(0);

    const enrichedHoldings = holdings.map((holding) => {
      const asset = paxos.normalizeAsset(holding.asset);
      const amount = new Decimal(holding.amount.toString());
      const avgPrice = new Decimal(holding.avgPrice.toString());
      const currentPrice = new Decimal(prices[asset]?.price || 0);
      const currentValue = amount.mul(currentPrice);
      const costBasis = amount.mul(avgPrice);
      const pnl = currentValue.minus(costBasis);
      const pnlPct = costBasis.gt(0) ? pnl.div(costBasis).mul(100) : new Decimal(0);

      totalValueUsd = totalValueUsd.plus(currentValue);
      totalPnl = totalPnl.plus(pnl);
      totalCostBasis = totalCostBasis.plus(costBasis);

      return {
        asset: holding.asset,
        amount: amount.toDecimalPlaces(8).toNumber(),
        avg_price: avgPrice.toDecimalPlaces(2).toNumber(),
        current_price: currentPrice.toDecimalPlaces(2).toNumber(),
        current_value: currentValue.toDecimalPlaces(2).toNumber(),
        unrealized_pnl: pnl.toDecimalPlaces(2).toNumber(),
        pnl_pct: pnlPct.toDecimalPlaces(2).toNumber(),
      };
    });

    return {
      holdings: enrichedHoldings,
      total_value_usd: totalValueUsd.toDecimalPlaces(2).toNumber(),
      total_pnl: totalPnl.toDecimalPlaces(2).toNumber(),
      total_pnl_pct: totalCostBasis.gt(0)
        ? totalPnl.div(totalCostBasis).mul(100).toDecimalPlaces(2).toNumber()
        : 0,
    };
  }

  private async increaseHolding(
    tx: TxClient,
    userId: string,
    asset: SupportedCryptoAsset,
    amountReceived: Decimal,
    buyPrice: Decimal,
  ) {
    const existing = await tx.portfolioHolding.findUnique({
      where: { userId_asset: { userId, asset } },
    });

    if (!existing) {
      await tx.portfolioHolding.create({
        data: {
          userId,
          asset,
          amount: amountReceived.toFixed(8),
          avgPrice: buyPrice.toFixed(2),
        },
      });
      return;
    }

    const existingAmount = new Decimal(existing.amount.toString());
    const existingAvgPrice = new Decimal(existing.avgPrice.toString());
    const newAmount = existingAmount.plus(amountReceived);
    const newAvgPrice = existingAvgPrice
      .mul(existingAmount)
      .plus(buyPrice.mul(amountReceived))
      .div(newAmount);

    await tx.portfolioHolding.update({
      where: { userId_asset: { userId, asset } },
      data: {
        amount: newAmount.toFixed(8),
        avgPrice: newAvgPrice.toFixed(2),
      },
    });
  }

  private async decreaseHolding(
    tx: TxClient,
    userId: string,
    asset: SupportedCryptoAsset,
    amountSold: Decimal,
  ) {
    const existing = await tx.portfolioHolding.findUnique({
      where: { userId_asset: { userId, asset } },
    });
    if (!existing) return;

    const currentAmount = new Decimal(existing.amount.toString());
    const nextAmount = Decimal.max(0, currentAmount.minus(amountSold));
    await tx.portfolioHolding.update({
      where: { userId_asset: { userId, asset } },
      data: { amount: nextAmount.toFixed(8) },
    });
  }

  private async recordRevenue(
    tx: TxClient,
    userId: string,
    tradeId: string,
    feeAmount: Decimal,
    spreadAmount: Decimal,
    asset: SupportedCryptoAsset,
  ) {
    await tx.revenue.createMany({
      data: [
        {
          userId,
          tradeId,
          type: "TRADE_FEE",
          amount: feeAmount.toFixed(2),
          asset,
        },
        {
          userId,
          tradeId,
          type: "SPREAD",
          amount: spreadAmount.toFixed(2),
          asset,
        },
      ],
    });
  }

  private calculateBuyFees(amountUsd: Decimal, marketPriceValue: number) {
    const marketPrice = new Decimal(marketPriceValue);
    const feeAmount = amountUsd.mul(this.feeRate);
    const spreadPerUnit = marketPrice.mul(this.spreadRate);
    const executionPrice = marketPrice.plus(spreadPerUnit);
    const netUsd = amountUsd.minus(feeAmount);
    return { feeAmount, spreadPerUnit, executionPrice, netUsd };
  }

  private calculateSellFees(amountCrypto: Decimal, marketPriceValue: number) {
    const marketPrice = new Decimal(marketPriceValue);
    const spreadPerUnit = marketPrice.mul(this.spreadRate);
    const executionPrice = marketPrice.minus(spreadPerUnit);
    const grossUsd = amountCrypto.mul(executionPrice);
    const feeAmount = grossUsd.mul(this.feeRate);
    const netUsd = grossUsd.minus(feeAmount);
    return { feeAmount, spreadPerUnit, executionPrice, grossUsd, netUsd };
  }

  private normalizeOrderFill(order: PaxosOrder): NormalizedOrderFill {
    const fillPrice = this.decimalFrom(
      order.fill_price || order.average_price || order.volume_weighted_average_price,
    );
    const baseAmount = this.decimalFrom(
      order.filled_base_amount || order.amount_filled || order.base_amount,
    );
    const quoteAmount = this.decimalFrom(order.filled_quote_amount || order.quote_amount);
    const filledAt = order.filled_at ? new Date(order.filled_at) : undefined;
    return { fillPrice, baseAmount, quoteAmount, filledAt };
  }

  private decimalFrom(value?: string): Decimal | undefined {
    if (!value) return undefined;
    try {
      const parsed = new Decimal(value);
      return parsed.isFinite() ? parsed : undefined;
    } catch {
      return undefined;
    }
  }

  private get feeRate(): number {
    return Number(process.env.FEE_RATE_DEFAULT ?? DEFAULT_FEE_RATE);
  }

  private get spreadRate(): number {
    return Number(process.env.SPREAD_RATE ?? DEFAULT_SPREAD_RATE);
  }

  private dailyLimitForTier(tier: string): number {
    if (tier === "verified_plus") {
      return Number(process.env.DAILY_TRADE_LIMIT_VERIFIED_PLUS ?? 50_000);
    }
    return Number(process.env.DAILY_TRADE_LIMIT_STANDARD ?? 10_000);
  }

  private async auditComplianceRejection(
    userId: string,
    reason: string,
    metadata?: Record<string, unknown>,
  ) {
    await audit.log({
      action: "COMPLIANCE_REJECTED",
      userId,
      metadata: { reason, ...metadata },
    });
  }

  private errorMetadata(err: unknown, extra?: Record<string, unknown>) {
    const error = err as any;
    return {
      ...extra,
      code: error?.code,
      message: error instanceof Error ? error.message : String(err),
      details: error?.details,
    };
  }
}

export const cryptoService = new CryptoService();
export default cryptoService;
