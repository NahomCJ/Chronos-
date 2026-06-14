import axios, { AxiosError, AxiosInstance } from "axios";
import { CryptoApiError } from "./crypto.errors";

export const SUPPORTED_CRYPTO_ASSETS = ["BTC", "ETH", "SOL", "UNI", "AAVE", "LINK"] as const;
export type SupportedCryptoAsset = (typeof SUPPORTED_CRYPTO_ASSETS)[number];

const ASSET_TO_MARKET: Record<SupportedCryptoAsset, string> = {
  BTC: "BTCUSD",
  ETH: "ETHUSD",
  SOL: "SOLUSD",
  UNI: "UNIUSD",
  AAVE: "AAVEUSD",
  LINK: "LINKUSD",
};

const ASSET_TO_COINGECKO: Record<SupportedCryptoAsset, string> = {
  BTC: "bitcoin",
  ETH: "ethereum",
  SOL: "solana",
  UNI: "uniswap",
  AAVE: "aave",
  LINK: "chainlink",
};

interface PaxosRuntimeConfig {
  apiBaseUrl: string;
  oauthBaseUrl: string;
  clientId?: string;
  clientSecret?: string;
  profileId?: string;
  settlementProfileId?: string;
  scopes: string;
  configured: boolean;
}

interface CachedToken {
  cacheKey: string;
  token: string;
  expiresAt: number;
}

interface PaxosTokenResponse {
  access_token: string;
  expires_in: number;
}

export interface PaxosIdentity {
  id: string;
  ref_id?: string;
  status?: string;
  summary_status?: string;
}

export interface PaxosProfile {
  id: string;
  ref_id?: string;
  nickname?: string;
  status?: string;
}

export interface PaxosBalance {
  asset: string;
  available: string;
  trading?: string;
}

export interface PaxosOrder {
  id: string;
  client_order_id?: string;
  ref_id?: string;
  profile_id?: string;
  side: "BUY" | "SELL";
  market: string;
  status: string;
  fill_price?: string;
  average_price?: string;
  base_amount?: string;
  quote_amount?: string;
  amount_filled?: string;
  volume_weighted_average_price?: string;
  filled_base_amount?: string;
  filled_quote_amount?: string;
  filled_at?: string;
  created_at?: string;
  updated_at?: string;
}

export interface PaxosTransfer {
  id: string;
  ref_id?: string;
  profile_id?: string;
  amount: string;
  asset: string;
  direction?: string;
  type?: string;
  status: string;
  created_at?: string;
  updated_at?: string;
}

export interface MarketPrice {
  asset: SupportedCryptoAsset;
  market: string;
  price: number;
  source: "paxos" | "coingecko";
  updated_at: string;
}

export class PaxosCryptoService {
  private cachedToken: CachedToken | null = null;
  private apiClient: AxiosInstance | null = null;
  private apiClientBaseUrl: string | null = null;

  get supportedAssets(): readonly SupportedCryptoAsset[] {
    return SUPPORTED_CRYPTO_ASSETS;
  }

  normalizeAsset(asset: string): SupportedCryptoAsset {
    const normalized = asset.toUpperCase();
    if (!SUPPORTED_CRYPTO_ASSETS.includes(normalized as SupportedCryptoAsset)) {
      throw new CryptoApiError(
        "UNSUPPORTED_ASSET",
        `Asset ${asset} is not supported`,
        400,
        { supportedAssets: SUPPORTED_CRYPTO_ASSETS },
      );
    }
    return normalized as SupportedCryptoAsset;
  }

  getConfig(): PaxosRuntimeConfig {
    const paxosEnv = (process.env.PAXOS_ENV || process.env.NODE_ENV || "sandbox").toLowerCase();
    const isProduction = paxosEnv === "production";
    const apiBaseUrl =
      process.env.PAXOS_API_URL ||
      (isProduction ? "https://api.paxos.com/v2" : "https://api.sandbox.paxos.com/v2");
    const oauthBaseUrl = isProduction
      ? "https://oauth.paxos.com"
      : "https://oauth.sandbox.paxos.com";
    const clientId = process.env.PAXOS_CLIENT_ID;
    const clientSecret = process.env.PAXOS_CLIENT_SECRET;
    const profileId = process.env.PAXOS_PROFILE_ID;
    const settlementProfileId = process.env.PAXOS_SETTLEMENT_PROFILE_ID;
    const scopes =
      process.env.PAXOS_SCOPES ||
      [
        "funding:read_profile",
        "funding:write_profile",
        "trading:read_order",
        "trading:write_order",
        "identity:read_identity",
        "identity:write_identity",
        "transfer:read_transfer",
        "transfer:write_internal_transfer",
      ].join(" ");

    return {
      apiBaseUrl,
      oauthBaseUrl,
      clientId,
      clientSecret,
      profileId,
      settlementProfileId,
      scopes,
      configured: Boolean(clientId && clientSecret),
    };
  }

