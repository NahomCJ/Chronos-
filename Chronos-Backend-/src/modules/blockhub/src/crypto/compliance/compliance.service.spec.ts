// ============================================================
// ComplianceService Unit Tests — All rejection paths
// ============================================================

import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { ComplianceService } from './compliance.service';
import { PrismaService } from '../../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { ComplianceError } from '../../common/errors/compliance.error';

describe('ComplianceService', () => {
  let service: ComplianceService;

  const mockAudit = { log: jest.fn() };
  const mockConfig = {
    get: jest.fn((key: string, def?: any) => {
      if (key === 'DAILY_TRADE_LIMIT_STANDARD') return 10000;
      if (key === 'DAILY_TRADE_LIMIT_VERIFIED_PLUS') return 50000;
      return def;
    }),
  };

  const makeMockPrisma = (overrides: Partial<{
    user: any;
    tradeAggregate: number;
    fraudFlag: any;
  }> = {}) => ({
    user: {
      findUnique: jest.fn().mockResolvedValue({
        id: 'user-1',
        status: 'VERIFIED',
        wallet_ready: true,
        tier: 'standard',
        ...overrides.user,
      }),
    },
    trade: {
      aggregate: jest.fn().mockResolvedValue({
        _sum: { amount_usd: overrides.tradeAggregate ?? 0 },
      }),
    },
    auditLog: {
      findFirst: jest.fn().mockResolvedValue(overrides.fraudFlag ?? null),
    },
  });

  const buildService = async (prismaOverrides = {}) => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ComplianceService,
        { provide: PrismaService, useValue: makeMockPrisma(prismaOverrides) },
        { provide: AuditService, useValue: mockAudit },
        { provide: ConfigService, useValue: mockConfig },
      ],
    }).compile();
    return module.get<ComplianceService>(ComplianceService);
  };

  afterEach(() => jest.clearAllMocks());

  it('should pass all checks for a fully verified user with no flags', async () => {
    service = await buildService();
    await expect(service.checkUser('user-1')).resolves.toBeUndefined();
  });

  it('should throw ACCOUNT_SUSPENDED for suspended users', async () => {
    service = await buildService({ user: { status: 'SUSPENDED' } });
    await expect(service.checkUser('user-1')).rejects.toMatchObject({
      response: expect.objectContaining({ code: 'ACCOUNT_SUSPENDED' }),
    });
  });

  it('should throw KYC_NOT_VERIFIED for EMAIL_VERIFIED users', async () => {
    service = await buildService({ user: { status: 'EMAIL_VERIFIED' } });
    await expect(service.checkUser('user-1')).rejects.toMatchObject({
      response: expect.objectContaining({ code: 'KYC_NOT_VERIFIED' }),
    });
  });

  it('should throw KYC_NOT_VERIFIED for PENDING_VERIFICATION users', async () => {
    service = await buildService({ user: { status: 'PENDING_VERIFICATION' } });
    await expect(service.checkUser('user-1')).rejects.toMatchObject({
      response: expect.objectContaining({ code: 'KYC_NOT_VERIFIED' }),
    });
  });

  it('should throw WALLET_NOT_FOUND if wallet_ready is false', async () => {
    service = await buildService({ user: { wallet_ready: false } });
    await expect(service.checkUser('user-1')).rejects.toMatchObject({
      response: expect.objectContaining({ code: 'WALLET_NOT_FOUND' }),
    });
  });

  it('should throw DAILY_LIMIT_EXCEEDED when volume hits $10,000', async () => {
    service = await buildService({ tradeAggregate: 10000 });
    await expect(service.checkUser('user-1')).rejects.toMatchObject({
      response: expect.objectContaining({ code: 'DAILY_LIMIT_EXCEEDED' }),
    });
  });

  it('should pass for verified_plus user under $50,000 daily limit', async () => {
    service = await buildService({
      user: { tier: 'verified_plus' },
      tradeAggregate: 20000,
    });
    await expect(service.checkUser('user-1')).resolves.toBeUndefined();
  });

  it('should throw ACCOUNT_FLAGGED when fraud flag exists', async () => {
    service = await buildService({
      fraudFlag: { id: 'flag-1', action: 'ACCOUNT_FLAGGED', user_id: 'user-1' },
    });
    await expect(service.checkUser('user-1')).rejects.toMatchObject({
      response: expect.objectContaining({ code: 'ACCOUNT_FLAGGED' }),
    });
  });

  it('should log COMPLIANCE_REJECTED audit event on every rejection', async () => {
    service = await buildService({ user: { status: 'SUSPENDED' } });
    try {
      await service.checkUser('user-1');
    } catch {
      // expected
    }
    expect(mockAudit.log).toHaveBeenCalledWith(
      'COMPLIANCE_REJECTED',
      'user-1',
      expect.objectContaining({ reason: 'ACCOUNT_SUSPENDED' }),
    );
  });
});
