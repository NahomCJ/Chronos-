import { Module } from '@nestjs/common';
import { MarketplaceService } from './marketplace.service';
import { MarketplaceController } from './marketplace.controller';
import { ComplianceModule } from '../compliance/compliance.module';
import { NftModule } from '../nft/nft.module';
import { PaxosModule } from '../../providers/paxos/paxos.module';
import { ThirdwebModule } from '../../providers/thirdweb/thirdweb.module';
import { RoyaltyModule } from '../royalty/royalty.module';
import { AuditModule } from '../audit/audit.module';
import { WebsocketModule } from '../websocket/websocket.module';

@Module({
  imports: [
    ComplianceModule,
    NftModule,
    PaxosModule,
    ThirdwebModule,
    RoyaltyModule,
    AuditModule,
    WebsocketModule,
  ],
  providers: [MarketplaceService],
  controllers: [MarketplaceController],
  exports: [MarketplaceService],
})
export class MarketplaceModule {}
