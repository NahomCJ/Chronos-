import { IsOptional, IsUUID, IsEnum, IsInt, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';
import { NftStatus } from '../../common/types';

export class BrowseNftsDto {
  @IsOptional()
  @IsUUID()
  collectionId?: string;

  @IsOptional()
  @IsEnum(['MINTED', 'LISTED', 'SOLD'])
  status?: NftStatus;

  @IsOptional()
  @IsEnum(['price_asc', 'price_desc', 'recent', 'trending'])
  sort?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}

export class FavoriteNftDto {
  @IsUUID()
  nftId!: string;
}
