import { Module } from '@nestjs/common';
import { NftModule as NftCoreModule } from './nft/nft.module';
import { MintingModule } from './minting/minting.module';
import { MarketplaceModule } from './marketplace/marketplace.module';
import { RoyaltyModule } from './royalty/royalty.module';
import { PortfolioModule } from './portfolio/portfolio.module';
import { ComplianceModule } from './compliance/compliance.module';
import { AuditModule } from './audit/audit.module';
import { WebsocketModule } from './websocket/websocket.module';
import { NotificationModule } from './notification/notification.module';

@Module({
  imports: [
    NftCoreModule,
    MintingModule,
    MarketplaceModule,
    RoyaltyModule,
    PortfolioModule,
    ComplianceModule,
    AuditModule,
    WebsocketModule,
    NotificationModule,
  ],
  exports: [
    NftCoreModule,
    MintingModule,
    MarketplaceModule,
    RoyaltyModule,
    PortfolioModule,
    ComplianceModule,
    AuditModule,
    WebsocketModule,
    NotificationModule,
  ],
})
export class NftModule {}
