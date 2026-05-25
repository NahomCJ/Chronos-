import {
  IsString, IsUUID, IsOptional, IsArray, IsNumber,
  Min, Max, MaxLength, IsNotEmpty,
} from 'class-validator';
import { Type } from 'class-transformer';

export class NftAttributeDto {
  @IsString()
  trait_type!: string;

  @IsString()
  value!: string;
}

export class MintNftDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name!: string;

  @IsString()
  @IsOptional()
  @MaxLength(1000)
  description?: string;

  @IsUUID()
  collectionId!: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(10)
  royaltyPercent?: number;  // 0–10%

  @IsOptional()
  @IsArray()
  @Type(() => NftAttributeDto)
  attributes?: NftAttributeDto[];
}

export class DeployCollectionDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(10)
  symbol!: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(10)
  royaltyPercent?: number;
}
