// ============================================================
// PaxosService — Paxos API integration
// Gracefully degrades when PAXOS_CLIENT_ID is not configured.
// Trading endpoints return 503. Prices fall back to CoinGecko.
// ============================================================

import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance, AxiosError } from 'axios';
import {
  PaxosTokenResponse,
  PaxosCachedToken,
  PaxosCreateIdentityRequest,
  PaxosIdentity,
  PaxosCreateProfileRequest,
  PaxosProfile,
  PaxosBalancesResponse,
  PaxosBalance,
  PaxosCreateOrderRequest,
  PaxosOrder,
  PaxosMarketTicker,
  PaxosTransfersResponse,
  PaxosApiError,
} from './paxos.types';

const ASSET_TO_MARKET: Record<string, string> = {
  BTC:  'BTCUSD',
  ETH:  'ETHUSD',
  SOL:  'SOLUSD',
  UNI:  'UNIUSD',
  AAVE: 'AAVEUSD',
  LINK: 'LINKUSD',
};

// CoinGecko asset ID mapping (free, no key required)
const ASSET_TO_COINGECKO: Record<string, string> = {
  BTC:  'bitcoin',
  ETH:  'ethereum',
  SOL:  'solana',
  UNI:  'uniswap',
  AAVE: 'aave',
  LINK: 'chainlink',
};

@Injectable()
export class PaxosService {
  private readonly logger = new Logger(PaxosService.name);

  private readonly oauthBaseUrl: string;
  private readonly apiBaseUrl: string;
  private readonly clientId: string | undefined;
  private readonly clientSecret: string | undefined;
  private readonly scopes: string;
  private readonly configured: boolean;

  private cachedToken: PaxosCachedToken | null = null;
  private apiClient: AxiosInstance;

  constructor(private readonly configService: ConfigService) {
    const isProd = configService.get('NODE_ENV') === 'production';

    this.oauthBaseUrl = isProd
      ? 'https://oauth.paxos.com'
      : 'https://oauth.sandbox.paxos.com';

    this.apiBaseUrl = isProd
      ? 'https://api.paxos.com/v2'
      : 'https://api.sandbox.paxos.com/v2';

    this.clientId = configService.get<string>('PAXOS_CLIENT_ID');
    this.clientSecret = configService.get<string>('PAXOS_CLIENT_SECRET');
    this.scopes = configService.get<string>('PAXOS_SCOPES', 'funding:read_profile funding:write_profile trading:read_order trading:write_order identity:read_identity identity:write_identity transfer:read_transfer');

    this.configured = !!(this.clientId && this.clientSecret);

    this.apiClient = axios.create({ baseURL: this.apiBaseUrl });

    this.apiClient.interceptors.request.use(async (config) => {
      const token = await this.getAccessToken();
      config.headers['Authorization'] = `Bearer ${token}`;
      config.headers['Content-Type'] = 'application/json';
      return config;
    });
  }

  async onModuleInit(): Promise<void> {
    if (!this.configured) {
      this.logger.warn('PaxosService: PAXOS_CLIENT_ID/SECRET not set — trading disabled, prices via CoinGecko');
      return;
    }
    try {
      await this.getAccessToken();
      this.logger.log(`PaxosService ready — ${this.configService.get('NODE_ENV')} mode`);
    } catch (err) {
      this.logger.error('PaxosService: failed to obtain initial access token', err);
    }
  }

  get isConfigured(): boolean {
    return this.configured;
  }

  private assertConfigured(): void {
    if (!this.configured) {
      throw new ServiceUnavailableException(
        'Crypto trading is not yet available. Paxos integration coming soon.',
      );
    }
  }

  // ── OAuth2 ───────────────────────────────────────────────────

