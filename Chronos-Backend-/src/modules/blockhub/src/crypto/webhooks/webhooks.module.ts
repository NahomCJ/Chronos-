import { Module } from '@nestjs/common';
import { WebhooksController } from './webhooks.controller';
import { WalletModule } from '../wallet/wallet.module';
import { AuditModule } from '../audit/audit.module';

@Module({
  imports: [WalletModule, AuditModule],
  controllers: [WebhooksController],
})
export class WebhooksModule {}
