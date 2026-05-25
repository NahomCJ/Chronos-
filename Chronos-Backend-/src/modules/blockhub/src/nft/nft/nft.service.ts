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
    return { data, pagination: { page, limit, total } };
  }

  async getCollectionById(id: string) {
    const col = await this.prisma.nftContract.findUnique({ where: { id }, include: { nfts: true } });
    if (!col) throw new NotFoundException('NFT_004: Collection not found');
    return col;
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