  private async getAccessToken(): Promise<string> {
    this.assertConfigured();
    const now = Date.now();

    if (this.cachedToken && this.cachedToken.expiresAt - 60_000 > now) {
      return this.cachedToken.token;
    }

    try {
      const response = await axios.post<PaxosTokenResponse>(
        `${this.oauthBaseUrl}/oauth2/token`,
        new URLSearchParams({
          grant_type: 'client_credentials',
          client_id: this.clientId!,
          client_secret: this.clientSecret!,
          scope: this.scopes,
        }),
        { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } },
      );

      this.cachedToken = {
        token: response.data.access_token,
        expiresAt: now + response.data.expires_in * 1_000,
      };

      return this.cachedToken.token;
    } catch (err: any) {
      this.logger.error('Paxos: OAuth2 token fetch failed', err?.response?.data);
      throw new PaxosApiError(
        'PAXOS_AUTH_FAILED',
        'Failed to authenticate with Paxos — check PAXOS_CLIENT_ID and PAXOS_CLIENT_SECRET',
        401,
        err?.response?.data,
      );
    }
  }

  // ── Identity ─────────────────────────────────────────────────

  async createIdentity(payload: PaxosCreateIdentityRequest): Promise<PaxosIdentity> {
    this.assertConfigured();
    return this.request<PaxosIdentity>('POST', '/identity/identity', payload);
  }

  async createProfile(payload: PaxosCreateProfileRequest): Promise<PaxosProfile> {
    this.assertConfigured();
    return this.request<PaxosProfile>('POST', '/identity/profiles', payload);
  }

  // ── Balances ──────────────────────────────────────────────────

  async getBalances(profileId: string): Promise<PaxosBalance[]> {
    this.assertConfigured();
    const response = await this.request<PaxosBalancesResponse>('GET', `/profiles/${profileId}/balances`);
    return response.items;
  }

  async getUsdBalance(profileId: string): Promise<number> {
    const balances = await this.getBalances(profileId);
    const usd = balances.find((b) => b.asset === 'USD');
    return parseFloat(usd?.available ?? '0');
  }

  async getCryptoBalance(profileId: string, asset: string): Promise<number> {
    const balances = await this.getBalances(profileId);
    const holding = balances.find((b) => b.asset === asset.toUpperCase());
    return parseFloat(holding?.available ?? '0');
  }

  // ── Orders ───────────────────────────────────────────────────

  async placeOrder(payload: PaxosCreateOrderRequest): Promise<PaxosOrder> {
    this.assertConfigured();
    return this.request<PaxosOrder>('POST', '/brokerage/orders', payload);
  }

  async getOrder(orderId: string): Promise<PaxosOrder> {
    this.assertConfigured();
    return this.request<PaxosOrder>('GET', `/brokerage/orders/${orderId}`);
  }

  async pollOrderUntilFilled(orderId: string): Promise<PaxosOrder> {
    this.assertConfigured();
    const INTERVAL_MS = 2_000;
    const MAX_ATTEMPTS = 15;

    for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
      const order = await this.getOrder(orderId);
      if (order.status === 'FILLED') return order;
      if (order.status === 'FAILED' || order.status === 'CANCELLED') {
        throw new PaxosApiError('ORDER_EXECUTION_FAILED', `Order ended with status: ${order.status}`, 502, order);
      }
      if (attempt < MAX_ATTEMPTS) await this.sleep(INTERVAL_MS);
    }

    throw new PaxosApiError('ORDER_TIMEOUT', `Order ${orderId} did not fill within 30 seconds`, 504);
  }

  // ── Market Data (Paxos primary, CoinGecko fallback) ──────────

  async getMarketPrice(asset: string): Promise<number> {
    const key = asset.toUpperCase();

    if (this.configured) {
      const market = ASSET_TO_MARKET[key];
      if (!market) throw new PaxosApiError('UNSUPPORTED_ASSET', `Asset ${asset} is not supported`, 400);
      const ticker = await this.request<PaxosMarketTicker>('GET', `/markets/${market}/ticker`);
      return (parseFloat(ticker.bid) + parseFloat(ticker.ask)) / 2;
    }

    // CoinGecko fallback
    return this.getCoinGeckoPrice(key);
  }

  async getAllMarketPrices(): Promise<Record<string, number>> {
    if (this.configured) {
      const assets = Object.keys(ASSET_TO_MARKET);
      const prices = await Promise.all(assets.map((a) => this.getMarketPrice(a)));
      return Object.fromEntries(assets.map((a, i) => [a, prices[i]]));
    }
    return this.getAllCoinGeckoPrices();
  }

  private async getCoinGeckoPrice(asset: string): Promise<number> {
    const id = ASSET_TO_COINGECKO[asset];
    if (!id) return 0;
    try {
      const res = await axios.get(
        `https://api.coingecko.com/api/v3/simple/price?ids=${id}&vs_currencies=usd`,
        { timeout: 5000 },
      );
      return res.data?.[id]?.usd ?? 0;
    } catch {
      this.logger.warn(`CoinGecko fallback failed for ${asset}`);
      return 0;
    }
  }

  private async getAllCoinGeckoPrices(): Promise<Record<string, number>> {
    const ids = Object.values(ASSET_TO_COINGECKO).join(',');
    try {
      const res = await axios.get(
        `https://api.coingecko.com/api/v3/simple/price?ids=${ids}&vs_currencies=usd`,
        { timeout: 5000 },
      );
      const result: Record<string, number> = {};
      for (const [asset, geckoId] of Object.entries(ASSET_TO_COINGECKO)) {
        result[asset] = res.data?.[geckoId]?.usd ?? 0;
      }
      return result;
    } catch {
      this.logger.warn('CoinGecko batch price fetch failed');
      return Object.fromEntries(Object.keys(ASSET_TO_COINGECKO).map((a) => [a, 0]));
    }
  }

  // ── Transfers ─────────────────────────────────────────────────

  async getTransfers(profileId: string, limit = 50, cursor?: string): Promise<PaxosTransfersResponse> {
    this.assertConfigured();
    const params: Record<string, any> = { profile_id: profileId, limit };
    if (cursor) params.page_cursor = cursor;
    return this.request<PaxosTransfersResponse>('GET', '/transfer/transfers', undefined, params);
  }

  async getAssetBalance(profileId: string, asset: string): Promise<number> {
    this.assertConfigured();
    const balances = await this.getBalances(profileId);
    const holding = balances.find((b) => b.asset === asset.toUpperCase());
    return parseFloat(holding?.available ?? '0');
  }

  async debit(params: { walletId: string; amount: number; currency: string; memo: string; idempotencyKey: string }): Promise<{ id: string }> {
    this.assertConfigured();
    const settlementProfileId = this.configService.getOrThrow<string>('PAXOS_SETTLEMENT_PROFILE_ID');
    return this.request<{ id: string }>('POST', '/transfer/transfers', {
      source_profile_id: params.walletId,
      destination_profile_id: settlementProfileId,
      asset: params.currency,
      amount: params.amount.toFixed(8),
      memo: params.memo,
      ref_id: params.idempotencyKey,
    });
  }

  async credit(params: { walletId: string; amount: number; currency: string; memo: string; idempotencyKey: string }): Promise<{ id: string }> {
    this.assertConfigured();
    const settlementProfileId = this.configService.getOrThrow<string>('PAXOS_SETTLEMENT_PROFILE_ID');
    return this.request<{ id: string }>('POST', '/transfer/transfers', {
      source_profile_id: settlementProfileId,
      destination_profile_id: params.walletId,
      asset: params.currency,
      amount: params.amount.toFixed(8),
      memo: params.memo,
      ref_id: params.idempotencyKey,
    });
  }

  // ── Internal HTTP ─────────────────────────────────────────────

  private async request<T>(method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH', path: string, data?: Record<string, any>, params?: Record<string, any>, attempt = 1): Promise<T> {
    try {
      const response = await this.apiClient.request<T>({ method, url: path, data, params });
      return response.data;
    } catch (err: any) {
      const axiosErr = err as AxiosError;
      const statusCode = axiosErr.response?.status ?? 500;
      const responseData = axiosErr.response?.data;

      if (attempt < 3 && [429, 503, 504].includes(statusCode)) {
        const delayMs = Math.min(500 * Math.pow(2, attempt - 1), 5_000);
        await this.sleep(delayMs);
        return this.request<T>(method, path, data, params, attempt + 1);
      }

      throw this.mapError(statusCode, responseData);
    }
  }

  private mapError(statusCode: number, raw?: any): PaxosApiError {
    const errorMap: Record<number, [string, string]> = {
      400: ['INVALID_ORDER',        'Invalid order parameters'],
      401: ['PAXOS_AUTH_FAILED',    'Paxos authentication error — check credentials'],
      403: ['PAXOS_FORBIDDEN',      'Operation not permitted by Paxos'],
      404: ['PAXOS_NOT_FOUND',      'Paxos resource not found'],
      409: ['PAXOS_CONFLICT',       'Duplicate request or conflicting state'],
      422: ['INSUFFICIENT_BALANCE', 'Insufficient balance for this trade'],
      429: ['RATE_LIMITED',         'Too many requests — please try again shortly'],
      503: ['PAXOS_UNAVAILABLE',    'Paxos trading service temporarily unavailable'],
      504: ['PAXOS_TIMEOUT',        'Paxos trading service timed out'],
    };
    const [code, message] = errorMap[statusCode] ?? ['PAXOS_ERROR', 'Unexpected Paxos API error'];
    return new PaxosApiError(code, message, statusCode, raw);
  }

  private sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
