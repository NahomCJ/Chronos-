import { Module } from '@nestjs/common';
import { TradingService } from './trading.service';
import { TradingController } from './trading.controller';
import { ComplianceModule } from '../compliance/compliance.module';
import { WalletModule } from '../wallet/wallet.module';
import { PortfolioModule } from '../portfolio/portfolio.module';
import { RevenueModule } from '../revenue/revenue.module';
import { AuditModule } from '../audit/audit.module';
import { GatewayModule } from '../../gateway/gateway.module';

@Module({
  imports: [
    ComplianceModule,
    WalletModule,
    PortfolioModule,
    RevenueModule,
    AuditModule,
    GatewayModule,
  ],
  providers: [TradingService],
  controllers: [TradingController],
})
export class TradingModule {}
