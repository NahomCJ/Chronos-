import { Module } from '@nestjs/common';
import { WalletModule } from './wallet/wallet.module';
import { ComplianceModule } from './compliance/compliance.module';
import { AuditModule } from './audit/audit.module';
import { RevenueModule } from './revenue/revenue.module';
import { TradingModule } from './trading/trading.module';
import { PortfolioModule } from './portfolio/portfolio.module';
import { WebhooksModule } from './webhooks/webhooks.module';

@Module({
  imports: [
    WalletModule,
    ComplianceModule,
    AuditModule,
    RevenueModule,
    TradingModule,
    PortfolioModule,
    WebhooksModule,
  ],
  exports: [
    WalletModule,
    ComplianceModule,
    AuditModule,
    RevenueModule,
    TradingModule,
    PortfolioModule,
    WebhooksModule,
  ],
})
export class CryptoModule {}
