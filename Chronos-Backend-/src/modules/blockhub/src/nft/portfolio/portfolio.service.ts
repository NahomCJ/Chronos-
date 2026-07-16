import { Injectable } from '@nestjs/common';
import { ComplianceService } from '../compliance/compliance.service';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class PortfolioService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly complianceService: ComplianceService,
  ) {}

  /**
   * Get all NFTs currently owned by the user.
   */
  async getNftHoldings(userId: string) {
    await this.complianceService.assertReady(userId);

    const nfts = await this.prisma.nft.findMany({
      where: { ownerUserId: userId },
      include: {
        contract: true,
        listings: { where: { status: 'ACTIVE' } },
      },
      orderBy: { createdAt: 'desc' },
    });

    const enriched = await Promise.all(
      nfts.map(async (nft) => {
        const acquisitionTxn = await this.prisma.nftTransaction.findFirst({
          where: { nftId: nft.id, buyerUserId: userId, status: 'COMPLETED' },
          orderBy: { createdAt: 'desc' },
        });

        const activeListings = nft.listings || [];

        return {
          id: nft.id,
          name: nft.name,
          description: nft.description,
          imageUrl: nft.imageUrl,
          status: nft.status,
          collection: {
            id: nft.contract?.id,
            name: nft.contract?.name,
            contractAddress: nft.contract?.contractAddress,
          },
          acquiredAt: acquisitionTxn?.createdAt ?? nft.mintedAt,
          acquiredPrice: acquisitionTxn
            ? { amount: acquisitionTxn.salePrice, currency: acquisitionTxn.currency }
            : null,
          currentListing: activeListings[0]
            ? { amount: activeListings[0].priceAmount, currency: activeListings[0].priceCurrency }
            : null,
        };
      }),
    );

    return {
      totalNfts: nfts.length,
      nfts: enriched,
    };
  }

  /**
   * Get portfolio summary: NFT count, estimated value, transaction history.
   */
  async getPortfolioSummary(userId: string) {
    await this.complianceService.assertReady(userId);

    const [ownedNfts, purchased, sold, royaltiesEarned] = await Promise.all([
      this.prisma.nft.count({ where: { ownerUserId: userId } }),
      this.prisma.nftTransaction.count({ where: { buyerUserId: userId, status: 'COMPLETED' } }),
      this.prisma.nftTransaction.count({ where: { sellerUserId: userId, status: 'COMPLETED' } }),
      this.prisma.royaltyPayment.groupBy({
        by: ['currency'],
        where: { creatorUserId: userId },
        _sum: { amount: true },
      }),
    ]);

    return {
      ownedNfts,
      totalPurchases: purchased,
      totalSales: sold,
      royaltiesEarned: royaltiesEarned.map(r => ({ currency: r.currency, total: r._sum.amount })),
    };
  }

  /**
   * Get creator royalty history.
   */
  async getRoyaltyHistory(userId: string, page = 1, limit = 20) {
    const [data, total] = await Promise.all([
      this.prisma.royaltyPayment.findMany({
        where: { creatorUserId: userId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.royaltyPayment.count({
        where: { creatorUserId: userId },
      }),
    ]);
    return { data, pagination: { page, limit, total } };
  }
}
