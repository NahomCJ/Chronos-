// ============================================================
// TradingService — Module 3 (Core of BlockHub)
//
// BUY Flow:
//   1. Compliance gate
//   2. USD balance check
//   3. Fee + spread calculation
//   4. Place Paxos order
//   5. Poll until filled
//   6. Atomic DB write (trade + portfolio + revenue)
//   7. Audit + WebSocket push
//
// SELL Flow:
//   1. Compliance gate
//   2. Crypto balance check
//   3. Fee + spread calculation
//   4. Place Paxos order
//   5. Poll until filled
//   6. Atomic DB write (trade + portfolio + revenue)
//   7. Audit + WebSocket push
//
// NON-NEGOTIABLE RULES:
//   - Fees BEFORE order submission
//   - Atomic writes — revenue + trade in same TX
//   - Every trade audited (success AND failure)
//   - No trade bypasses compliance gate
// ============================================================

import {
  Injectable,
  Logger,
  HttpException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { randomUUID as uuidv4 } from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { PaxosService } from '../../providers/paxos/paxos.service';
import { PaxosMapper } from '../../providers/paxos/paxos.mapper';
import { PaxosApiError } from '../../providers/paxos/paxos.types';
import { ComplianceService } from '../compliance/compliance.service';
import { WalletService } from '../wallet/wallet.service';
import { PortfolioService } from '../portfolio/portfolio.service';
import { RevenueService } from '../revenue/revenue.service';
import { AuditService } from '../audit/audit.service';
import { BlockhubGateway } from '../../gateway/blockhub.gateway';
import { BuyDto } from './dto/buy.dto';
import { SellDto } from './dto/sell.dto';
import { AppError } from '../../common/errors/app.error';

@Injectable()
export class TradingService {
  private readonly logger = new Logger(TradingService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly paxos: PaxosService,
    private readonly compliance: ComplianceService,
    private readonly wallet: WalletService,
    private readonly portfolio: PortfolioService,
    private readonly revenue: RevenueService,
    private readonly audit: AuditService,
    private readonly gateway: BlockhubGateway,
    private readonly config: ConfigService,
  ) {}

  private get feeRate(): number {
    return this.config.get<number>('FEE_RATE_DEFAULT', 0.005);
  }

  private get spreadRate(): number {
    return this.config.get<number>('SPREAD_RATE', 0.002);
  }

  // ============================================================
  // BUY
  // ============================================================

  async buy(userId: string, dto: BuyDto) {
    const { asset, amount_usd } = dto;
    const tradeId = uuidv4();
    this.logger.log(`BUY initiated: user=${userId} asset=${asset} amount=$${amount_usd}`);

    // ── Step 1: Compliance gate ──────────────────────────────
    await this.compliance.checkUser(userId);

    // ── Step 2: Wallet + balance check ──────────────────────
    const walletRecord = await this.wallet.getWallet(userId);
    const profileId = walletRecord.paxosWalletId;

    const usdBalance = await this.paxos.getUsdBalance(profileId);
    if (usdBalance < amount_usd) {
      throw new AppError('INSUFFICIENT_BALANCE', `Insufficient USD balance. Available: $${usdBalance.toFixed(2)}`, 422);
    }

    // ── Step 3: Fee + price calculation ─────────────────────
    const marketPrice = await this.paxos.getMarketPrice(asset);
    const fees = this.revenue.calculateBuyFees(amount_usd, marketPrice, this.feeRate, this.spreadRate);

    this.logger.debug(
      `BUY fees: fee=${fees.feeAmount.toFixed(2)} spread=${fees.spreadAmount.toFixed(2)} ` +
      `execPrice=${fees.executionPrice.toFixed(2)} netUsd=${fees.netUsd.toFixed(2)}`,
    );

    // ── Step 4: Place Paxos order ────────────────────────────
    let paxosOrderId: string;
    try {
      const order = await this.paxos.placeOrder({
        profile_id: profileId,
        side: 'BUY',
        market: `${asset.toUpperCase()}USD`,
        type: 'MARKET',
        quote_amount: fees.netUsd.toFixed(8), // net USD after fee
        client_order_id: tradeId,
      });
      paxosOrderId = order.id;
    } catch (err) {
      await this.audit.log(`BUY_${asset}`, userId, {
        event: 'ORDER_PLACEMENT_FAILED',
        amount_usd,
        error: (err as Error).message,
      });
      throw this.wrapPaxosError(err);
    }

    // ── Step 5: Poll for fill ────────────────────────────────
    let filledOrder: Awaited<ReturnType<typeof this.paxos.pollOrderUntilFilled>>;
    try {
      filledOrder = await this.paxos.pollOrderUntilFilled(paxosOrderId);
    } catch (err: any) {
      const isTimeout = err?.code === 'ORDER_TIMEOUT';
      await this.audit.log(isTimeout ? 'ORDER_TIMEOUT' : 'ORDER_FAILED', userId, {
        paxos_order_id: paxosOrderId,
        asset,
        amount_usd,
        error: err.message,
      });
      throw this.wrapPaxosError(err);
    }

    const result = PaxosMapper.toInternalOrder(filledOrder);
    const cryptoReceived = result.cryptoAmount ?? fees.netUsd / fees.executionPrice;
    const fillPrice = result.fillPrice ?? fees.executionPrice;

    // ── Step 6: Atomic DB write ──────────────────────────────
    await this.prisma.$transaction(async (tx) => {
      // 6a. Insert trade record
      const trade = await tx.trade.create({
        data: {
          id: tradeId,
          userId: userId,
          asset: asset.toUpperCase(),
          side: 'BUY',
          amountUsd: amount_usd,
          amountCrypto: cryptoReceived,
          fee: fees.feeAmount,
          executionPrice: fillPrice,
          paxosOrderId: paxosOrderId,
          status: 'FILLED',
          filledAt: result.filledAt ?? new Date(),
        },
      });

      // 6b. Update portfolio holdings (weighted avg)
      await this.portfolio.updateHoldings(tx, userId, asset, cryptoReceived, fillPrice);

      // 6c. Record revenue (fee + spread)
      await this.revenue.record(tx, userId, trade.id, fees.feeAmount, fees.spreadAmount, asset);
    });

    // ── Step 7: Post-trade ───────────────────────────────────
    await this.audit.log(`BUY_${asset}`, userId, {
      trade_id: tradeId,
      paxos_order_id: paxosOrderId,
      amount_usd,
      fee: fees.feeAmount,
      crypto_received: cryptoReceived,
      execution_price: fillPrice,
    }, amount_usd, asset);

    const updatedHoldings = await this.portfolio.getHolding(userId, asset);
    this.gateway.pushPortfolioUpdate(userId, updatedHoldings);

    this.logger.log(`BUY completed: user=${userId} asset=${asset} received=${cryptoReceived} price=${fillPrice}`);

    return {
      trade_id: tradeId,
      asset,
      amount_usd,
      fee: fees.feeAmount,
      crypto_received: cryptoReceived,
      execution_price: fillPrice,
      status: 'filled',
      filled_at: result.filledAt ?? new Date(),
    };
  }

  // ============================================================
  // SELL
  // ============================================================

  async sell(userId: string, dto: SellDto) {
    const { asset, amount_crypto } = dto;
    const tradeId = uuidv4();
    this.logger.log(`SELL initiated: user=${userId} asset=${asset} amount=${amount_crypto}`);

    // ── Step 1: Compliance gate ──────────────────────────────
    await this.compliance.checkUser(userId);

    // ── Step 2: Wallet + crypto balance check ───────────────
    const walletRecord = await this.wallet.getWallet(userId);
    const profileId = walletRecord.paxosWalletId;

    const cryptoBalance = await this.paxos.getCryptoBalance(profileId, asset);
    if (cryptoBalance < amount_crypto) {
      throw new AppError(
        'INSUFFICIENT_CRYPTO_BALANCE',
        `Insufficient ${asset} balance. Available: ${cryptoBalance}`,
        422,
      );
    }

    // ── Step 3: Fee + price calculation ─────────────────────
    const marketPrice = await this.paxos.getMarketPrice(asset);
    const fees = this.revenue.calculateSellFees(amount_crypto, marketPrice, this.feeRate, this.spreadRate);

    this.logger.debug(
      `SELL fees: grossUsd=${fees.grossUsd.toFixed(2)} fee=${fees.feeAmount.toFixed(2)} netUsd=${fees.netUsd.toFixed(2)}`,
    );

    // ── Step 4: Place Paxos order ────────────────────────────
    let paxosOrderId: string;
    try {
      const order = await this.paxos.placeOrder({
        profile_id: profileId,
        side: 'SELL',
        market: `${asset.toUpperCase()}USD`,
        type: 'MARKET',
        base_amount: amount_crypto.toFixed(8),
        client_order_id: tradeId,
      });
      paxosOrderId = order.id;
    } catch (err) {
      await this.audit.log(`SELL_${asset}`, userId, {
        event: 'ORDER_PLACEMENT_FAILED',
        amount_crypto,
        error: (err as Error).message,
      });
      throw this.wrapPaxosError(err);
    }

    // ── Step 5: Poll for fill ────────────────────────────────
    let filledOrder: Awaited<ReturnType<typeof this.paxos.pollOrderUntilFilled>>;
    try {
      filledOrder = await this.paxos.pollOrderUntilFilled(paxosOrderId);
    } catch (err: any) {
      const isTimeout = err?.code === 'ORDER_TIMEOUT';
      await this.audit.log(isTimeout ? 'ORDER_TIMEOUT' : 'ORDER_FAILED', userId, {
        paxos_order_id: paxosOrderId,
        asset,
        amount_crypto,
        error: err.message,
      });
      throw this.wrapPaxosError(err);
    }

    const result = PaxosMapper.toInternalOrder(filledOrder);
    const fillPrice = result.fillPrice ?? fees.executionPrice;
    const netUsd = result.usdAmount ? result.usdAmount - fees.feeAmount : fees.netUsd;

    // ── Step 6: Atomic DB write ──────────────────────────────
    await this.prisma.$transaction(async (tx) => {
      const trade = await tx.trade.create({
        data: {
          id: tradeId,
          userId: userId,
          asset: asset.toUpperCase(),
          side: 'SELL',
          amountUsd: fees.grossUsd,
          amountCrypto: amount_crypto,
          fee: fees.feeAmount,
          executionPrice: fillPrice,
          paxosOrderId: paxosOrderId,
          status: 'FILLED',
          filledAt: result.filledAt ?? new Date(),
        },
      });

      await this.portfolio.reduceHoldings(tx, userId, asset, amount_crypto);
      await this.revenue.record(tx, userId, trade.id, fees.feeAmount, fees.spreadAmount, asset);
    });

    // ── Step 7: Post-trade ───────────────────────────────────
    await this.audit.log(`SELL_${asset}`, userId, {
      trade_id: tradeId,
      paxos_order_id: paxosOrderId,
      amount_crypto,
      gross_usd: fees.grossUsd,
      fee: fees.feeAmount,
      net_usd: netUsd,
    }, fees.grossUsd, asset);

    const updatedHoldings = await this.portfolio.getHolding(userId, asset);
    this.gateway.pushPortfolioUpdate(userId, updatedHoldings);

    this.logger.log(`SELL completed: user=${userId} asset=${asset} netUsd=${netUsd}`);

    return {
      trade_id: tradeId,
      asset,
      amount_crypto,
      gross_usd: fees.grossUsd,
      fee: fees.feeAmount,
      net_usd: netUsd,
      execution_price: fillPrice,
      status: 'filled',
      filled_at: result.filledAt ?? new Date(),
    };
  }

  // ---- Error wrapping ----

  private wrapPaxosError(err: any): any {
    if (err instanceof PaxosApiError) {
      return new AppError(err.code, err.message, err.statusCode);
    }
    if (err instanceof HttpException) return err;
    return new AppError('TRADING_ERROR', 'An unexpected trading error occurred', 500);
  }
}
