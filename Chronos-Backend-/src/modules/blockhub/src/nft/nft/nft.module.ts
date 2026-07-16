import { Module } from '@nestjs/common';
import { NftService } from './nft.service';
import { NftController } from './nft.controller';
import { AuditModule } from '../audit/audit.module';

@Module({
  imports: [
    AuditModule,
  ],
  providers: [NftService],
  controllers: [NftController],
  exports: [NftService],
})
export class NftModule {}