  isConfigured(): boolean {
    return this.getConfig().configured;
  }

  assertConfigured(): void {
    if (!this.isConfigured()) {
      throw new CryptoApiError(
        "PAXOS_NOT_CONFIGURED",
        "Crypto trading is not available because Paxos credentials are not configured.",
        503,
      );
    }
  }

  async createIdentity(params: {
    userId: string;
    email: string;
    firstName: string;
    lastName: string;
  }): Promise<PaxosIdentity> {
    return this.request<PaxosIdentity>("POST", "/identity/identities", {
      ref_id: params.userId,
      person_details: {
        verifier_type: "PASSTHROUGH",
        passthrough_verifier_type: "PLAID",
        passthrough_verified_at: new Date().toISOString(),
        first_name: params.firstName || "Unknown",
        last_name: params.lastName || "Unknown",
        email: params.email,
      },
      tax_details_not_required: true,
      metadata: {
        chronos_user_id: params.userId,
      },
    });
  }

  async createProfile(nickname: string, description?: string): Promise<PaxosProfile> {
    return this.request<PaxosProfile>("POST", "/profiles", {
      nickname,
      ...(description && { description }),
    });
  }

  async getBalances(profileId: string): Promise<PaxosBalance[]> {
    const response = await this.request<{ items: PaxosBalance[] }>(
      "GET",
      `/profiles/${profileId}/balances`,
    );
    return response.items || [];
  }

  async getBalance(profileId: string, asset: string): Promise<number> {
    const normalized = asset.toUpperCase();
    const balances = await this.getBalances(profileId);
    const balance = balances.find((item) => item.asset.toUpperCase() === normalized);
    return Number(balance?.available ?? 0);
  }

  async placeOrder(params: {
    profileId: string;
    side: "BUY" | "SELL";
    asset: SupportedCryptoAsset;
    quoteAmount?: string;
    baseAmount?: string;
    clientOrderId: string;
  }): Promise<PaxosOrder> {
    const body: Record<string, string> = {
      side: params.side,
      market: ASSET_TO_MARKET[params.asset],
      type: "MARKET",
      ref_id: params.clientOrderId,
    };

    if (params.side === "BUY" && params.quoteAmount) body.quote_amount = params.quoteAmount;
    if (params.side === "SELL" && params.baseAmount) body.base_amount = params.baseAmount;

    return this.request<PaxosOrder>("POST", `/profiles/${params.profileId}/orders`, body);
  }

  async getOrder(profileId: string, orderId: string): Promise<PaxosOrder> {
    return this.request<PaxosOrder>("GET", `/profiles/${profileId}/orders/${orderId}`);
  }

  async pollOrderUntilTerminal(profileId: string, orderId: string): Promise<PaxosOrder> {
    const intervalMs = Number(process.env.PAXOS_ORDER_POLL_INTERVAL_MS ?? 2000);
    const maxAttempts = Number(process.env.PAXOS_ORDER_POLL_ATTEMPTS ?? 15);

    for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
      const order = await this.getOrder(profileId, orderId);
      const status = order.status.toUpperCase();

      if (["FILLED", "SETTLED"].includes(status)) return order;
      if (["FAILED", "CANCELLED", "REJECTED", "EXPIRED"].includes(status)) {
        throw new CryptoApiError(
          "ORDER_EXECUTION_FAILED",
          `Paxos order ended with status ${order.status}`,
          502,
          order,
        );
      }

      if (attempt < maxAttempts) {
        await new Promise((resolve) => setTimeout(resolve, intervalMs));
      }
    }

