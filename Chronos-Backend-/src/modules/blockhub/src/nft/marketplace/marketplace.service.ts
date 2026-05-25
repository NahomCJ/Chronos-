import {
  Injectable, Logger, NotFoundException, BadRequestException,
  ForbiddenException, InternalServerErrorException,
} from '@nestjs/common';
import { CreateListingDto, BuyNftDto, BrowseListingsDto } from './marketplace.dto';
import { ComplianceService } from '../compliance/compliance.service';
import { NftService } from '../nft/nft.service';
import { PaxosService } from '../../providers/paxos/paxos.service';
import { ThirdwebService } from '../../providers/thirdweb/thirdweb.service';
import { RoyaltyService } from '../royalty/royalty.service';
import { AuditService } from '../audit/audit.service';
import { ConfigService } from '@nestjs/config';
import { NftEventGateway } from '../websocket/nft-event.gateway';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class MarketplaceService {
  private readonly logger = new Logger(MarketplaceService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly complianceService: ComplianceService,
    private readonly nftService: NftService,
    private readonly paxosService: PaxosService,
    private readonly thirdwebService: ThirdwebService,
    private readonly royaltyService: RoyaltyService,
    private readonly auditService: AuditService,
    private readonly configService: ConfigService,
    private readonly eventGateway: NftEventGateway,
  ) {}

  // ─── Browse listings ──────────────────────────────────────────────────────

  async browseListings(query: BrowseListingsDto) {
    const { collectionId, minPrice, maxPrice, currency, sort, page = 1, limit = 20 } = query;

    const where: Prisma.NftListingWhereInput = {
      status: 'ACTIVE',
    };

    if (collectionId) {
      where.nft = { contractId: collectionId };
    }
    if (currency) {
      where.priceCurrency = currency;
    }
    if (minPrice || maxPrice) {
      where.priceAmount = {
        gte: minPrice ? new Prisma.Decimal(minPrice) : undefined,
        lte: maxPrice ? new Prisma.Decimal(maxPrice) : undefined,
      };
    }

    const orderBy: any = {};
    if (sort === 'price_asc') orderBy.priceAmount = 'asc';
    else if (sort === 'price_desc') orderBy.priceAmount = 'desc';
    else orderBy.createdAt = 'desc';

    const [data, total] = await Promise.all([
      this.prisma.nftListing.findMany({
        where,
        include: { nft: { include: { contract: true } } },
        orderBy,
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.nftListing.count({ where }),
    ]);

    return { data, pagination: { page, limit, total } };
  }

  async getListingById(listingId: string) {
    const listing = await this.prisma.nftListing.findUnique({
      where: { id: listingId },
      include: { nft: { include: { contract: true } } },
    });
    if (!listing) throw new NotFoundException('NFT_005: Listing not found');
    return listing;
  }

  // ─── Create listing ───────────────────────────────────────────────────────

  async createListing(userId: string, dto: CreateListingDto): Promise<any> {
    // Compliance gate
    await this.complianceService.assertReady(userId);

    // Verify ownership
    const nft = await this.nftService.assertOwnership(dto.nftId, userId);

    // Check NFT is not already listed
    if (nft.status === 'LISTED') {
      throw new BadRequestException('NFT_002: NFT is already listed for sale');
    }

    const marketplaceAddress = this.configService.get<string>('platform.marketplaceAddress') ?? '';

    // Create on-chain listing via thirdweb
    let thirdwebListingId: string;
    try {
      thirdwebListingId = await this.thirdwebService.createListing(marketplaceAddress, {
        nftContractAddress: nft.contract.contractAddress,
        tokenId: nft.tokenId,
        pricePerToken: dto.priceAmount,
        currencyContractAddress: '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE', // native token
        startTimestamp: new Date(),
        endTimestamp: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
      });
    } catch (err) {
      this.logger.error('Failed to create on-chain listing', err);
      throw new InternalServerErrorException('Failed to create listing on-chain');
    }

    // Save listing + update NFT status
    const listing = await this.prisma.nftListing.create({
      data: {
        nftId: dto.nftId,
        sellerUserId: userId,
        priceAmount: new Prisma.Decimal(dto.priceAmount),
        priceCurrency: dto.priceCurrency,
        thirdwebListingId,
        status: 'ACTIVE',
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    });

    await this.nftService.updateNftStatus(dto.nftId, 'LISTED');

    await this.auditService.log({
      userId,
      event: 'NFT_LISTED',
      nftId: dto.nftId,
      payload: { listingId: listing.id, price: dto.priceAmount, currency: dto.priceCurrency },
    });

    // Broadcast to collection subscribers
    this.eventGateway.broadcastToCollection(nft.contractId, 'new_listing', {
      listingId: listing.id,
      nftId: nft.id,
      price: { amount: dto.priceAmount, currency: dto.priceCurrency },
    });

    return listing;
  }

  // ─── Cancel listing ───────────────────────────────────────────────────────

  async cancelListing(userId: string, listingId: string): Promise<{ message: string }> {
    const listing = await this.getListingById(listingId);

    if (listing.sellerUserId !== userId) {
      throw new ForbiddenException('You are not the seller of this listing');
    }
    if (listing.status !== 'ACTIVE') {
      throw new BadRequestException('Listing is not active');
    }

    const marketplaceAddress = this.configService.get<string>('platform.marketplaceAddress') ?? '';

    try {
      await this.thirdwebService.cancelListing(marketplaceAddress, listing.thirdwebListingId ?? '');
    } catch (err) {
      this.logger.warn(`Failed to cancel on-chain listing ${listingId}`, err);
      // Continue to cancel in DB even if on-chain fails
    }

    await this.prisma.nftListing.update({
      where: { id: listingId },
      data: { status: 'CANCELLED' },
    });
    await this.nftService.updateNftStatus(listing.nftId, 'MINTED');

    await this.auditService.log({
      userId,
      event: 'NFT_DELISTED',
      nftId: listing.nftId,
      payload: { listingId },
    });

    return { message: 'Listing cancelled. NFT returned to your portfolio.' };
  }

  // ─── Buy NFT — THE CRITICAL FLOW ─────────────────────────────────────────

  async buyNft(userId: string, dto: BuyNftDto): Promise<any> {
    // ── Step 1: Compliance gate ──────────────────────────────────────────
    const compliance = await this.complianceService.assertReady(userId);

    // ── Step 2: Fetch and validate listing ───────────────────────────────
    const listing = await this.getListingById(dto.listingId);
    if (listing.status !== 'ACTIVE') {
      throw new BadRequestException('NFT_006: Listing is no longer available');
    }
    if (listing.sellerUserId === userId) {
      throw new BadRequestException('NFT_007: Cannot purchase your own listing');
    }

    // ── Step 3: Fetch seller compliance record ───────────────────────────
    const sellerCompliance = await this.complianceService.assertReady(listing.sellerUserId!);

    // ── Step 4: Fee calculation ──────────────────────────────────────────
    const salePrice = parseFloat(listing.priceAmount.toString());
    const feeBps = this.configService.get<number>('platform.feeBps') ?? 250; // e.g., 250
    const platformFee = salePrice * (feeBps / 10000);
    const royaltyBps = listing.nft.contract.royaltyBps;
    const royaltyAmount = salePrice * (royaltyBps / 10000);
    const sellerNet = salePrice - platformFee - royaltyAmount;
    const buyerTotal = salePrice + platformFee;

    this.logger.log(
      `Buy NFT ${listing.nftId}: price=${salePrice} fee=${platformFee} royalty=${royaltyAmount} sellerNet=${sellerNet}`,
    );

    // ── Step 5: Check buyer Paxos balance ────────────────────────────────
    const balance = await this.paxosService.getAssetBalance(
      compliance.paxosWalletId,
      listing.priceCurrency,
    );
    if (balance < buyerTotal) {
      throw new BadRequestException(
        `NFT_008: Insufficient balance. Required: ${buyerTotal} ${listing.priceCurrency}`,
      );
    }

    // ── Step 6: Lock listing (prevent double-buy) ────────────────────────
    await this.prisma.nftListing.update({
      where: { id: dto.listingId },
      data: { status: 'SOLD' },
    });

    // ── Step 7: Debit buyer Paxos wallet ─────────────────────────────────
    let debitTx;
    try {
      debitTx = await this.paxosService.debit({
        walletId: compliance.paxosWalletId,
        amount: buyerTotal,
        currency: listing.priceCurrency,
        memo: `NFT purchase: ${listing.nft.name}`,
        idempotencyKey: `buy-${dto.listingId}-${userId}`,
      });
    } catch (err) {
      // Rollback listing status
      await this.prisma.nftListing.update({
        where: { id: dto.listingId },
        data: { status: 'ACTIVE' },
      });
      throw err;
    }

    // ── Step 8: Execute on-chain NFT transfer via thirdweb ───────────────
    let onchainTxHash: string;
    const marketplaceAddress = this.configService.get<string>('platform.marketplaceAddress') ?? '';

    try {
      onchainTxHash = await this.thirdwebService.executeBuy(marketplaceAddress, {
        listingId: listing.thirdwebListingId ?? '',
        buyerAddress: compliance.nftWalletAddress,
      });
    } catch (err) {
      this.logger.error('On-chain transfer failed — initiating refund', err);
      // Refund buyer
      await this.paxosService.credit({
        walletId: compliance.paxosWalletId,
        amount: buyerTotal,
        currency: listing.priceCurrency,
        memo: `Refund: NFT transfer failed — ${listing.nft.name}`,
        idempotencyKey: `refund-${dto.listingId}-${userId}`,
      });
      await this.prisma.nftListing.update({
        where: { id: dto.listingId },
        data: { status: 'ACTIVE' },
      });
      throw new InternalServerErrorException('NFT_010: On-chain transfer failed. Refund initiated.');
    }

    // ── Step 9: Credit seller Paxos wallet ───────────────────────────────
    const sellerCreditTx = await this.paxosService.credit({
      walletId: sellerCompliance.paxosWalletId,
      amount: sellerNet,
      currency: listing.priceCurrency,
      memo: `NFT sold: ${listing.nft.name}`,
      idempotencyKey: `credit-seller-${dto.listingId}`,
    });

    // ── Step 10: Pay creator royalty ─────────────────────────────────────
    if (royaltyAmount > 0) {
      await this.royaltyService.payRoyalty({
        nftTransactionId: null, // set after txn saved
        creatorUserId: listing.nft.creatorUserId,
        amount: royaltyAmount,
        currency: listing.priceCurrency,
        listingNft: listing.nft,
      });
    }

    // ── Step 11: Update DB ────────────────────────────────────────────────
    await this.nftService.updateNftOwner(listing.nftId, userId);

    const txRecord = await this.prisma.nftTransaction.create({
      data: {
        nftId: listing.nftId,
        listingId: listing.id,
        buyerUserId: userId,
        sellerUserId: listing.sellerUserId as string,
        salePrice: new Prisma.Decimal(salePrice),
        platformFee: new Prisma.Decimal(platformFee),
        royaltyAmount: new Prisma.Decimal(royaltyAmount),
        sellerNet: new Prisma.Decimal(sellerNet),
        currency: listing.priceCurrency,
        paxosDebitTxId: debitTx.id,
        paxosCreditTxId: sellerCreditTx.id,
        onchainTxHash,
        status: 'COMPLETED',
      },
    });
    return txRecord;
  }

  // ─── User listings / purchases ────────────────────────────────────────────

  async getMyListings(userId: string) {
    const [active, sold, cancelled] = await Promise.all([
      this.prisma.nftListing.findMany({ where: { sellerUserId: userId, status: 'ACTIVE' }, include: { nft: true } }),
      this.prisma.nftListing.findMany({ where: { sellerUserId: userId, status: 'SOLD' }, include: { nft: true } }),
      this.prisma.nftListing.findMany({ where: { sellerUserId: userId, status: 'CANCELLED' }, include: { nft: true } }),
    ]);
    return { active, sold, cancelled };
  }

  async getMyPurchases(userId: string, page = 1, limit = 20) {
    const [data, total] = await Promise.all([
      this.prisma.nftTransaction.findMany({
        where: { buyerUserId: userId, status: 'COMPLETED' },
        include: { nft: true },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.nftTransaction.count({
        where: { buyerUserId: userId, status: 'COMPLETED' },
      }),
    ]);
    return { data, pagination: { page, limit, total } };
  }
}
