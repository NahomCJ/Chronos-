import {
  Injectable, Logger, NotFoundException, BadRequestException,
} from '@nestjs/common';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { v4 as uuid } from 'uuid';
import { MintNftDto, DeployCollectionDto } from './minting.dto';
import { ComplianceService } from '../compliance/compliance.service';
import { NftService } from '../nft/nft.service';
import { ThirdwebService } from '../../providers/thirdweb/thirdweb.service';
import { AuditService } from '../audit/audit.service';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';

export const MINT_QUEUE = 'mint-queue';

@Injectable()
export class MintingService {
  private readonly logger = new Logger(MintingService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly complianceService: ComplianceService,
    private readonly nftService: NftService,
    private readonly thirdwebService: ThirdwebService,
    private readonly auditService: AuditService,
    private readonly configService: ConfigService,
    @InjectQueue(MINT_QUEUE) private readonly mintQueue: Queue,
  ) {}

  async initiateMint(
    userId: string,
    dto: MintNftDto,
    imageFile: Express.Multer.File,
  ): Promise<{ mintJobId: string; status: string }> {
    const compliance = await this.complianceService.assertReady(userId);

    const collection = await this.nftService.getCollectionById(dto.collectionId);
    if (!collection.isActive) {
      throw new BadRequestException('Collection is not active');
    }

    const maxRoyaltyBps = this.configService.get<number>('platform.maxCreatorRoyaltyBps') ?? 2000;
    const royaltyBps = Math.round((dto.royaltyPercent ?? 5) * 100);
    if (royaltyBps > maxRoyaltyBps) {
      throw new BadRequestException(`Royalty cannot exceed ${maxRoyaltyBps / 100}%`);
    }

    const jobId = uuid();
    await this.prisma.nftMintRecord.create({
      data: {
        jobId,
        creatorUserId: userId,
        status: 'PENDING',
        mintFee: new Prisma.Decimal(0),
      },
    });

    await this.mintQueue.add(
      'mint',
      {
        jobId,
        userId,
        userWalletAddress: compliance.nftWalletAddress,
        contractAddress: collection.contractAddress,
        collectionId: dto.collectionId,
        name: dto.name,
        description: dto.description ?? '',
        attributes: dto.attributes ?? [],
        royaltyBps,
        imageBuffer: imageFile.buffer,
        imageMimetype: imageFile.mimetype,
        imageOriginalname: imageFile.originalname,
      },
      {
        attempts: 3,
        backoff: { type: 'exponential', delay: 5000 },
        removeOnComplete: 100,
        removeOnFail: 50,
      },
    );

    this.logger.log(`Mint job ${jobId} queued for user ${userId}`);
    return { mintJobId: jobId, status: 'PENDING' };
  }

  async getMintStatus(jobId: string, requestingUserId: string) {
    const record = await this.prisma.nftMintRecord.findUnique({ where: { jobId } });
    if (!record) throw new NotFoundException('Mint job not found');
    if (record.creatorUserId !== requestingUserId) throw new NotFoundException('Mint job not found');
    return record;
  }

  async deployCollection(userId: string, dto: DeployCollectionDto) {
    await this.complianceService.assertReady(userId);

    const royaltyBps = Math.round((dto.royaltyPercent ?? 5) * 100);
    const revenueWallet = this.configService.get<string>('platform.revenueWallet') ?? '';
    const compliance = await this.complianceService.assertReady(userId);

    const result = await this.thirdwebService.deployNftCollection({
      name: dto.name,
      symbol: dto.symbol,
      royaltyRecipient: compliance.nftWalletAddress || revenueWallet,
      royaltyBps,
      primarySaleRecipient: revenueWallet,
    });

    const contract = await this.nftService.createContractRecord({
      name: dto.name,
      symbol: dto.symbol,
      standard: 'ERC721',
      contractAddress: result.contractAddress,
      chain: this.configService.get<string>('thirdweb.chain'),
      ownerUserId: userId,
      royaltyBps,
      deployedAt: new Date(),
    });

    await this.auditService.log({
      userId,
      event: 'COLLECTION_DEPLOYED',
      payload: { contractAddress: result.contractAddress, name: dto.name },
    });

    return contract;
  }
}
