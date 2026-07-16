import {
  Injectable, NotFoundException,
} from '@nestjs/common';
import { BrowseNftsDto } from './nft.dto';
import { NftStatus } from '../../common/types';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class NftService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  // ─── Browse NFTs ──────────────────────────────────────────────────────────

  async browseNfts(query: BrowseNftsDto) {
    const { collectionId, status, sort, page = 1, limit = 20 } = query;

    const where: Prisma.NftWhereInput = {};
    if (collectionId) where.contractId = collectionId;
    if (status) where.status = status as any;

    const orderBy: any = {};
    if (sort === 'trending') orderBy.updatedAt = 'desc';
    else orderBy.createdAt = 'desc';

    const [data, total] = await Promise.all([
      this.prisma.nft.findMany({
        where,
        include: {
          contract: true,
          listings: { where: { status: 'ACTIVE' } },
        },
        orderBy,
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.nft.count({ where }),
    ]);

    return { data, pagination: { page, limit, total } };
  }

  // ─── Get single NFT ───────────────────────────────────────────────────────

  async getNftById(id: string) {
    const nft = await this.prisma.nft.findUnique({
      where: { id },
      include: { contract: true, listings: true },
    });
    if (!nft) throw new NotFoundException('NFT_001: NFT not found');
    return nft;
  }

  // ─── Collections ──────────────────────────────────────────────────────────

  async getCollections(page = 1, limit = 20) {
    const [data, total] = await Promise.all([
      this.prisma.nftContract.findMany({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.nftContract.count({ where: { isActive: true } }),
    ]);
    const enriched = await Promise.all(
      data.map(async (c) => ({ ...c, ...(await this.computeCollectionStats(c.id, 24)) })),
    );
    return { data: enriched, pagination: { page, limit, total } };
  }

  async getCollectionById(id: string) {
    const col = await this.prisma.nftContract.findUnique({ where: { id }, include: { nfts: true } });
    if (!col) throw new NotFoundException('NFT_004: Collection not found');
    const stats = await this.computeCollectionStats(id, 24);
    return { ...col, ...stats };
  }

  // ─── Collection market stats (featured / trending / top-volume) ──────────
  // Computed on the fly from NftListing/NftTransaction — there is no
  // snapshot table yet, so "change" is a real volume-over-volume
  // comparison (current window vs. the preceding window of equal length),
  // not a floor-price history (that would need periodic snapshots).
  // Fields are flattened onto the collection object (not nested) to match
  // what the Flutter NftCollectionModel already parses: floorPrice/volume/
  // itemCount/imageUrl at the top level.

  private async computeCollectionStats(contractId: string, windowHours: number) {
    const now = new Date();
    const windowStart = new Date(now.getTime() - windowHours * 60 * 60 * 1000);
    const prevWindowStart = new Date(windowStart.getTime() - windowHours * 60 * 60 * 1000);

    const [floorAgg, ownerRows, itemCount, currentVolumeAgg, previousVolumeAgg] = await Promise.all([
      this.prisma.nftListing.aggregate({
        where: { status: 'ACTIVE', nft: { contractId } },
        _min: { priceAmount: true },
      }),
      this.prisma.nft.findMany({
        where: { contractId },
        select: { ownerUserId: true },
        distinct: ['ownerUserId'],
      }),
      this.prisma.nft.count({ where: { contractId } }),
      this.prisma.nftTransaction.aggregate({
        where: { status: 'COMPLETED', createdAt: { gte: windowStart }, nft: { contractId } },
        _sum: { salePrice: true },
      }),
      this.prisma.nftTransaction.aggregate({
        where: {
          status: 'COMPLETED',
          createdAt: { gte: prevWindowStart, lt: windowStart },
          nft: { contractId },
        },
        _sum: { salePrice: true },
      }),
    ]);

    const volume = currentVolumeAgg._sum.salePrice ? Number(currentVolumeAgg._sum.salePrice) : 0;
    const prevVolume = previousVolumeAgg._sum.salePrice ? Number(previousVolumeAgg._sum.salePrice) : 0;
    const volumeChangePct =
      prevVolume > 0 ? ((volume - prevVolume) / prevVolume) * 100 : volume > 0 ? 100 : 0;

    return {
      floorPrice: floorAgg._min.priceAmount ? Number(floorAgg._min.priceAmount) : 0,
      ownerCount: ownerRows.length,
      itemCount,
      volume,
      volumeChangePct: Number(volumeChangePct.toFixed(2)),
    };
  }

  /** GET /nft/collections/featured — admin-curated collection, or the highest-volume one if none is marked */
  async getFeaturedCollection() {
    const featured =
      (await this.prisma.nftContract.findFirst({
        where: { isActive: true, isFeatured: true },
        orderBy: { createdAt: 'desc' },
      })) ??
      (await this.prisma.nftContract.findFirst({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
      }));
    if (!featured) return null;
    const stats = await this.computeCollectionStats(featured.id, 24);
    return { ...featured, ...stats };
  }

  /** GET /nft/collections/trending — collections ranked by 24h volume */
  async getTrendingCollections(category?: string, limit = 10) {
    const where: Prisma.NftContractWhereInput = { isActive: true };
    if (category) where.category = category;

    const collections = await this.prisma.nftContract.findMany({ where });
    const withStats = await Promise.all(
      collections.map(async (c) => ({ ...c, ...(await this.computeCollectionStats(c.id, 24)) })),
    );
    return withStats.sort((a, b) => b.volume - a.volume).slice(0, limit);
  }

  /** GET /nft/collections/top-volume — collections ranked by volume over a selectable period */
  async getTopVolumeCollections(period: '24h' | '7d' = '24h', category?: string, limit = 10) {
    const windowHours = period === '7d' ? 24 * 7 : 24;
    const where: Prisma.NftContractWhereInput = { isActive: true };
    if (category) where.category = category;

    const collections = await this.prisma.nftContract.findMany({ where });
    const withStats = await Promise.all(
      collections.map(async (c) => ({ ...c, ...(await this.computeCollectionStats(c.id, windowHours)) })),
    );
    return withStats
      .sort((a, b) => b.volume - a.volume)
      .slice(0, limit)
      .map((c, i) => ({ rank: i + 1, ...c }));
  }

  /** GET /nft/drops/new — most recently minted NFTs, optionally filtered by collection category */
  async getNewDrops(category?: string, limit = 10) {
    const where: Prisma.NftWhereInput = {
      mintedAt: { not: null },
      status: { in: ['MINTED', 'LISTED'] },
    };
    if (category) where.contract = { category };

    const nfts = await this.prisma.nft.findMany({
      where,
      include: { contract: true, listings: { where: { status: 'ACTIVE' } } },
      orderBy: { mintedAt: 'desc' },
      take: limit,
    });

    return nfts.map((n) => ({
      id: n.id,
      name: n.name,
      imageUrl: n.imageUrl,
      collectionName: n.contract.name,
      category: n.contract.category,
      price: n.listings[0]?.priceAmount ?? 0,
      currency: n.listings[0]?.priceCurrency ?? 'ETH',
      mintedAt: n.mintedAt,
    }));
  }

  // ─── Ownership history ────────────────────────────────────────────────────

  async getOwnershipHistory(nftId: string) {
    await this.getNftById(nftId); // throws if not found
    return this.prisma.nftTransaction.findMany({
      where: { nftId, status: 'COMPLETED' },
      orderBy: { createdAt: 'asc' },
    });
  }

  // ─── Favorite ─────────────────────────────────────────────────────────────

  async toggleFavorite(nftId: string, userId: string): Promise<{ favorited: boolean }> {
    const nft = await this.getNftById(nftId);
    const favorites: string[] = (nft.isFavoritedBy as string[]) || [];
    const idx = favorites.indexOf(userId);

    if (idx === -1) {
      favorites.push(userId);
    } else {
      favorites.splice(idx, 1);
    }

    await this.prisma.nft.update({
      where: { id: nftId },
      data: { isFavoritedBy: favorites },
    });
    return { favorited: idx === -1 };
  }

  // ─── Internal helpers (used by minting/marketplace services) ─────────────

  async createNftRecord(data: any) {
    return this.prisma.nft.create({ data });
  }

  async updateNftOwner(nftId: string, newOwnerId: string): Promise<void> {
    await this.prisma.nft.update({
      where: { id: nftId },
      data: { ownerUserId: newOwnerId, status: 'SOLD' },
    });
  }

  async updateNftStatus(nftId: string, status: NftStatus): Promise<void> {
    await this.prisma.nft.update({
      where: { id: nftId },
      data: { status: status as any },
    });
  }

  async assertOwnership(nftId: string, userId: string) {
    const nft = await this.getNftById(nftId);
    if (nft.ownerUserId !== userId) {
      throw new NotFoundException('NFT_003: You do not own this NFT');
    }
    return nft;
  }

  async createContractRecord(data: any) {
    return this.prisma.nftContract.create({ data });
  }
}
