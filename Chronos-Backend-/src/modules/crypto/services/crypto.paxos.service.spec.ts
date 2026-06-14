import axios from "axios";
import { CryptoApiError } from "./crypto.errors";
import { PaxosCryptoService } from "./crypto.paxos.service";

jest.mock("axios");

const mockedAxios = axios as jest.Mocked<typeof axios>;

describe("PaxosCryptoService", () => {
  let service: PaxosCryptoService;
  let request: jest.Mock;

  beforeEach(() => {
    service = new PaxosCryptoService();
    request = jest.fn();
    mockedAxios.create.mockReturnValue({ request } as any);
    mockedAxios.post.mockResolvedValue({
      data: { access_token: "token-1", expires_in: 3600 },
    } as any);
    mockedAxios.get.mockResolvedValue({
      data: { bitcoin: { usd: 65000 } },
    } as any);
    delete process.env.PAXOS_CLIENT_ID;
    delete process.env.PAXOS_CLIENT_SECRET;
    delete process.env.PAXOS_ENV;
    delete process.env.PAXOS_API_URL;
    delete process.env.PAXOS_PROFILE_ID;
    delete process.env.PAXOS_SETTLEMENT_PROFILE_ID;
    delete process.env.PAXOS_SCOPES;
    delete process.env.PAXOS_ORDER_POLL_INTERVAL_MS;
    delete process.env.PAXOS_ORDER_POLL_ATTEMPTS;
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("falls back to CoinGecko when Paxos credentials are absent", async () => {
    const price = await service.getMarketPrice("BTC");

    expect(price).toMatchObject({
      asset: "BTC",
      source: "coingecko",
      price: 65000,
    });
    expect(mockedAxios.post).not.toHaveBeenCalled();
  });

  it("returns zero from the CoinGecko fallback when fallback pricing also fails", async () => {
    mockedAxios.get.mockRejectedValue(new Error("network unavailable"));

    const price = await service.getMarketPrice("ETH");

    expect(price).toMatchObject({
      asset: "ETH",
      market: "ETHUSD",
      source: "coingecko",
      price: 0,
    });
  });

  it("rejects unsupported assets before any external request", async () => {
    await expect(service.getMarketPrice("DOGE")).rejects.toMatchObject({
      code: "UNSUPPORTED_ASSET",
      status: 400,
    });

    expect(mockedAxios.get).not.toHaveBeenCalled();
    expect(mockedAxios.post).not.toHaveBeenCalled();
  });

  it("returns 503 for trading calls when Paxos credentials are absent", async () => {
    await expect(
      service.placeOrder({
        profileId: "profile-1",
        side: "BUY",
        asset: "BTC",
        quoteAmount: "5.00",
        clientOrderId: "order-1",
      }),
    ).rejects.toMatchObject({
      code: "PAXOS_NOT_CONFIGURED",
      status: 503,
    });
  });

  it("exposes dynamic sandbox, production, and override config", () => {
    expect(service.getConfig()).toMatchObject({
      apiBaseUrl: "https://api.sandbox.paxos.com/v2",
      oauthBaseUrl: "https://oauth.sandbox.paxos.com",
      configured: false,
    });

    process.env.PAXOS_ENV = "production";
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    process.env.PAXOS_PROFILE_ID = "profile-platform";
    process.env.PAXOS_SETTLEMENT_PROFILE_ID = "settlement-1";
    process.env.PAXOS_SCOPES = "custom:scope";

    expect(service.getConfig()).toMatchObject({
      apiBaseUrl: "https://api.paxos.com/v2",
      oauthBaseUrl: "https://oauth.paxos.com",
      clientId: "client-1",
      clientSecret: "secret-1",
      profileId: "profile-platform",
      settlementProfileId: "settlement-1",
      scopes: "custom:scope",
      configured: true,
    });

    process.env.PAXOS_API_URL = "https://example.test/v2";
    expect(service.getConfig().apiBaseUrl).toBe("https://example.test/v2");
  });

  it("fetches and caches OAuth tokens for configured sandbox calls", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    process.env.PAXOS_ENV = "sandbox";
    request.mockResolvedValue({
      data: {
        best_bid: { price: "65000" },
        best_ask: { price: "65100" },
        snapshot_at: "2026-06-06T00:00:00Z",
      },
    });

    const price = await service.getMarketPrice("BTC");
    await service.getMarketPrice("ETH");

    expect(price.price).toBe(65050);
    expect(mockedAxios.post).toHaveBeenCalledTimes(1);
    expect(String(mockedAxios.post.mock.calls[0][0])).toContain("oauth.sandbox.paxos.com");
    expect(request).toHaveBeenCalledTimes(2);
    expect(request.mock.calls[0][0]).toMatchObject({
      method: "GET",
      url: "/markets/BTCUSD/ticker",
    });
  });

  it("refreshes OAuth tokens when the scope cache key changes", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    process.env.PAXOS_SCOPES = "scope:one";
    request.mockResolvedValue({ data: { items: [] } });

    await service.getBalances("profile-1");
    process.env.PAXOS_SCOPES = "scope:two";
    await service.getBalances("profile-1");

    expect(mockedAxios.post).toHaveBeenCalledTimes(2);
  });

  it("uses profile-scoped Paxos v2 order endpoints", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    request.mockResolvedValue({
      data: { id: "paxos-order-1", side: "BUY", market: "BTCUSD", status: "PENDING" },
    });

    await service.placeOrder({
      profileId: "profile-1",
      side: "BUY",
      asset: "BTC",
      quoteAmount: "5.00",
      clientOrderId: "trade-1",
    });

    expect(request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: "POST",
        url: "/profiles/profile-1/orders",
        data: expect.objectContaining({
          side: "BUY",
          market: "BTCUSD",
          quote_amount: "5.00",
          ref_id: "trade-1",
        }),
      }),
    );
  });

  it("uses base_amount for sell orders", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    request.mockResolvedValue({
      data: { id: "paxos-order-1", side: "SELL", market: "ETHUSD", status: "PENDING" },
    });

    await service.placeOrder({
      profileId: "profile-1",
      side: "SELL",
      asset: "ETH",
      baseAmount: "0.25000000",
      clientOrderId: "trade-2",
    });

    expect(request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: "POST",
        url: "/profiles/profile-1/orders",
        data: expect.objectContaining({
          side: "SELL",
          market: "ETHUSD",
          base_amount: "0.25000000",
          ref_id: "trade-2",
        }),
      }),
    );
  });

  it("creates identities with passthrough Plaid verification metadata", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    request.mockResolvedValue({
      data: { id: "identity-1", ref_id: "user-1", status: "APPROVED" },
    });

    await service.createIdentity({
      userId: "user-1",
      email: "test@example.com",
      firstName: "Test",
      lastName: "User",
    });

    expect(request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: "POST",
        url: "/identity/identities",
        data: expect.objectContaining({
          ref_id: "user-1",
          person_details: expect.objectContaining({
            verifier_type: "PASSTHROUGH",
            passthrough_verifier_type: "PLAID",
            first_name: "Test",
            last_name: "User",
            email: "test@example.com",
          }),
          tax_details_not_required: true,
        }),
      }),
    );
  });

  it("uses the official profile creation payload", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    request.mockResolvedValue({
      data: { id: "profile-1", nickname: "user-1-crypto", type: "NORMAL" },
    });

    await service.createProfile("user-1-crypto", "Chronos crypto profile");

    expect(request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: "POST",
        url: "/profiles",
        data: {
          nickname: "user-1-crypto",
          description: "Chronos crypto profile",
        },
      }),
    );
  });

  it("maps Paxos insufficient balance errors", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    request.mockRejectedValue({ response: { status: 422, data: { reason: "no funds" } } });

    await expect(service.getBalances("profile-1")).rejects.toEqual(
      expect.objectContaining({
        code: "INSUFFICIENT_BALANCE",
        status: 422,
      }) as CryptoApiError,
    );
  });

  it.each([
    [400, "INVALID_ORDER"],
    [401, "PAXOS_AUTH_FAILED"],
    [403, "PAXOS_FORBIDDEN"],
    [404, "PAXOS_NOT_FOUND"],
    [409, "PAXOS_CONFLICT"],
    [429, "RATE_LIMITED"],
    [503, "PAXOS_UNAVAILABLE"],
    [504, "PAXOS_TIMEOUT"],
    [500, "PAXOS_ERROR"],
  ])("maps Paxos HTTP %s responses to %s", async (status, code) => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    request.mockRejectedValue({ response: { status, data: { reason: "bad request" } } });

    await expect(service.getBalances("profile-1")).rejects.toMatchObject({
      code,
      status,
      details: { reason: "bad request" },
    });
  });

  it("retries transient Paxos responses before mapping errors", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    request
      .mockRejectedValueOnce({ response: { status: 503, data: { reason: "temporarily down" } } })
      .mockResolvedValueOnce({ data: { items: [{ asset: "USD", available: "7.00" }] } });

    const balances = await service.getBalances("profile-1");

    expect(balances).toEqual([{ asset: "USD", available: "7.00" }]);
    expect(request).toHaveBeenCalledTimes(2);
  });

  it("returns profile balances and single-asset available balance", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    request.mockResolvedValue({
      data: {
        items: [
          { asset: "USD", available: "12.50" },
          { asset: "BTC", available: "0.01000000", trading: "0.00200000" },
        ],
      },
    });

    await expect(service.getBalances("profile-1")).resolves.toHaveLength(2);
    await expect(service.getBalance("profile-1", "btc")).resolves.toBe(0.01);

    expect(request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: "GET",
        url: "/profiles/profile-1/balances",
      }),
    );
  });

  it("polls orders until terminal fill and fails on terminal rejection", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    process.env.PAXOS_ORDER_POLL_INTERVAL_MS = "0";
    request
      .mockResolvedValueOnce({ data: { id: "order-1", status: "PENDING" } })
      .mockResolvedValueOnce({ data: { id: "order-1", status: "FILLED" } })
      .mockResolvedValueOnce({ data: { id: "order-2", status: "REJECTED" } });

    await expect(service.pollOrderUntilTerminal("profile-1", "order-1")).resolves.toMatchObject({
      id: "order-1",
      status: "FILLED",
    });
    await expect(service.pollOrderUntilTerminal("profile-1", "order-2")).rejects.toMatchObject({
      code: "ORDER_EXECUTION_FAILED",
      status: 502,
    });
  });

  it("times out order polling when no terminal status arrives", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    process.env.PAXOS_ORDER_POLL_INTERVAL_MS = "0";
    process.env.PAXOS_ORDER_POLL_ATTEMPTS = "2";
    request.mockResolvedValue({ data: { id: "order-1", status: "PENDING" } });

    await expect(service.pollOrderUntilTerminal("profile-1", "order-1")).rejects.toMatchObject({
      code: "ORDER_TIMEOUT",
      status: 504,
    });
    expect(request).toHaveBeenCalledTimes(2);
  });

  it("uses internal transfer endpoint for settlement credits", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    process.env.PAXOS_SETTLEMENT_PROFILE_ID = "settlement-1";
    request.mockResolvedValue({
      data: { id: "transfer-1", asset: "USD", amount: "5.00", status: "COMPLETED" },
    });

    await service.creditFromSettlement({
      profileId: "profile-1",
      amount: "5.00",
      asset: "USD",
      refId: "credit-1",
    });

    expect(request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: "POST",
        url: "/transfer/internal",
        data: expect.objectContaining({
          from_profile_id: "settlement-1",
          to_profile_id: "profile-1",
          asset: "USD",
          amount: "5.00",
        }),
      }),
    );
  });

  it("uses internal transfer endpoint for settlement debits and rejects missing settlement profile", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";

    await expect(
      service.debitToSettlement({
        profileId: "profile-1",
        amount: "5.00",
        asset: "USD",
        refId: "debit-1",
      }),
    ).rejects.toMatchObject({
      code: "PAXOS_SETTLEMENT_NOT_CONFIGURED",
      status: 503,
    });

    process.env.PAXOS_SETTLEMENT_PROFILE_ID = "settlement-1";
    request.mockResolvedValue({
      data: { id: "transfer-2", asset: "USD", amount: "5.00", status: "COMPLETED" },
    });

    await service.debitToSettlement({
      profileId: "profile-1",
      amount: "5.00",
      asset: "USD",
      refId: "debit-1",
    });

    expect(request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: "POST",
        url: "/transfer/internal",
        data: expect.objectContaining({
          from_profile_id: "profile-1",
          to_profile_id: "settlement-1",
          ref_id: "debit-1",
        }),
      }),
    );
  });

  it("filters transfer listing by profile_ids", async () => {
    process.env.PAXOS_CLIENT_ID = "client-1";
    process.env.PAXOS_CLIENT_SECRET = "secret-1";
    request.mockResolvedValue({ data: { items: [], next_page_cursor: "cursor-2" } });

    await service.listTransfers("profile-1", 25, "cursor-1");

    expect(request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: "GET",
        url: "/transfer/transfers",
        params: {
          profile_ids: "profile-1",
          limit: 25,
          page_cursor: "cursor-1",
        },
      }),
    );
  });
});
