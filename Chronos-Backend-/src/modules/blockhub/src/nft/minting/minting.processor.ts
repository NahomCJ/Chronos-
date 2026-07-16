import { Process, Processor } from '@nestjs/bull';
import { Logger } from '@nestjs/common';
import { NftService } from '../nft/nft.service';
import { ThirdwebService } from '../../providers/thirdweb/thirdweb.service';
import { AuditService } from '../audit/audit.service';
import { NotificationService } from '../notification/notification.service';
import { MINT_QUEUE } from './minting.service';
import { PrismaService } from '../../prisma/prisma.service';

interface MintJobData {
  jobId: string;
  userId: string;
  userWalletAddress: string;
  contractAddress: string;
  collectionId: string;
  name: string;
  description: string;
  attributes: Record<string, any>[];
  royaltyBps: number;
  imageBuffer: Buffer;
  imageMimetype: string;
  imageOriginalname: string;
}

@Processor(MINT_QUEUE)
export class MintingProcessor {
  private readonly logger = new Logger(MintingProcessor.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly nftService: NftService,
    private readonly thirdwebService: ThirdwebService,
    private readonly auditService: AuditService,
    private readonly notificationService: NotificationService,
  ) {}

  @Process('mint')
  async handleMint(job: { data: MintJobData }): Promise<void> {
    const {
      jobId, userId, userWalletAddress, contractAddress,
      collectionId, name, description, attributes,
      imageBuffer, imageOriginalname,
    } = job.data;

    this.logger.log(`Processing mint job ${jobId}`);

    try {
      // ─── Step 1: Upload asset to IPFS ─────────────────────────────────
      await this.updateStatus(jobId, 'UPLOADING_IPFS');
      const buffer = Buffer.from(imageBuffer);
      const imageUri = await this.thirdwebService.uploadAssetToIPFS(buffer, imageOriginalname);

      // ─── Step 2: Upload metadata to IPFS ─────────────────────────────
      const metadataUri = await this.thirdwebService.uploadMetadataToIPFS({
        name,
        description,
        image: imageUri,
        attributes,
      });
      await this.prisma.nftMintRecord.update({
        where: { jobId },
        data: { ipfsAsset: imageUri, ipfsMetadata: metadataUri },
      });

      // ─── Step 3: Mint on-chain via thirdweb ───────────────────────────
      await this.updateStatus(jobId, 'MINTING');
      const { transactionHash, tokenId } = await this.thirdwebService.mintNFT({
        contractAddress,
        toAddress: userWalletAddress,
        name,
        description,
        imageUri,
        attributes,
      });

      // ─── Step 4: Save NFT record in DB ────────────────────────────────
      const imageHttpUrl = this.thirdwebService.ipfsToHttp(imageUri);
      const nft = await this.nftService.createNftRecord({
        tokenId,
        contractId: collectionId,
        ownerUserId: userId,
        creatorUserId: userId,
        name,
        description,
        imageUrl: imageHttpUrl,
        metadataUrl: metadataUri,
        attributes,
        status: 'MINTED',
        mintedAt: new Date(),
      });

      // ─── Step 5: Update mint record ───────────────────────────────────
      await this.prisma.nftMintRecord.update({
        where: { jobId },
        data: {
          nftId: nft.id,
          onchainTxHash: transactionHash,
          status: 'COMPLETED',
        },
      });

      // ─── Step 6: Audit log + WebSocket notification ───────────────────
      await this.auditService.log({
        userId,
        event: 'NFT_MINTED',
        nftId: nft.id,
        payload: { jobId, tokenId, transactionHash, contractAddress },
      });

      await this.notificationService.send(userId, 'mint_complete', {
        jobId,
        nftId: nft.id,
        tokenId,
        transactionHash,
        name,
        imageUrl: imageHttpUrl,
      });

      this.logger.log(`Mint complete — NFT ${nft.id}, token #${tokenId}, tx: ${transactionHash}`);

    } catch (err) {
      this.logger.error(`Mint job ${jobId} failed`, err);
      await this.prisma.nftMintRecord.update({
        where: { jobId },
        data: { status: 'FAILED', errorMessage: (err as any)?.message ?? 'Unknown error' },
      });
      throw err;
    }
  }

  private async updateStatus(jobId: string, status: string): Promise<void> {
    await this.prisma.nftMintRecord.update({
      where: { jobId },
      data: { status: status as any },
    });
  }
}
