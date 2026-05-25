// ============================================================
// TradingService Unit Tests
// Tests the full BUY and SELL flows with all dependencies mocked.
// ============================================================

import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { TradingService } from './trading.service';
import { PrismaService } from '../../prisma/prisma.service';
import { PaxosService } from '../../providers/paxos/paxos.service';
import { ComplianceService } from '../compliance/compliance.service';
import { WalletService } from '../wallet/wallet.service';
import { PortfolioService } from '../portfolio/portfolio.service';
import { RevenueService } from '../revenue/revenue.service';
import { AuditService } from '../audit/audit.service';
import { BlockhubGateway } from '../../gateway/blockhub.gateway';
import { PaxosApiError } from '../../providers/paxos/paxos.types';

describe('TradingService', () => {
  let service: TradingService;

  // Mocked dependencies
  const mockPrisma = {
    $transaction: jest.fn(),
    trade: { create: jest.fn() },
  };
  const mockPaxos = {
    getMarketPrice: jest.fn(),
    placeOrder: jest.fn(),
    pollOrderUntilFilled: jest.fn(),
    getUsdBalance: jest.fn(),
    getCryptoBalance: jest.fn(),
  };
  const mockCompliance = { checkUser: jest.fn() };
  const mockWallet = { getWallet: jest.fn() };
  const mockPortfolio = {
    updateHoldings: jest.fn(),
    reduceHoldings: jest.fn(),
    getHolding: jest.fn(),
  };
  const mockRevenue = {
    calculateBuyFees: jest.fn(),
    calculateSellFees: jest.fn(),
    record: jest.fn(),
  };
  const mockAudit = { log: jest.fn() };
  const mockGateway = { pushPortfolioUpdate: jest.fn() };
  const mockConfig = {
    get: jest.fn((key: string, def?: any) => {
      if (key === 'FEE_RATE_DEFAULT') return 0.005;
      if (key === 'SPREAD_RATE') return 0.002;
      return def;
    }),
  };

  const MOCK_WALLET = {
    id: 'wallet-1',
    user_id: 'user-1',
    paxos_customer_id: 'identity-1',
    paxos_wallet_id: 'profile-1',
    created_at: new Date(),
  };

  const MOCK_FILLED_ORDER = {
    id: 'paxos-order-1',
    status: 'FILLED' as const,
    side: 'BUY' as const,
    market: 'BTCUSD',
    type: 'MARKET',
    profile_id: 'profile-1',
    fill_price: '62000.00',
    base_amount: '0.01587',
    quote_amount: '984.94',
    filled_at: new Date().toISOString(),
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TradingService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: PaxosService, useValue: mockPaxos },
        { provide: ComplianceService, useValue: mockCompliance },
        { provide: WalletService, useValue: mockWallet },
        { provide: PortfolioService, useValue: mockPortfolio },
        { provide: RevenueService, useValue: mockRevenue },
        { provide: AuditService, useValue: mockAudit },
        { provide: BlockhubGateway, useValue: mockGateway },
        { provide: ConfigService, useValue: mockConfig },
      ],
    }).compile();

    service = module.get<TradingService>(TradingService);
  });

  afterEach(() => jest.clearAllMocks());

  // ── BUY Flow ─────────────────────────────────────────────────

  describe('buy()', () => {
    const userId = 'user-1';
    const buyDto = { asset: 'BTC', amount_usd: 1000 };

    beforeEach(() => {
      mockCompliance.checkUser.mockResolvedValue(undefined);
      mockWallet.getWallet.mockResolvedValue(MOCK_WALLET);
      mockPaxos.getUsdBalance.mockResolvedValue(5000);
      mockPaxos.getMarketPrice.mockResolvedValue(62000);
      mockRevenue.calculateBuyFees.mockReturnValue({
        feeAmount: 5.00,
        spreadAmount: 124.00,
        executionPrice: 62124.00,
        netUsd: 995.00,
      });
      mockPaxos.placeOrder.mockResolvedValue({ id: 'paxos-order-1', status: 'PENDING' });
      mockPaxos.pollOrderUntilFilled.mockResolvedValue(MOCK_FILLED_ORDER);
      mockPrisma.$transaction.mockImplementation(async (fn: any) =>
        fn({
          trade: { create: jest.fn().mockResolvedValue({ id: 'trade-1' }) },
          portfolioHolding: { findUnique: jest.fn(), create: jest.fn(), update: jest.fn() },
          revenue: { createMany: jest.fn() },
        }),
      );
      mockPortfolio.updateHoldings.mockResolvedValue(undefined);
      mockRevenue.record.mockResolvedValue(undefined);
      mockPortfolio.getHolding.mockResolvedValue({
        asset: 'BTC', amount: 0.01587, current_value: 985, pnl: 0, pnl_pct: 0,
      });
      mockGateway.pushPortfolioUpdate.mockReturnValue(undefined);
      mockAudit.log.mockResolvedValue(undefined);
    });

    it('should complete a successful BUY and return trade result', async () => {
      const result = await service.buy(userId, buyDto);

      expect(result.status).toBe('filled');
      expect(result.asset).toBe('BTC');
      expect(result.amount_usd).toBe(1000);
      expect(result.fee).toBe(5.00);
      expect(result.trade_id).toBeDefined();
    });

    it('should run compliance check before anything else', async () => {
      const callOrder: string[] = [];
      mockCompliance.checkUser.mockImplementation(() => { callOrder.push('compliance'); });
      mockPaxos.getUsdBalance.mockImplementation(() => { callOrder.push('balance'); return 5000; });

      await service.buy(userId, buyDto);

      expect(callOrder[0]).toBe('compliance');
      expect(callOrder[1]).toBe('balance');
    });

    it('should throw 422 INSUFFICIENT_BALANCE if USD balance is too low', async () => {
      mockPaxos.getUsdBalance.mockResolvedValue(50); // Less than $1000

      await expect(service.buy(userId, buyDto)).rejects.toMatchObject({
        response: expect.objectContaining({ code: 'INSUFFICIENT_BALANCE' }),
      });
    });

    it('should not place order if compliance check fails', async () => {
      mockCompliance.checkUser.mockRejectedValue(new Error('KYC_NOT_VERIFIED'));

      await expect(service.buy(userId, buyDto)).rejects.toThrow();
      expect(mockPaxos.placeOrder).not.toHaveBeenCalled();
    });

    it('should audit ORDER_TIMEOUT on poll timeout', async () => {
      mockPaxos.pollOrderUntilFilled.mockRejectedValue(
        new PaxosApiError('ORDER_TIMEOUT', 'Timeout', 504),
      );

      await expect(service.buy(userId, buyDto)).rejects.toBeDefined();
      expect(mockAudit.log).toHaveBeenCalledWith(
        'ORDER_TIMEOUT',
        userId,
        expect.objectContaining({ paxos_order_id: 'paxos-order-1' }),
      );
    });

    it('should push WebSocket portfolio update after successful trade', async () => {
      await service.buy(userId, buyDto);
      expect(mockGateway.pushPortfolioUpdate).toHaveBeenCalledWith(
        userId,
        expect.any(Object),
      );
    });
  });

  // ── SELL Flow ────────────────────────────────────────────────

  describe('sell()', () => {
    const userId = 'user-1';
    const sellDto = { asset: 'BTC', amount_crypto: 0.015 };

    const MOCK_SELL_ORDER = {
      ...MOCK_FILLED_ORDER,
      side: 'SELL' as const,
      base_amount: '0.015',
      quote_amount: '930.00',
    };

    beforeEach(() => {
      mockCompliance.checkUser.mockResolvedValue(undefined);
      mockWallet.getWallet.mockResolvedValue(MOCK_WALLET);
      mockPaxos.getCryptoBalance.mockResolvedValue(0.05);
      mockPaxos.getMarketPrice.mockResolvedValue(62000);
      mockRevenue.calculateSellFees.mockReturnValue({
        feeAmount: 4.65,
        spreadAmount: 124.00,
        executionPrice: 61876.00,
        netUsd: 924.04,
        grossUsd: 928.14,
      });
      mockPaxos.placeOrder.mockResolvedValue({ id: 'paxos-sell-order-1', status: 'PENDING' });
      mockPaxos.pollOrderUntilFilled.mockResolvedValue(MOCK_SELL_ORDER);
      mockPrisma.$transaction.mockImplementation(async (fn: any) =>
        fn({
          trade: { create: jest.fn().mockResolvedValue({ id: 'trade-2' }) },
          portfolioHolding: { findUnique: jest.fn(), update: jest.fn() },
          revenue: { createMany: jest.fn() },
        }),
      );
      mockPortfolio.reduceHoldings.mockResolvedValue(undefined);
      mockRevenue.record.mockResolvedValue(undefined);
      mockPortfolio.getHolding.mockResolvedValue({
        asset: 'BTC', amount: 0.035, current_value: 2170, pnl: 50, pnl_pct: 2.4,
      });
      mockGateway.pushPortfolioUpdate.mockReturnValue(undefined);
      mockAudit.log.mockResolvedValue(undefined);
    });

    it('should complete a successful SELL and return trade result', async () => {
      const result = await service.sell(userId, sellDto);

      expect(result.status).toBe('filled');
      expect(result.asset).toBe('BTC');
      expect(result.amount_crypto).toBe(0.015);
      expect(result.fee).toBe(4.65);
    });

    it('should throw 422 INSUFFICIENT_CRYPTO_BALANCE if crypto balance is too low', async () => {
      mockPaxos.getCryptoBalance.mockResolvedValue(0.001); // Less than 0.015

      await expect(service.sell(userId, sellDto)).rejects.toMatchObject({
        response: expect.objectContaining({ code: 'INSUFFICIENT_CRYPTO_BALANCE' }),
      });
    });
  });
});
