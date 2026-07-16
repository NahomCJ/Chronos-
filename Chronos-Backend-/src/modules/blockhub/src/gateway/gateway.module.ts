import { Module } from '@nestjs/common';
import { BlockhubGateway } from './blockhub.gateway';
import { PriceBroadcasterService } from './price-broadcaster.service';
import { PortfolioModule } from '../crypto/portfolio/portfolio.module';

@Module({
  imports: [PortfolioModule],
  providers: [BlockhubGateway, PriceBroadcasterService],
  exports: [BlockhubGateway],
})
export class GatewayModule {}
