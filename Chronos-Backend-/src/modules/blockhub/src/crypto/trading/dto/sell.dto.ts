import { IsIn, IsNumber, IsPositive } from 'class-validator';

const SUPPORTED_ASSETS = ['BTC', 'ETH', 'SOL'] as const;

export class SellDto {
  @IsIn(SUPPORTED_ASSETS, { message: 'asset must be one of: BTC, ETH, SOL' })
  asset!: string;

  @IsNumber()
  @IsPositive()
  amount_crypto!: number;
}
