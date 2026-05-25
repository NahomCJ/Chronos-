import { IsIn, IsNumber, IsPositive, Min } from 'class-validator';

const SUPPORTED_ASSETS = ['BTC', 'ETH', 'SOL'] as const;

export class BuyDto {
  @IsIn(SUPPORTED_ASSETS, { message: 'asset must be one of: BTC, ETH, SOL' })
  asset!: string;

  @IsNumber()
  @IsPositive()
  @Min(10, { message: 'Minimum trade amount is $10 USD' })
  amount_usd!: number;
}
