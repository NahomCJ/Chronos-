import { Injectable, ForbiddenException, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

/**
 * ComplianceService
 *
 * Gate enforced before EVERY NFT marketplace action.
 * User must be KYC-verified and have a Paxos wallet before any action.
 *
 * Reads from the shared `user_compliance` view that is maintained by
 * the core platform's compliance service (Sumsub webhooks → core DB).
 *
 * Table: user_compliance (shared schema)
 *   user_id           UUID
 *   kyc_status        TEXT  (PENDING | APPROVED | REJECTED | EXPIRED)
 *   paxos_wallet_id   TEXT
 *   nft_wallet_address TEXT
 *   account_status    TEXT  (ACTIVE | SUSPENDED | CLOSED)
 *   user_index        INT   (HD wallet derivation index)
 */
export interface UserComplianceRecord {
  userId: string;
  kycStatus: string;
  paxosWalletId: string;
  nftWalletAddress: string;
  accountStatus: string;
  userIndex: number;
}

@Injectable()
export class ComplianceService {
  private readonly logger = new Logger(ComplianceService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Assert that a user is fully compliant before any NFT action.
   * Throws ForbiddenException with error code if not.
   */
  async assertReady(userId: string): Promise<UserComplianceRecord> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        bankingProfile: true,
        cryptoWallet: true,
      },
    });

    if (!user || !user.bankingProfile) {
      throw new ForbiddenException('CMP_000: User compliance record not found');
    }

    const { bankingProfile, cryptoWallet } = user;

    if (bankingProfile.frozen) {
      throw new ForbiddenException('CMP_003: Account is frozen');
    }
    if (bankingProfile.status === 'SUSPENDED') {
      throw new ForbiddenException('CMP_003: Account is suspended');
    }
    if (bankingProfile.status !== 'APPROVED') {
      this.logger.warn(`KYC gate blocked user ${userId}: status=${bankingProfile.status}`);
      throw new ForbiddenException('CMP_001: KYC verification required to access NFT marketplace');
    }
    if (!cryptoWallet || !cryptoWallet.paxosWalletId) {
      throw new ForbiddenException('CMP_002: Crypto wallet not initialized');
    }

    return {
      userId,
      kycStatus: bankingProfile.status,
      paxosWalletId: cryptoWallet.paxosWalletId,
      nftWalletAddress: cryptoWallet.nftWalletAddress || '',
      accountStatus: bankingProfile.status,
      userIndex: cryptoWallet.userIndex,
    };
  }

  async getOrCreateNftWallet(userId: string): Promise<string> {
    const record = await this.assertReady(userId);
    if (record.nftWalletAddress) {
      return record.nftWalletAddress;
    }
    throw new ForbiddenException('CMP_005: NFT wallet not initialized — contact support');
  }
}
