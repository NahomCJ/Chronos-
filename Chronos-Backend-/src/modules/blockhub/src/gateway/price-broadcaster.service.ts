// ============================================================
// PriceBroadcasterService
// Runs on a 5-second interval and pushes live prices to all
// connected WebSocket clients via the BlockhubGateway.
// ============================================================

import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { MarketDataService } from '../crypto/portfolio/market-data.service';
import { BlockhubGateway } from './blockhub.gateway';

@Injectable()
export class PriceBroadcasterService {
  private readonly logger = new Logger(PriceBroadcasterService.name);

  constructor(
    private readonly marketData: MarketDataService,
    private readonly gateway: BlockhubGateway,
  ) {}

  @Cron('*/5 * * * * *') // Every 5 seconds
  async broadcastPrices() {
    try {
      const prices = await this.marketData.getAllPrices();
      this.gateway.pushAllPrices(prices);
    } catch (err) {
      this.logger.warn('Failed to broadcast price update', err);
    }
  }
}
