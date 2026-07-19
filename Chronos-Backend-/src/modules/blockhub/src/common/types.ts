export type PaginatedResponse<T> = {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
};

export type NftStatus = 'MINTED' | 'LISTED' | 'SOLD' | 'BURNED';

export type NftStandard = 'ERC721' | 'ERC1155';

export type ListingStatus = 'ACTIVE' | 'SOLD' | 'CANCELLED' | 'EXPIRED';

export type TransactionStatus = 'PENDING' | 'COMPLETED' | 'FAILED' | 'CANCELLED';

export type MintJobStatus = 'PENDING' | 'PROCESSING' | 'COMPLETED' | 'FAILED';

export type NftAuditEvent = 
  | 'NFT_MINTED'
  | 'NFT_LISTED'
  | 'NFT_DELISTED'
  | 'NFT_PURCHASED'
  | 'NFT_SOLD'
  | 'ROYALTY_PAID'
  | 'COLLECTION_DEPLOYED'
  | string;

export interface AuthenticatedUser {
  id: string;
  email: string;
  role: string;
}