    throw new CryptoApiError("ORDER_TIMEOUT", `Paxos order ${orderId} did not fill in time`, 504);
  }

  async getMarketPrice(asset: string): Promise<MarketPrice> {
    const normalized = this.normalizeAsset(asset);

    if (this.isConfigured()) {
      try {
        const ticker = await this.request<{
          bid?: string;
          ask?: string;
          price?: string;
          timestamp?: string;
          snapshot_at?: string;
          best_bid?: { price?: string };
          best_ask?: { price?: string };
          last_execution?: { price?: string };
        }>("GET", `/markets/${ASSET_TO_MARKET[normalized]}/ticker`);
        const bid = Number(ticker.best_bid?.price ?? ticker.bid);
        const ask = Number(ticker.best_ask?.price ?? ticker.ask);
        const price = Number.isFinite(bid) && Number.isFinite(ask)
          ? (bid + ask) / 2
          : Number(ticker.last_execution?.price ?? ticker.price);

        if (Number.isFinite(price) && price > 0) {
          return {
            asset: normalized,
            market: ASSET_TO_MARKET[normalized],
            price,
            source: "paxos",
            updated_at: ticker.snapshot_at || ticker.timestamp || new Date().toISOString(),
          };
        }
      } catch (err) {
        if (err instanceof CryptoApiError && err.code === "UNSUPPORTED_ASSET") throw err;
      }
    }

    const fallbackPrice = await this.getCoinGeckoPrice(normalized);
    return {
      asset: normalized,
      market: ASSET_TO_MARKET[normalized],
      price: fallbackPrice,
      source: "coingecko",
      updated_at: new Date().toISOString(),
    };
  }

  async getAllMarketPrices(): Promise<Record<SupportedCryptoAsset, MarketPrice>> {
    const entries = await Promise.all(
      SUPPORTED_CRYPTO_ASSETS.map(async (asset) => [asset, await this.getMarketPrice(asset)] as const),
    );
    return Object.fromEntries(entries) as Record<SupportedCryptoAsset, MarketPrice>;
  }

  async listTransfers(profileId: string, limit = 25, cursor?: string): Promise<{
    items: PaxosTransfer[];
    next_page_cursor?: string;
  }> {
    const params: Record<string, string | number> = { profile_ids: profileId, limit };
    if (cursor) params.page_cursor = cursor;
    return this.request<{ items: PaxosTransfer[]; next_page_cursor?: string }>(
      "GET",
      "/transfer/transfers",
      undefined,
      params,
    );
  }

  async creditFromSettlement(params: {
    profileId: string;
    amount: string;
    asset: string;
    refId: string;
  }): Promise<PaxosTransfer> {
    const settlementProfileId = process.env.PAXOS_SETTLEMENT_PROFILE_ID;
    if (!settlementProfileId) {
      throw new CryptoApiError("PAXOS_SETTLEMENT_NOT_CONFIGURED", "Paxos settlement profile is not configured.", 503);
    }
    return this.internalTransfer({
      fromProfileId: settlementProfileId,
      toProfileId: params.profileId,
      amount: params.amount,
      asset: params.asset,
      refId: params.refId,
    });
  }

  async debitToSettlement(params: {
    profileId: string;
    amount: string;
    asset: string;
    refId: string;
  }): Promise<PaxosTransfer> {
    const settlementProfileId = process.env.PAXOS_SETTLEMENT_PROFILE_ID;
    if (!settlementProfileId) {
      throw new CryptoApiError("PAXOS_SETTLEMENT_NOT_CONFIGURED", "Paxos settlement profile is not configured.", 503);
    }
    return this.internalTransfer({
      fromProfileId: params.profileId,
      toProfileId: settlementProfileId,
      amount: params.amount,
      asset: params.asset,
      refId: params.refId,
    });
  }

  private async internalTransfer(params: {
    fromProfileId: string;
    toProfileId: string;
    amount: string;
    asset: string;
    refId: string;
  }): Promise<PaxosTransfer> {
    return this.request<PaxosTransfer>("POST", "/transfer/internal", {
      from_profile_id: params.fromProfileId,
      to_profile_id: params.toProfileId,
      amount: params.amount,
      asset: params.asset.toUpperCase(),
      ref_id: params.refId,
    });
  }

  private async getAccessToken(): Promise<string> {
    const config = this.getConfig();
    if (!config.configured) this.assertConfigured();

    const cacheKey = `${config.oauthBaseUrl}:${config.clientId}:${config.scopes}`;
    const now = Date.now();
    if (this.cachedToken?.cacheKey === cacheKey && this.cachedToken.expiresAt - 60_000 > now) {
      return this.cachedToken.token;
    }

    try {
      const response = await axios.post<PaxosTokenResponse>(
        `${config.oauthBaseUrl}/oauth2/token`,
        new URLSearchParams({
          grant_type: "client_credentials",
          client_id: config.clientId!,
          client_secret: config.clientSecret!,
          scope: config.scopes,
        }),
        { headers: { "Content-Type": "application/x-www-form-urlencoded" } },
      );

      this.cachedToken = {
        cacheKey,
        token: response.data.access_token,
        expiresAt: now + response.data.expires_in * 1000,
      };
      return this.cachedToken.token;
    } catch (err: any) {
      throw new CryptoApiError(
        "PAXOS_AUTH_FAILED",
        "Failed to authenticate with Paxos. Check PAXOS_CLIENT_ID and PAXOS_CLIENT_SECRET.",
        401,
        err?.response?.data,
      );
    }
  }

  private getApiClient(): AxiosInstance {
    const { apiBaseUrl } = this.getConfig();
    if (!this.apiClient || this.apiClientBaseUrl !== apiBaseUrl) {
      this.apiClientBaseUrl = apiBaseUrl;
      this.apiClient = axios.create({ baseURL: apiBaseUrl, timeout: 15_000 });
    }
    return this.apiClient;
  }

  private async request<T>(
    method: "GET" | "POST",
    path: string,
    data?: Record<string, unknown>,
    params?: Record<string, string | number>,
    attempt = 1,
  ): Promise<T> {
    this.assertConfigured();
    try {
      const token = await this.getAccessToken();
      const response = await this.getApiClient().request<T>({
        method,
        url: path,
        data,
        params,
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
      });
      return response.data;
    } catch (err) {
      if (err instanceof CryptoApiError) throw err;

      const axiosErr = err as AxiosError;
      const status = axiosErr.response?.status ?? 500;
      if (attempt < 3 && [429, 503, 504].includes(status)) {
        await new Promise((resolve) => setTimeout(resolve, 500 * attempt));
        return this.request<T>(method, path, data, params, attempt + 1);
      }

      throw this.mapPaxosError(status, axiosErr.response?.data);
    }
  }

  private mapPaxosError(status: number, raw: unknown): CryptoApiError {
    const errorMap: Record<number, [string, string]> = {
      400: ["INVALID_ORDER", "Invalid Paxos request."],
      401: ["PAXOS_AUTH_FAILED", "Paxos authentication failed."],
      403: ["PAXOS_FORBIDDEN", "Paxos rejected this operation."],
      404: ["PAXOS_NOT_FOUND", "Paxos resource not found."],
      409: ["PAXOS_CONFLICT", "Duplicate request or conflicting Paxos state."],
      422: ["INSUFFICIENT_BALANCE", "Insufficient Paxos balance for this operation."],
      429: ["RATE_LIMITED", "Paxos rate limit exceeded."],
      503: ["PAXOS_UNAVAILABLE", "Paxos trading service is unavailable."],
      504: ["PAXOS_TIMEOUT", "Paxos trading service timed out."],
    };
    const [code, message] = errorMap[status] || ["PAXOS_ERROR", "Unexpected Paxos API error."];
    return new CryptoApiError(code, message, status, raw);
  }

  private async getCoinGeckoPrice(asset: SupportedCryptoAsset): Promise<number> {
    const id = ASSET_TO_COINGECKO[asset];
    try {
      const response = await axios.get(
        `https://api.coingecko.com/api/v3/simple/price?ids=${id}&vs_currencies=usd`,
        { timeout: 5_000 },
      );
      const price = Number(response.data?.[id]?.usd);
      return Number.isFinite(price) ? price : 0;
    } catch {
      return 0;
    }
  }
}

export const paxosCryptoService = new PaxosCryptoService();
export default paxosCryptoService;
