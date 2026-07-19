import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PaxosService } from '../../providers/paxos/paxos.service';
import { AuditService } from '../audit/audit.service';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';

interface PayRoyaltyParams {
  nftTransactionId: string | null;
  creatorUserId: string;
  amount: number;
  currency: string;
  listingNft: { id: string; name: string };
}

@Injectable()
export class RoyaltyService {
  private readonly logger = new Logger(RoyaltyService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly paxosService: PaxosService,
    private readonly auditService: AuditService,
  ) {}

  /**
   * Credit the NFT creator's Paxos wallet with their royalty share.
   * Called as part of the NFT purchase flow.
   */
  async payRoyalty(params: PayRoyaltyParams): Promise<any> {
    const { creatorUserId, amount, currency, listingNft } = params;

    this.logger.log(`Paying royalty: ${amount} ${currency} to creator ${creatorUserId}`);

    const creatorWalletId = await this.getCreatorPaxosWallet(creatorUserId);

    const tx = await this.paxosService.credit({
      walletId: creatorWalletId,
      amount,
      currency,
      memo: `Royalty: ${listingNft.name}`,
      idempotencyKey: `royalty-${params.nftTransactionId || Date.now()}-${creatorUserId}`,
    });

    const record = await this.prisma.royaltyPayment.create({
      data: {
        nftTransactionId: params.nftTransactionId,
        creatorUserId,
        amount: new Prisma.Decimal(amount),
        currency,
        paxosTxId: tx.id,
        paidAt: new Date(),
      },
    });

    await this.auditService.log({
      userId: creatorUserId,
      event: 'ROYALTY_PAID',
      nftId: listingNft.id,
      payload: { amount, currency, paxosTxId: tx.id },
    });

    return record;
  }

  async getCreatorRoyaltyHistory(creatorUserId: string, page = 1, limit = 20) {
    const [data, total] = await Promise.all([
      this.prisma.royaltyPayment.findMany({
        where: { creatorUserId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.royaltyPayment.count({
        where: { creatorUserId },
      }),
    ]);
    return { data, pagination: { page, limit, total } };
  }

  /**
   * Looks up the creator's Paxos wallet ID via the shared user_compliance view.
   */
  private async getCreatorPaxosWallet(creatorUserId: string): Promise<string> {
    const wallet = await this.prisma.cryptoWallet.findUnique({
      where: { userId: creatorUserId },
    });
    if (!wallet?.paxosWalletId) {
      throw new NotFoundException(`Creator wallet not found for user ${creatorUserId}`);
    }
    return wallet.paxosWalletId;
  }
}
