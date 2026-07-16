import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  MintNFTParams, CreateListingParams, BuyListingParams,
  DeployCollectionParams, MintResult, DeployResult,
} from './thirdweb.types';

/**
 * ThirdwebService
 *
 * Wraps all on-chain NFT operations via the thirdweb SDK.
 * All signing is done server-side using the platform backend wallet.
 * No private keys are ever exposed to the frontend.
 *
 * NOTE: thirdweb SDK is dynamically imported to avoid ESM issues at startup.
 * In production you can switch to a direct import once the build pipeline is configured.
 */
@Injectable()
export class ThirdwebService {
  private readonly logger = new Logger(ThirdwebService.name);
  private sdk: any; // ThirdwebSDK instance
  private storage: any; // ThirdwebStorage instance
  private chain: string;
  private ipfsGateway: string;

  constructor(private readonly configService: ConfigService) {
    this.chain = this.configService.get<string>('thirdweb.chain', 'sepolia');
    this.ipfsGateway = this.configService.get<string>('ipfsGateway', 'https://gateway.ipfs.io/ipfs/');
  }

  async onModuleInit() {
    try {
      const privateKey = await this.resolveBackendWalletKey();
      const clientId = this.configService.get<string>('thirdweb.clientId');
      const secretKey = this.configService.get<string>('thirdweb.secretKey');

      const { ThirdwebSDK } = await import('@thirdweb-dev/sdk');
      const { ThirdwebStorage } = await import('@thirdweb-dev/storage');

      this.sdk = ThirdwebSDK.fromPrivateKey(privateKey, this.chain, {
        clientId,
        secretKey,
      });

      this.storage = new ThirdwebStorage({ clientId, secretKey });

      this.logger.log(`ThirdwebService ready — chain: ${this.chain}`);
    } catch (err) {
      this.logger.warn('ThirdwebService: wallet key not configured — NFT minting disabled. Set THIRDWEB_BACKEND_WALLET_KEY to enable.');
      this.sdk = null;
      this.storage = null;
    }
  }

  private assertReady(): void {
    if (!this.sdk || !this.storage) {
      const { ServiceUnavailableException } = require('@nestjs/common');
      throw new ServiceUnavailableException('NFT minting is not yet available. Thirdweb integration coming soon.');
    }
  }

  // ─── Private key resolution ────────────────────────────────────────────────

  private async resolveBackendWalletKey(): Promise<string> {
    const nodeEnv = this.configService.get<string>('nodeEnv');

    // In dev, fall back to env var directly
    if (nodeEnv !== 'production') {
      const key = process.env.THIRDWEB_BACKEND_WALLET_KEY;
      if (key) return key;
    }

    // In production, fetch from AWS Secrets Manager
    const secretName = this.configService.get<string>('thirdweb.walletSecretName');
    const region = this.configService.get<string>('aws.region');
    const { SecretsManagerClient, GetSecretValueCommand } = await import('@aws-sdk/client-secrets-manager' as string);
    const client = new SecretsManagerClient({ region });
    const res = await client.send(new GetSecretValueCommand({ SecretId: secretName }));
    const parsed = JSON.parse(res.SecretString);
    return parsed.private_key;
  }

  // ─── IPFS ─────────────────────────────────────────────────────────────────

  /**
   * Upload raw bytes (image/video) to IPFS via thirdweb.
   * Returns the ipfs:// URI.
   */
  async uploadAssetToIPFS(buffer: Buffer, filename?: string): Promise<string> {
    this.assertReady();
    const file = {
      name: filename || 'asset',
      data: buffer,
    };
    const uri = await this.storage.upload(file);
    this.logger.debug(`Uploaded asset to IPFS: ${uri}`);
    return uri;
  }

  /**
   * Upload a JSON metadata object to IPFS.
   * Returns the ipfs:// URI.
   */
  async uploadMetadataToIPFS(metadata: Record<string, any>): Promise<string> {
    this.assertReady();
    const uri = await this.storage.upload(metadata);
    this.logger.debug(`Uploaded metadata to IPFS: ${uri}`);
    return uri;
  }

  /**
   * Convert ipfs:// URI to HTTP gateway URL.
   */
  ipfsToHttp(ipfsUri: string): string {
    if (!ipfsUri) return '';
    return ipfsUri.replace('ipfs://', this.ipfsGateway);
  }

  // ─── NFT Collection ───────────────────────────────────────────────────────

  /**
   * Deploy a new ERC-721 NFT Collection contract via thirdweb.
   */
  async deployNftCollection(params: DeployCollectionParams): Promise<DeployResult> {
    this.assertReady();
    this.logger.log(`Deploying NFT Collection: ${params.name}`);
    const address = await this.sdk.deployer.deployNFTCollection({
      name: params.name,
      symbol: params.symbol,
      primary_sale_recipient: params.primarySaleRecipient,
      fee_recipient: params.royaltyRecipient,
      seller_fee_basis_points: params.royaltyBps,
    });

    return {
      contractAddress: address,
      transactionHash: '', // thirdweb deployer returns address directly
    };
  }

