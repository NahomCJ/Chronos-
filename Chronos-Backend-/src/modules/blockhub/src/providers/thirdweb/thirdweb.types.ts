export interface MintNFTParams {
  contractAddress: string;
  toAddress: string;
  name: string;
  description: string;
  imageUri: string;
  attributes?: Record<string, any>[];
}

export interface CreateListingParams {
  nftContractAddress: string;
  tokenId: string;
  pricePerToken: string;  // in wei as string
  currencyContractAddress: string;
  startTimestamp: Date;
  endTimestamp?: Date;
}

export interface BuyListingParams {
  listingId: string;
  buyerAddress: string;
  quantity?: number;
}

export interface DeployCollectionParams {
  name: string;
  symbol: string;
  royaltyRecipient: string;
  royaltyBps: number;
  primarySaleRecipient: string;
}

export interface MintResult {
  transactionHash: string;
  tokenId: string;
}

export interface DeployResult {
  contractAddress: string;
  transactionHash: string;
}
