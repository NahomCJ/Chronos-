// ============================================================
// MarketDataService — Module 4
// Server-side price cache with 5s TTL.
// Wraps PaxosService.getMarketPrice with in-memory cache.
// Production upgrade: replace Map with Redis (5s TTL via ioredis).
// ============================================================

import { Injectable, Logger } from '@nestjs/common';
import { PaxosService } from '../../providers/paxos/paxos.service';

const SUPPORTED_ASSETS = ['BTC', 'ETH', 'SOL', 'UNI', 'AAVE', 'LINK'];
const TTL_MS = 5_000;

interface CacheEntry {
  price: number;
  ts: number;
}

@Injectable()
export class MarketDataService {
  private readonly logger = new Logger(MarketDataService.name);
  private readonly cache = new Map<string, CacheEntry>();

  constructor(private readonly paxos: PaxosService) {}

  /**
   * Returns cached price for a single asset.
   * Re-fetches from Paxos if cache is stale (>5s).
   */
  async getPrice(asset: string): Promise<number> {
    const key = asset.toUpperCase();
    const cached = this.cache.get(key);

    if (cached && Date.now() - cached.ts < TTL_MS) {
      return cached.price;
    }

    const price = await this.paxos.getMarketPrice(key);
    this.cache.set(key, { price, ts: Date.now() });
    return price;
  }

  /**
   * Returns all supported asset prices.
   * Fetches only stale or missing assets.
   */
  async getAllPrices(): Promise<Record<string, number>> {
    const result: Record<string, number> = {};

    await Promise.all(
      SUPPORTED_ASSETS.map(async (asset) => {
        try {
          result[asset] = await this.getPrice(asset);
        } catch (err) {
          this.logger.warn(`Failed to fetch price for ${asset}`, err);
          result[asset] = 0;
        }
      }),
    );

    return result;
  }

  /**
   * Returns prices with metadata (for the /market/prices endpoint).
   */
  async getPriceSnapshot() {
    const prices = await this.getAllPrices();
    return {
      ...prices,
      updated_at: new Date().toISOString(),
    };
  }
}
