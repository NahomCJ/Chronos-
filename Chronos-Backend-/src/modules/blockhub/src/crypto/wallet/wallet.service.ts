// ============================================================
// WalletService — Module 1
// Handles Paxos identity + profile creation and wallet provisioning.
// Triggered automatically when a user's KYC is confirmed via Plaid webhook.
// ============================================================

import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { PaxosService } from '../../providers/paxos/paxos.service';
import { AuditService } from '../audit/audit.service';
import { AppError } from '../../common/errors/app.error';

@Injectable()
export class WalletService {
  private readonly logger = new Logger(WalletService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly paxos: PaxosService,
    private readonly audit: AuditService,
  ) {}

  /**
   * Main entry point — called when Plaid webhook confirms VERIFIED status.
   * Creates a Paxos identity, profile, and stores the wallet_id.
   * Idempotent: if wallet already exists, returns the existing record.
   */
  async createForUser(userId: string): Promise<void> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });

    if (!user) {
      throw new AppError('USER_NOT_FOUND', 'User not found', 404);
    }

    // Idempotency check — don't re-provision if wallet already exists
    const existing = await this.prisma.cryptoWallet.findUnique({
      where: { userId: userId },
    });

    if (existing) {
      this.logger.warn(`Wallet already provisioned for user ${userId} — skipping`);
      return;
    }

    try {
      // Step 1: Create Paxos Identity
      this.logger.log(`Provisioning Paxos identity for user ${userId}`);
      const firstName = user.firstName || 'Unknown';
      const lastName = user.lastName || 'Unknown';

      const identity = await this.paxos.createIdentity({
        ref_id: userId,
        customer_type: 'INDIVIDUAL',
        first_name: firstName,
        last_name: lastName,
        email: user.email,
      });

      // Step 2: Create Paxos Profile (linked to identity)
      this.logger.log(`Creating Paxos profile for identity ${identity.id}`);
      const profile = await this.paxos.createProfile({
        identity_id: identity.id,
        ref_id: `${userId}-profile`,
      });

      // Step 3: Persist to database
      await this.prisma.$transaction([
        this.prisma.cryptoWallet.create({
          data: {
            userId: userId,
            paxosCustomerId: identity.id,
            paxosWalletId: profile.id, // profile ID is our "wallet ID"
          },
        })
      ]);

      // Step 4: Audit
      await this.audit.log('WALLET_CREATED', userId, {
        paxos_identity_id: identity.id,
        paxos_profile_id: profile.id,
      });

      this.logger.log(`Wallet provisioned successfully for user ${userId}`);
    } catch (err: any) {
      this.logger.error(`Failed to provision wallet for user ${userId}`, err);
      await this.audit.log('WALLET_PROVISION_FAILED', userId, { error: err.message });
      throw err;
    }
  }

  /**
   * Returns wallet info for a user, or throws if not provisioned.
   */
  async getWallet(userId: string) {
    const wallet = await this.prisma.cryptoWallet.findUnique({ where: { userId: userId } });
    if (!wallet) {
      throw new AppError('WALLET_NOT_FOUND', 'Trading wallet not provisioned for this account', 403);
    }
    return wallet;
  }

  /**
   * Returns USD balance for a user's Paxos profile.
   */
  async getUsdBalance(userId: string): Promise<number> {
    const wallet = await this.getWallet(userId);
    return this.paxos.getUsdBalance(wallet.paxosWalletId);
  }

  /**
   * Returns crypto balance for a specific asset.
   */
  async getCryptoBalance(userId: string, asset: string): Promise<number> {
    const wallet = await this.getWallet(userId);
    return this.paxos.getCryptoBalance(wallet.paxosWalletId, asset);
  }
}
