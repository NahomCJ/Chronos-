import { Module } from '@nestjs/common';
import { PortfolioService } from './portfolio.service';
import { PortfolioController } from './portfolio.controller';
import { MarketDataService } from './market-data.service';

@Module({
  providers: [PortfolioService, MarketDataService],
  controllers: [PortfolioController],
  exports: [PortfolioService, MarketDataService],
})
export class PortfolioModule {}
