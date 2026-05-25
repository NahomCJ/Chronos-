import { Module } from '@nestjs/common';
import { RoyaltyService } from './royalty.service';
import { PaxosModule } from '../../providers/paxos/paxos.module';
import { AuditModule } from '../audit/audit.module';

@Module({
  imports: [
    PaxosModule,
    AuditModule,
  ],
  providers: [RoyaltyService],
  exports: [RoyaltyService],
})
export class RoyaltyModule {}
