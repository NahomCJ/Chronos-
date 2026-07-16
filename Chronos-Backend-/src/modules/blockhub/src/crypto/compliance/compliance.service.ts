// ============================================================
// ComplianceService — Module 5
// Pre-trade gate: runs on EVERY order before fee calculation.
// If ANY check fails: trade rejected, no fee charged, 403 returned.
// ============================================================

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';
import { ComplianceError } from '../../common/errors/compliance.error';
import { AuditService } from '../audit/audit.service';

@Injectable()
export class ComplianceService {
  private readonly logger = new Logger(ComplianceService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly audit: AuditService,
  ) {}

  /**
   * Pre-trade compliance gate.
   * Must pass ALL checks before any order is processed.
   * Throws ComplianceError on any failure.
   */
  async checkUser(userId: string): Promise<void> {
    const profile = await this.prisma.bankingProfile.findUnique({ where: { userId } });

    if (!profile) {
      throw new ComplianceError('KYC_NOT_VERIFIED');
    }

    // 1. Account must not be suspended (includes frozen)
    if (profile.status === 'SUSPENDED' || profile.frozen) {
      this.logger.warn(`Compliance rejected: user ${userId} is SUSPENDED or FROZEN`);
      await this.audit.log('COMPLIANCE_REJECTED', userId, { reason: 'ACCOUNT_SUSPENDED' });
      throw new ComplianceError('ACCOUNT_SUSPENDED');
    }

    // 2. KYC must be fully approved
    if (profile.status !== 'APPROVED' || !profile.kycVerified) {
      this.logger.warn(`Compliance rejected: user ${userId} status=${profile.status} verified=${profile.kycVerified}`);
      await this.audit.log('COMPLIANCE_REJECTED', userId, { reason: 'KYC_NOT_VERIFIED' });
      throw new ComplianceError('KYC_NOT_VERIFIED');
    }

    // 3. Wallet must be provisioned
    const wallet = await this.prisma.cryptoWallet.findUnique({ where: { userId } });
    if (!wallet) {
      this.logger.warn(`Compliance rejected: user ${userId} has no crypto wallet`);
      throw new ComplianceError('WALLET_NOT_FOUND');
    }

    // 4. Daily trading limit check
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    const todayVolume = await this.getTodayVolume(userId);
    const limit = this.getDailyLimitForTier(user?.tier ?? 'standard');

    if (todayVolume >= limit) {
      this.logger.warn(`Compliance rejected: user ${userId} daily limit ${limit} reached (${todayVolume})`);
      await this.audit.log('COMPLIANCE_REJECTED', userId, {
        reason: 'DAILY_LIMIT_EXCEEDED',
        today_volume: todayVolume,
        limit,
      });
      throw new ComplianceError('DAILY_LIMIT_EXCEEDED');
    }

    // 5. Fraud / AML flag check
    const flagged = await this.hasFraudFlag(userId);
    if (flagged) {
      await this.audit.log('COMPLIANCE_REJECTED', userId, { reason: 'ACCOUNT_FLAGGED' });
      throw new ComplianceError('ACCOUNT_FLAGGED');
    }
  }

  // ---- Daily Volume ----

  private async getTodayVolume(userId: string): Promise<number> {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const result = await this.prisma.trade.aggregate({
      where: {
        userId: userId,
        status: 'FILLED',
        createdAt: { gte: startOfDay },
      },
      _sum: { amountUsd: true },
    });

    return Number(result._sum.amountUsd ?? 0);
  }

  private getDailyLimitForTier(tier: string): number {
    const limits: Record<string, number> = {
      standard: this.config.get<number>('DAILY_TRADE_LIMIT_STANDARD', 10_000),
      verified_plus: this.config.get<number>('DAILY_TRADE_LIMIT_VERIFIED_PLUS', 50_000),
    };
    return limits[tier] ?? limits['standard'];
  }

  // ---- Fraud Flag ----

  /**
   * Returns true if the user has an active fraud/AML flag.
   * Phase 1: Checks audit log for unresolved ACCOUNT_FLAGGED events.
   * Phase 2: Replace with dedicated fraud-flag table + external AML feed.
   */
  private async hasFraudFlag(userId: string): Promise<boolean> {
    const flag = await this.prisma.auditLog.findFirst({
      where: {
        userId: userId,
        action: 'ACCOUNT_FLAGGED',
      },
      orderBy: { createdAt: 'desc' },
    });
    return !!flag;
  }
}
