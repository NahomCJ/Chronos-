// ============================================================
// AuditService — Module 5
// Append-only log of every significant system event.
// Records are NEVER modified or deleted (enforced by DB trigger).
// ============================================================

import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export type AuditAction =
  | 'BUY_BTC'
  | 'BUY_ETH'
  | 'BUY_SOL'
  | 'SELL_BTC'
  | 'SELL_ETH'
  | 'SELL_SOL'
  | 'KYC_APPROVED'
  | 'KYC_REJECTED'
  | 'WALLET_CREATED'
  | 'WALLET_PROVISION_FAILED'
  | 'COMPLIANCE_REJECTED'
  | 'ORDER_FAILED'
  | 'ORDER_TIMEOUT'
  | 'ACCOUNT_SUSPENDED'
  | 'USER_REGISTERED'
  | 'USER_LOGIN'
  | string; // Allow custom actions

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(private readonly prisma: PrismaService) {}

  async log(
    action: AuditAction,
    userId: string | null,
    metadata?: Record<string, any>,
    amount?: number,
    asset?: string,
  ): Promise<void> {
    try {
      await this.prisma.auditLog.create({
        data: {
          action,
          userId: userId ?? undefined,
          amount: amount ?? undefined,
          asset: asset ?? undefined,
          metadata: metadata ?? undefined,
        },
      });
    } catch (err) {
      // Audit failures must NOT block the main flow — log and continue
      this.logger.error(`Failed to write audit log: ${action} for user ${userId}`, err);
    }
  }
}
