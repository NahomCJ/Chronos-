import { Module } from '@nestjs/common';
import { WalletService } from './wallet.service';
import { AuditModule } from '../audit/audit.module';

@Module({
  imports: [AuditModule],
  providers: [WalletService],
  exports: [WalletService],
})
export class WalletModule {}