  /**
   * Mint an NFT to a user's custodial wallet address.
   */
  async mintNFT(params: MintNFTParams): Promise<MintResult> {
    this.assertReady();
    this.logger.log(`Minting NFT "${params.name}" to ${params.toAddress}`);
    const contract = await this.sdk.getContract(params.contractAddress, 'nft-collection');

    const tx = await contract.mintTo(params.toAddress, {
      name: params.name,
      description: params.description,
      image: params.imageUri,
      attributes: params.attributes || [],
    });

    const tokenId = tx.id?.toString() ?? '0';
    const txHash = tx.receipt?.transactionHash ?? '';

    this.logger.log(`✅ Minted token #${tokenId} — tx: ${txHash}`);
    return { transactionHash: txHash, tokenId };
  }

  /**
   * Transfer an NFT between two custodial wallet addresses.
   */
  async transferNFT(
    contractAddress: string,
    toAddress: string,
    tokenId: string,
  ): Promise<string> {
    this.assertReady();
    this.logger.log(`Transferring token #${tokenId} → ${toAddress}`);
    const contract = await this.sdk.getContract(contractAddress, 'nft-collection');
    const tx = await contract.transfer(toAddress, tokenId);
    return tx.receipt?.transactionHash ?? '';
  }

  // ─── Marketplace ──────────────────────────────────────────────────────────

  /**
   * Create a fixed-price listing on the platform marketplace contract.
   */
  async createListing(
    marketplaceAddress: string,
    params: CreateListingParams,
  ): Promise<string> {
    this.assertReady();
    this.logger.log(`Creating listing for token #${params.tokenId}`);
    const marketplace = await this.sdk.getContract(marketplaceAddress, 'marketplace-v3');

    const tx = await marketplace.directListings.createListing({
      assetContractAddress: params.nftContractAddress,
      tokenId: params.tokenId,
      pricePerToken: params.pricePerToken,
      currencyContractAddress: params.currencyContractAddress,
      startTimestamp: params.startTimestamp,
      endTimestamp: params.endTimestamp,
      quantity: 1,
    });

    const listingId = tx.id?.toString() ?? '';
    this.logger.log(`✅ Listing created: ${listingId}`);
    return listingId;
  }

  /**
   * Execute a buy on the marketplace contract.
   * Called after Paxos payment has been confirmed.
   */
  async executeBuy(
    marketplaceAddress: string,
    params: BuyListingParams,
  ): Promise<string> {
    this.assertReady();
    this.logger.log(`Executing on-chain buy for listing ${params.listingId}`);
    const marketplace = await this.sdk.getContract(marketplaceAddress, 'marketplace-v3');

    const tx = await marketplace.directListings.buyFromListing(
      params.listingId,
      params.buyerAddress,
      params.quantity ?? 1,
    );

    const txHash = tx.receipt?.transactionHash ?? '';
    this.logger.log(`✅ On-chain buy complete — tx: ${txHash}`);
    return txHash;
  }

  /**
   * Cancel a listing on the marketplace contract.
   */
  async cancelListing(marketplaceAddress: string, listingId: string): Promise<void> {
    this.assertReady();
    this.logger.log(`Cancelling listing: ${listingId}`);
    const marketplace = await this.sdk.getContract(marketplaceAddress, 'marketplace-v3');
    await marketplace.directListings.cancelListing(listingId);
  }

  // ─── HD Wallet helpers ────────────────────────────────────────────────────

  /**
   * Derive a deterministic on-chain wallet address for a user.
   * Uses HD wallet derivation from master mnemonic stored in Secrets Manager.
   * Call once on user account creation and store the resulting address.
   */
  async deriveUserWalletAddress(userIndex: number): Promise<string> {
    this.assertReady();
    const { ethers } = await import('ethers');
    const mnemonic = await this.resolveMasterMnemonic();
    const hdNode = ethers.utils.HDNode.fromMnemonic(mnemonic);
    const userWallet = hdNode.derivePath(`m/44'/60'/0'/0/${userIndex}`);
    return userWallet.address;
  }

  private async resolveMasterMnemonic(): Promise<string> {
    const nodeEnv = this.configService.get<string>('nodeEnv');
    if (nodeEnv !== 'production') {
      const mnemonic = process.env.PLATFORM_MASTER_MNEMONIC;
      if (mnemonic) return mnemonic;
    }
    const secretName = this.configService.get<string>('thirdweb.hdWalletSecretName');
    const region = this.configService.get<string>('aws.region');
    const { SecretsManagerClient, GetSecretValueCommand } = await import('@aws-sdk/client-secrets-manager' as string);
    const client = new SecretsManagerClient({ region });
    const res = await client.send(new GetSecretValueCommand({ SecretId: secretName }));
    return JSON.parse(res.SecretString).mnemonic;
  }
}
