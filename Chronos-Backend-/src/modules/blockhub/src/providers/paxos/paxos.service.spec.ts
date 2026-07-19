// ============================================================
// PaxosService Unit Tests
// All Paxos HTTP calls are mocked — no real API calls made here.
// ============================================================

import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { PaxosService } from './paxos.service';
import { PaxosOrder, PaxosApiError } from './paxos.types';
import axios from 'axios';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('PaxosService', () => {
  let service: PaxosService;

  const mockConfig = {
    get: jest.fn((key: string, def?: any) => {
      const map: Record<string, any> = {
        NODE_ENV: 'test',
        PAXOS_CLIENT_ID: 'test-client-id',
        PAXOS_CLIENT_SECRET: 'test-client-secret',
        PAXOS_SCOPES: 'trading:read_order trading:write_order',
      };
      return map[key] ?? def;
    }),
    getOrThrow: jest.fn((key: string) => {
      const map: Record<string, any> = {
        PAXOS_CLIENT_ID: 'test-client-id',
        PAXOS_CLIENT_SECRET: 'test-client-secret',
      };
      if (!map[key]) throw new Error(`Config key ${key} not found`);
      return map[key];
    }),
  };

  beforeEach(async () => {
    // Mock OAuth token endpoint
    mockedAxios.post = jest.fn().mockResolvedValue({
      data: {
        access_token: 'mock-access-token',
        token_type: 'Bearer',
        expires_in: 3600,
        scope: 'trading:read_order trading:write_order',
      },
    });

    // Mock axios.create to return a client with a request method
    const mockClient = {
      interceptors: {
        request: { use: jest.fn() },
      },
      request: jest.fn(),
    };
    mockedAxios.create = jest.fn().mockReturnValue(mockClient);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PaxosService,
        { provide: ConfigService, useValue: mockConfig },
      ],
    }).compile();

    service = module.get<PaxosService>(PaxosService);
  });

  afterEach(() => jest.clearAllMocks());

  // ── Token Management ────────────────────────────────────────

  describe('OAuth2 token', () => {
    it('should fetch a token on first request', async () => {
      await service.onModuleInit();
      expect(mockedAxios.post).toHaveBeenCalledWith(
        expect.stringContaining('/oauth2/token'),
        expect.any(URLSearchParams),
        expect.any(Object),
      );
    });

    it('should use sandbox URL in non-production env', async () => {
      await service.onModuleInit();
      const callUrl = (mockedAxios.post as jest.Mock).mock.calls[0][0] as string;
      expect(callUrl).toContain('sandbox');
    });
  });

  // ── Fee Calculation (via RevenueService — tested separately) ─

  describe('getMarketPrice', () => {
    it('should throw UNSUPPORTED_ASSET for unknown asset', async () => {
      await expect(service.getMarketPrice('DOGE')).rejects.toThrow(PaxosApiError);
      await expect(service.getMarketPrice('DOGE')).rejects.toMatchObject({
        code: 'UNSUPPORTED_ASSET',
        statusCode: 400,
      });
    });
  });

  // ── Error Mapping ────────────────────────────────────────────

  describe('error mapping', () => {
    const errorCases: [number, string][] = [
      [400, 'INVALID_ORDER'],
      [401, 'PAXOS_AUTH_FAILED'],
      [403, 'PAXOS_FORBIDDEN'],
      [422, 'INSUFFICIENT_BALANCE'],
      [429, 'RATE_LIMITED'],
      [503, 'PAXOS_UNAVAILABLE'],
      [504, 'PAXOS_TIMEOUT'],
    ];

    it.each(errorCases)(
      'should map HTTP %i to error code %s',
      async (statusCode, expectedCode) => {
        // Access private mapError via casting
        const mapped = (service as any).mapError(statusCode, {});
        expect(mapped).toBeInstanceOf(PaxosApiError);
        expect(mapped.code).toBe(expectedCode);
        expect(mapped.statusCode).toBe(statusCode);
      },
    );
  });

  // ── Order Polling ────────────────────────────────────────────

  describe('pollOrderUntilFilled', () => {
    it('should throw ORDER_TIMEOUT after 15 failed attempts', async () => {
      const pendingOrder: PaxosOrder = {
        id: 'order-123',
        status: 'PENDING',
        side: 'BUY' as const,
        market: 'BTCUSD',
        type: 'MARKET',
        profile_id: 'profile-1',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      // Mock getOrder to always return PENDING
      jest.spyOn(service, 'getOrder').mockResolvedValue(pendingOrder);

      // Speed up polling for test
      jest.spyOn(service as any, 'sleep').mockResolvedValue(undefined);

      await expect(service.pollOrderUntilFilled('order-123')).rejects.toMatchObject({
        code: 'ORDER_TIMEOUT',
        statusCode: 504,
      });

      expect(service.getOrder).toHaveBeenCalledTimes(15);
    }, 10_000);

    it('should return immediately on FILLED status', async () => {
      const filledOrder: PaxosOrder = {
        id: 'order-456',
        status: 'FILLED' as const,
        side: 'BUY' as const,
        market: 'BTCUSD',
        type: 'MARKET',
        profile_id: 'profile-1',
        fill_price: '62000.00',
        base_amount: '0.01612',
        filled_at: new Date().toISOString(),
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      jest.spyOn(service, 'getOrder').mockResolvedValue(filledOrder);

      const result = await service.pollOrderUntilFilled('order-456');
      expect(result.status).toBe('FILLED');
      expect(service.getOrder).toHaveBeenCalledTimes(1);
    });

    it('should throw ORDER_EXECUTION_FAILED on FAILED status', async () => {
      const failedOrder: PaxosOrder = {
        id: 'order-789',
        status: 'FAILED' as const,
        side: 'BUY' as const,
        market: 'BTCUSD',
        type: 'MARKET',
        profile_id: 'profile-1',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      jest.spyOn(service, 'getOrder').mockResolvedValue(failedOrder);

      await expect(service.pollOrderUntilFilled('order-789')).rejects.toMatchObject({
        code: 'ORDER_EXECUTION_FAILED',
        statusCode: 502,
      });
    });
  });
});
