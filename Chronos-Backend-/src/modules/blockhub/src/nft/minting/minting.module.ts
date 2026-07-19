import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bull';
import { MintingService, MINT_QUEUE } from './minting.service';
import { MintingController } from './minting.controller';
import { MintingProcessor } from './minting.processor';
import { ThirdwebModule } from '../../providers/thirdweb/thirdweb.module';
import { ComplianceModule } from '../compliance/compliance.module';
import { NftModule } from '../nft/nft.module';
import { AuditModule } from '../audit/audit.module';
import { NotificationModule } from '../notification/notification.module';

@Module({
  imports: [
    BullModule.registerQueue({ name: MINT_QUEUE }),
    ThirdwebModule,
    ComplianceModule,
    NftModule,
    AuditModule,
    NotificationModule,
  ],
  providers: [MintingService, MintingProcessor],
  controllers: [MintingController],
  exports: [MintingService],
})
export class MintingModule {}
