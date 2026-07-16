import {
  IsUUID, IsString, IsNotEmpty, IsOptional,
  IsEnum, IsNumber, Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateListingDto {
  @IsUUID()
  nftId!: string;

  @IsString()
  @IsNotEmpty()
  priceAmount!: string;  // String to preserve precision (e.g., "0.5")

  @IsString()
  @IsEnum(['ETH', 'MATIC', 'USDT', 'USDC'])
  priceCurrency!: string;
}

export class BuyNftDto {
  @IsUUID()
  listingId!: string;
}

export class BrowseListingsDto {
  @IsOptional()
  @IsUUID()
  collectionId?: string;

  @IsOptional()
  @IsString()
  minPrice?: string;

  @IsOptional()
  @IsString()
  maxPrice?: string;

  @IsOptional()
  @IsEnum(['ETH', 'MATIC', 'USDT', 'USDC'])
  currency?: string;

  @IsOptional()
  @IsEnum(['price_asc', 'price_desc', 'recent'])
  sort?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  limit?: number = 20;
}
