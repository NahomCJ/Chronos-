const mockPrisma = {
  bankingProfile: { findUnique: jest.fn() },
  cryptoWallet: { findUnique: jest.fn(), create: jest.fn() },
  user: { findUnique: jest.fn() },
  auditLog: { findFirst: jest.fn(), create: jest.fn() },
  trade: { aggregate: jest.fn(), findMany: jest.fn(), count: jest.fn() },
  portfolioHolding: { findMany: jest.fn() },
  $transaction: jest.fn(),
};

const mockAudit = {
  log: jest.fn(),
};

const mockPaxos = {
  isConfigured: jest.fn(),
  assertConfigured: jest.fn(),
  normalizeAsset: jest.fn((asset: string) => asset.toUpperCase()),
  getAllMarketPrices: jest.fn(),
  getBalances: jest.fn(),
  getBalance: jest.fn(),
  getMarketPrice: jest.fn(),
  placeOrder: jest.fn(),
  pollOrderUntilTerminal: jest.fn(),
  listTransfers: jest.fn(),
  createIdentity: jest.fn(),
  createProfile: jest.fn(),
};

jest.mock("../../../models/prisma", () => ({
  __esModule: true,
  default: mockPrisma,
}));

jest.mock("./crypto.audit.service", () => ({
  __esModule: true,
  default: mockAudit,
}));

jest.mock("./crypto.paxos.service", () => ({
  __esModule: true,
  default: mockPaxos,
  SUPPORTED_CRYPTO_ASSETS: ["BTC", "ETH", "SOL", "UNI", "AAVE", "LINK"],
}));

import cryptoService from "./crypto.service";

describe("CryptoService", () => {
  const wallet = {
    id: "wallet-1",
    userId: "user-1",
    paxosCustomerId: "identity-1",
    paxosWalletId: "profile-1",
    createdAt: new Date("2026-06-06T00:00:00Z"),
  };

  const tx = {
    trade: { create: jest.fn() },
    portfolioHolding: { findUnique: jest.fn(), create: jest.fn(), update: jest.fn() },
    revenue: { createMany: jest.fn() },
  };

  beforeEach(() => {
    jest.clearAllMocks();
    process.env.FEE_RATE_DEFAULT = "0.005";
    process.env.SPREAD_RATE = "0.002";
    mockPaxos.isConfigured.mockReturnValue(true);
    mockPaxos.assertConfigured.mockReturnValue(undefined);
    mockPrisma.bankingProfile.findUnique.mockResolvedValue({
      userId: "user-1",
      status: "APPROVED",
      kycVerified: true,
      frozen: false,
    });
    mockPrisma.cryptoWallet.findUnique.mockResolvedValue(wallet);
    mockPrisma.auditLog.findFirst.mockResolvedValue(null);
    mockPrisma.user.findUnique.mockResolvedValue({ tier: "standard" });
    mockPrisma.trade.aggregate.mockResolvedValue({ _sum: { amountUsd: 0 } });
    mockPrisma.$transaction.mockImplementation(async (fn: any) => fn(tx));
    tx.trade.create.mockResolvedValue({ id: "trade-1" });
    tx.portfolioHolding.findUnique.mockResolvedValue(null);
    tx.portfolioHolding.create.mockResolvedValue({});
    tx.portfolioHolding.update.mockResolvedValue({});
    tx.revenue.createMany.mockResolvedValue({ count: 2 });
    mockPaxos.getBalance.mockResolvedValue(1000);
    mockPaxos.getMarketPrice.mockResolvedValue({
      asset: "BTC",
      market: "BTCUSD",
      price: 50000,
      source: "paxos",
      updated_at: "2026-06-06T00:00:00Z",
    });
    mockPaxos.placeOrder.mockResolvedValue({ id: "paxos-order-1", status: "PENDING" });
    mockPaxos.pollOrderUntilTerminal.mockResolvedValue({
      id: "paxos-order-1",
      side: "BUY",
      market: "BTCUSD",
      status: "FILLED",
      fill_price: "50100.00",
      base_amount: "0.00009930",
      quote_amount: "4.98",
      filled_at: "2026-06-06T00:00:01Z",
    });
  });

  it("rejects trading with 503 before Prisma calls when Paxos is not configured", async () => {
    mockPaxos.assertConfigured.mockImplementationOnce(() => {
      throw Object.assign(new Error("Paxos disabled"), {
        code: "PAXOS_NOT_CONFIGURED",
        status: 503,
      });
    });

    await expect(
      cryptoService.buy("user-1", { asset: "BTC", amount_usd: 5 }),
    ).rejects.toMatchObject({
      code: "PAXOS_NOT_CONFIGURED",
      status: 503,
    });

    expect(mockPrisma.bankingProfile.findUnique).not.toHaveBeenCalled();
    expect(mockPaxos.placeOrder).not.toHaveBeenCalled();
  });

  it("rejects buys before order placement when KYC has not passed", async () => {
    mockPrisma.bankingProfile.findUnique.mockResolvedValue({
      userId: "user-1",
      status: "PENDING",
      kycVerified: false,
      frozen: false,
    });

    await expect(
      cryptoService.buy("user-1", { asset: "BTC", amount_usd: 5 }),
    ).rejects.toMatchObject({
      code: "KYC_NOT_VERIFIED",
      status: 403,
    });

    expect(mockPaxos.placeOrder).not.toHaveBeenCalled();
    expect(mockAudit.log).toHaveBeenCalledWith(
      expect.objectContaining({
        action: "COMPLIANCE_REJECTED",
        metadata: expect.objectContaining({ reason: "KYC_NOT_VERIFIED" }),
      }),
    );
  });

  it("rejects suspended accounts before the KYC-not-verified check", async () => {
    mockPrisma.bankingProfile.findUnique.mockResolvedValue({
      userId: "user-1",
      status: "SUSPENDED",
      kycVerified: false,
      frozen: true,
    });

    await expect(
      cryptoService.buy("user-1", { asset: "BTC", amount_usd: 5 }),
    ).rejects.toMatchObject({
      code: "ACCOUNT_SUSPENDED",
      status: 403,
    });

    expect(mockAudit.log).toHaveBeenCalledWith(
      expect.objectContaining({
        action: "COMPLIANCE_REJECTED",
        metadata: expect.objectContaining({ reason: "ACCOUNT_SUSPENDED" }),
      }),
    );
    expect(mockPaxos.placeOrder).not.toHaveBeenCalled();
  });

  it("rejects trades when the Paxos wallet is missing", async () => {
    mockPrisma.cryptoWallet.findUnique.mockResolvedValue(null);

    await expect(
      cryptoService.buy("user-1", { asset: "BTC", amount_usd: 5 }),
    ).rejects.toMatchObject({
      code: "WALLET_NOT_FOUND",
      status: 403,
    });

    expect(mockPaxos.getBalance).not.toHaveBeenCalled();
    expect(mockPaxos.placeOrder).not.toHaveBeenCalled();
  });

  it("rejects flagged users before checking Paxos balances", async () => {
    mockPrisma.auditLog.findFirst.mockResolvedValue({ id: "flag-1", action: "ACCOUNT_FLAGGED" });

    await expect(
      cryptoService.buy("user-1", { asset: "BTC", amount_usd: 5 }),
    ).rejects.toMatchObject({
      code: "ACCOUNT_FLAGGED",
      status: 403,
    });

    expect(mockPaxos.getBalance).not.toHaveBeenCalled();
    expect(mockPaxos.placeOrder).not.toHaveBeenCalled();
  });

  it("rejects trades over the configured daily limit", async () => {
    mockPrisma.trade.aggregate.mockResolvedValue({ _sum: { amountUsd: "9998.00" } });

    await expect(
      cryptoService.buy("user-1", { asset: "BTC", amount_usd: 5 }),
    ).rejects.toMatchObject({
      code: "DAILY_LIMIT_EXCEEDED",
      status: 403,
    });

    expect(mockAudit.log).toHaveBeenCalledWith(
      expect.objectContaining({
        action: "COMPLIANCE_REJECTED",
        metadata: expect.objectContaining({
          reason: "DAILY_LIMIT_EXCEEDED",
          today_volume: "9998.00",
          incoming_notional_usd: "5.00",
          limit: 10000,
        }),
      }),
    );
    expect(mockPaxos.placeOrder).not.toHaveBeenCalled();
  });

  it("rejects buys when USD balance is insufficient", async () => {
    mockPaxos.getBalance.mockResolvedValue(1);

    await expect(
      cryptoService.buy("user-1", { asset: "BTC", amount_usd: 5 }),
    ).rejects.toMatchObject({
      code: "INSUFFICIENT_BALANCE",
      status: 422,
    });

    expect(mockPaxos.placeOrder).not.toHaveBeenCalled();
  });

  it("rejects sells when crypto balance is insufficient", async () => {
    mockPaxos.getBalance.mockResolvedValue(0.00001);

    await expect(
      cryptoService.sell("user-1", { asset: "BTC", amount_crypto: 0.0001 }),
    ).rejects.toMatchObject({
      code: "INSUFFICIENT_CRYPTO_BALANCE",
      status: 422,
    });

    expect(mockPaxos.placeOrder).not.toHaveBeenCalled();
  });

  it("executes a buy with atomic trade, holding, revenue, and audit writes", async () => {
    const result = await cryptoService.buy("user-1", { asset: "BTC", amount_usd: 5 });

    expect(result).toMatchObject({
      asset: "BTC",
      status: "filled",
      fee: 0.03,
      crypto_received: 0.0000993,
      paxos_order_id: "paxos-order-1",
    });
    expect(mockPaxos.placeOrder).toHaveBeenCalledWith(
      expect.objectContaining({
        profileId: "profile-1",
        side: "BUY",
        asset: "BTC",
        quoteAmount: "4.98",
      }),
    );
    expect(tx.trade.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          userId: "user-1",
          asset: "BTC",
          side: "BUY",
          status: "FILLED",
          paxosOrderId: "paxos-order-1",
        }),
      }),
    );
    expect(tx.portfolioHolding.create).toHaveBeenCalled();
    expect(tx.revenue.createMany).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.arrayContaining([
          expect.objectContaining({ type: "TRADE_FEE" }),
          expect.objectContaining({ type: "SPREAD" }),
        ]),
      }),
    );
    expect(mockAudit.log).toHaveBeenCalledWith(
      expect.objectContaining({ action: "BUY_BTC", userId: "user-1" }),
    );
  });

  it("updates existing holdings with a weighted average buy price", async () => {
    tx.portfolioHolding.findUnique.mockResolvedValue({
      amount: "0.01000000",
      avgPrice: "40000.00",
    });

    await cryptoService.buy("user-1", { asset: "BTC", amount_usd: 5 });

    expect(tx.portfolioHolding.create).not.toHaveBeenCalled();
    expect(tx.portfolioHolding.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { userId_asset: { userId: "user-1", asset: "BTC" } },
        data: expect.objectContaining({
          amount: "0.01009930",
          avgPrice: "40099.31",
        }),
      }),
    );
  });

  it("audits and rethrows order placement failures without DB writes", async () => {
    const paxosError = Object.assign(new Error("Paxos rejected order"), {
      code: "INVALID_ORDER",
      status: 400,
      details: { reason: "bad order" },
    });
    mockPaxos.placeOrder.mockRejectedValue(paxosError);

    await expect(
      cryptoService.buy("user-1", { asset: "BTC", amount_usd: 5 }),
    ).rejects.toMatchObject({
      code: "INVALID_ORDER",
      status: 400,
    });

    expect(mockPrisma.$transaction).not.toHaveBeenCalled();
    expect(mockAudit.log).toHaveBeenCalledWith(
      expect.objectContaining({
        action: "BUY_BTC_FAILED",
        metadata: expect.objectContaining({
          code: "INVALID_ORDER",
          message: "Paxos rejected order",
          details: { reason: "bad order" },
        }),
      }),
    );
  });

  it("executes a sell and reduces local holdings without failing on over-sell drift", async () => {
    tx.portfolioHolding.findUnique.mockResolvedValue({
      amount: "0.00005",
      avgPrice: "50000.00",
    });
    mockPaxos.pollOrderUntilTerminal.mockResolvedValue({
      id: "paxos-sell-1",
      side: "SELL",
      market: "BTCUSD",
      status: "FILLED",
      fill_price: "49900.00",
      base_amount: "0.00010000",
      quote_amount: "4.99",
      filled_at: "2026-06-06T00:00:01Z",
    });

    const result = await cryptoService.sell("user-1", { asset: "BTC", amount_crypto: 0.0001 });

    expect(result).toMatchObject({
      asset: "BTC",
      status: "filled",
      gross_usd: 4.99,
      paxos_order_id: "paxos-sell-1",
    });
    expect(tx.portfolioHolding.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: { amount: "0.00000000" },
      }),
    );
  });

  it("returns trade history and Paxos transfer references", async () => {
    const createdAt = new Date("2026-06-06T00:00:00Z");
    const filledAt = new Date("2026-06-06T00:00:01Z");
    mockPrisma.trade.findMany.mockResolvedValue([
      {
        id: "trade-1",
        side: "BUY",
        asset: "BTC",
        amountUsd: "5.00",
        amountCrypto: "0.00009930",
        fee: "0.03",
        executionPrice: "50100.00",
        paxosOrderId: "paxos-order-1",
        status: "FILLED",
        createdAt,
        filledAt,
      },
    ]);
    mockPrisma.trade.count.mockResolvedValue(1);
    mockPaxos.listTransfers.mockResolvedValue({
      items: [{ id: "transfer-1", asset: "USD", amount: "5.00", status: "COMPLETED" }],
      next_page_cursor: "cursor-2",
    });

    const history = await cryptoService.getHistory("user-1", {
      page: 2,
      limit: 10,
      asset: "BTC",
      from: new Date("2026-06-01T00:00:00Z"),
      to: new Date("2026-06-30T00:00:00Z"),
      cursor: "cursor-1",
    });

    expect(mockPrisma.trade.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          userId: "user-1",
          asset: "BTC",
          createdAt: {
            gte: new Date("2026-06-01T00:00:00Z"),
            lte: new Date("2026-06-30T00:00:00Z"),
          },
        },
        skip: 10,
        take: 10,
      }),
    );
    expect(mockPaxos.listTransfers).toHaveBeenCalledWith("profile-1", 10, "cursor-1");
    expect(history).toMatchObject({
      page: 2,
      limit: 10,
      total: 1,
      transactions: [
        {
          id: "trade-1",
          type: "trade",
          side: "BUY",
          asset: "BTC",
          amount_usd: 5,
          amount_crypto: 0.0000993,
          status: "filled",
        },
      ],
      transfers: [{ id: "transfer-1", asset: "USD", amount: "5.00", status: "COMPLETED" }],
      next_transfer_cursor: "cursor-2",
    });
  });

  it("omits Paxos transfer lookup from history when Paxos is disabled", async () => {
    mockPaxos.isConfigured.mockReturnValue(false);
    mockPrisma.trade.findMany.mockResolvedValue([]);
    mockPrisma.trade.count.mockResolvedValue(0);

    const history = await cryptoService.getHistory("user-1", { page: 1, limit: 25 });

    expect(mockPaxos.listTransfers).not.toHaveBeenCalled();
    expect(history).toMatchObject({ transactions: [], transfers: [] });
  });

  it("returns dashboard wallet, balances, portfolio, and supported assets", async () => {
    mockPaxos.getAllMarketPrices.mockResolvedValue({
      BTC: { asset: "BTC", market: "BTCUSD", price: 50000, source: "paxos", updated_at: "now" },
      ETH: { asset: "ETH", market: "ETHUSD", price: 3000, source: "paxos", updated_at: "now" },
      SOL: { asset: "SOL", market: "SOLUSD", price: 100, source: "paxos", updated_at: "now" },
      UNI: { asset: "UNI", market: "UNIUSD", price: 5, source: "paxos", updated_at: "now" },
      AAVE: { asset: "AAVE", market: "AAVEUSD", price: 80, source: "paxos", updated_at: "now" },
      LINK: { asset: "LINK", market: "LINKUSD", price: 12, source: "paxos", updated_at: "now" },
    });
    mockPaxos.getBalances.mockResolvedValue([{ asset: "USD", available: "10.00" }]);
    mockPrisma.portfolioHolding.findMany.mockResolvedValue([
      { asset: "BTC", amount: "0.01000000", avgPrice: "40000.00" },
    ]);

    const dashboard = await cryptoService.getDashboard("user-1");

    expect(dashboard.wallet).toMatchObject({ status: "ready", paxosWalletId: "profile-1" });
    expect(dashboard.balances).toEqual([{ asset: "USD", available: 10 }]);
    expect(dashboard.portfolio.holdings[0]).toMatchObject({
      asset: "BTC",
      current_value: 500,
      unrealized_pnl: 100,
    });
    expect(dashboard.supported_assets).toEqual(["BTC", "ETH", "SOL", "UNI", "AAVE", "LINK"]);
  });

  it("lazy provisions an approved user wallet during dashboard recovery", async () => {
    const createdWallet = {
      ...wallet,
      id: "wallet-created",
      paxosCustomerId: "identity-created",
      paxosWalletId: "profile-created",
    };
    mockPrisma.cryptoWallet.findUnique
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce(createdWallet);
    mockPaxos.createIdentity.mockResolvedValue({ id: "identity-created" });
    mockPaxos.createProfile.mockResolvedValue({ id: "profile-created" });
    mockPrisma.cryptoWallet.create.mockResolvedValue(createdWallet);
    mockPrisma.user.findUnique.mockResolvedValue({
      email: "test@example.com",
      firstName: "Test",
      lastName: "User",
    });
    mockPaxos.getAllMarketPrices.mockResolvedValue({
      BTC: { asset: "BTC", market: "BTCUSD", price: 50000, source: "paxos", updated_at: "now" },
      ETH: { asset: "ETH", market: "ETHUSD", price: 3000, source: "paxos", updated_at: "now" },
      SOL: { asset: "SOL", market: "SOLUSD", price: 100, source: "paxos", updated_at: "now" },
      UNI: { asset: "UNI", market: "UNIUSD", price: 5, source: "paxos", updated_at: "now" },
      AAVE: { asset: "AAVE", market: "AAVEUSD", price: 80, source: "paxos", updated_at: "now" },
      LINK: { asset: "LINK", market: "LINKUSD", price: 12, source: "paxos", updated_at: "now" },
    });
    mockPaxos.getBalances.mockResolvedValue([]);
    mockPrisma.portfolioHolding.findMany.mockResolvedValue([]);

    const dashboard = await cryptoService.getDashboard("user-1");

    expect(mockPaxos.createIdentity).toHaveBeenCalledWith(
      expect.objectContaining({
        userId: "user-1",
      }),
    );
    expect(mockPaxos.createProfile).toHaveBeenCalledWith(
      "user-1-crypto",
      "Chronos crypto profile for test@example.com",
    );
    expect(dashboard.wallet).toMatchObject({
      status: "ready",
      paxosWalletId: "profile-created",
    });
  });

  it("reports not_configured dashboard wallet status without throwing", async () => {
    mockPrisma.cryptoWallet.findUnique.mockResolvedValue(null);
    mockPaxos.isConfigured.mockReturnValue(false);
    mockPaxos.getAllMarketPrices.mockResolvedValue({
      BTC: { asset: "BTC", market: "BTCUSD", price: 50000, source: "coingecko", updated_at: "now" },
      ETH: { asset: "ETH", market: "ETHUSD", price: 3000, source: "coingecko", updated_at: "now" },
      SOL: { asset: "SOL", market: "SOLUSD", price: 100, source: "coingecko", updated_at: "now" },
      UNI: { asset: "UNI", market: "UNIUSD", price: 5, source: "coingecko", updated_at: "now" },
      AAVE: { asset: "AAVE", market: "AAVEUSD", price: 80, source: "coingecko", updated_at: "now" },
      LINK: { asset: "LINK", market: "LINKUSD", price: 12, source: "coingecko", updated_at: "now" },
    });
    mockPrisma.portfolioHolding.findMany.mockResolvedValue([]);

    const dashboard = await cryptoService.getDashboard("user-1");

    expect(dashboard.wallet).toMatchObject({ status: "not_configured" });
    expect(dashboard.balances).toEqual([]);
  });

  it("returns an existing Paxos account without creating another identity", async () => {
    const account = await cryptoService.provisionAccount("user-1");

    expect(account).toMatchObject({
      created: false,
      paxos: { configured: true },
      wallet: {
        status: "ready",
        id: "wallet-1",
        paxosCustomerId: "identity-1",
        paxosWalletId: "profile-1",
      },
    });
    expect(mockPaxos.assertConfigured).not.toHaveBeenCalled();
    expect(mockPaxos.createIdentity).not.toHaveBeenCalled();
    expect(mockPaxos.createProfile).not.toHaveBeenCalled();
    expect(mockPrisma.cryptoWallet.create).not.toHaveBeenCalled();
  });

  it("creates a Paxos sandbox account for an approved user", async () => {
    const createdWallet = {
      ...wallet,
      id: "wallet-created",
      paxosCustomerId: "identity-created",
      paxosWalletId: "profile-created",
    };
    mockPrisma.cryptoWallet.findUnique
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce(null);
    mockPrisma.user.findUnique.mockResolvedValue({
      email: "test@example.com",
      firstName: "Test",
      lastName: "User",
    });
    mockPaxos.createIdentity.mockResolvedValue({ id: "identity-created" });
    mockPaxos.createProfile.mockResolvedValue({ id: "profile-created" });
    mockPrisma.cryptoWallet.create.mockResolvedValue(createdWallet);

    const account = await cryptoService.provisionAccount("user-1");

    expect(mockPaxos.assertConfigured).toHaveBeenCalled();
    expect(mockPrisma.bankingProfile.findUnique).toHaveBeenCalledWith({
      where: { userId: "user-1" },
    });
    expect(mockPaxos.createIdentity).toHaveBeenCalledWith({
      userId: "user-1",
      email: "test@example.com",
      firstName: "Test",
      lastName: "User",
    });
    expect(mockPaxos.createProfile).toHaveBeenCalledWith(
      "user-1-crypto",
      "Chronos crypto profile for test@example.com",
    );
    expect(account).toMatchObject({
      created: true,
      wallet: {
        status: "ready",
        id: "wallet-created",
        paxosCustomerId: "identity-created",
        paxosWalletId: "profile-created",
      },
    });
  });

  it("blocks Paxos account provisioning until KYC is approved", async () => {
    mockPrisma.cryptoWallet.findUnique.mockResolvedValue(null);
    mockPrisma.bankingProfile.findUnique.mockResolvedValue({
      userId: "user-1",
      status: "PENDING",
      kycVerified: false,
      frozen: false,
    });

    await expect(cryptoService.provisionAccount("user-1")).rejects.toMatchObject({
      code: "KYC_NOT_VERIFIED",
      status: 403,
    });

    expect(mockPaxos.createIdentity).not.toHaveBeenCalled();
    expect(mockPaxos.createProfile).not.toHaveBeenCalled();
    expect(mockAudit.log).toHaveBeenCalledWith(
      expect.objectContaining({
        action: "COMPLIANCE_REJECTED",
        metadata: expect.objectContaining({ reason: "KYC_NOT_VERIFIED" }),
      }),
    );
  });

  it("returns Paxos configuration errors before provisioning a new account", async () => {
    mockPrisma.cryptoWallet.findUnique.mockResolvedValue(null);
    mockPaxos.assertConfigured.mockImplementationOnce(() => {
      throw Object.assign(new Error("Paxos disabled"), {
        code: "PAXOS_NOT_CONFIGURED",
        status: 503,
      });
    });

    await expect(cryptoService.provisionAccount("user-1")).rejects.toMatchObject({
      code: "PAXOS_NOT_CONFIGURED",
      status: 503,
    });

    expect(mockPrisma.bankingProfile.findUnique).not.toHaveBeenCalled();
    expect(mockPaxos.createIdentity).not.toHaveBeenCalled();
  });

  it("idempotently returns an existing wallet without Paxos calls", async () => {
    await expect(cryptoService.ensureWalletForUser("user-1")).resolves.toBe(wallet);

    expect(mockPaxos.createIdentity).not.toHaveBeenCalled();
    expect(mockPaxos.createProfile).not.toHaveBeenCalled();
    expect(mockPrisma.cryptoWallet.create).not.toHaveBeenCalled();
  });

  it("creates and audits a new Paxos wallet for approved users", async () => {
    const createdWallet = {
      ...wallet,
      id: "wallet-created",
      paxosCustomerId: "identity-created",
      paxosWalletId: "profile-created",
    };
    mockPrisma.cryptoWallet.findUnique.mockResolvedValue(null);
    mockPrisma.user.findUnique.mockResolvedValue({
      email: "test@example.com",
      firstName: "Test",
      lastName: "User",
    });
    mockPaxos.createIdentity.mockResolvedValue({ id: "identity-created" });
    mockPaxos.createProfile.mockResolvedValue({ id: "profile-created" });
    mockPrisma.cryptoWallet.create.mockResolvedValue(createdWallet);

    await expect(cryptoService.ensureWalletForUser("user-1")).resolves.toBe(createdWallet);

    expect(mockPrisma.cryptoWallet.create).toHaveBeenCalledWith({
      data: {
        userId: "user-1",
        paxosCustomerId: "identity-created",
        paxosWalletId: "profile-created",
      },
    });
    expect(mockAudit.log).toHaveBeenCalledWith(
      expect.objectContaining({
        action: "WALLET_CREATED",
        userId: "user-1",
        metadata: {
          paxos_identity_id: "identity-created",
          paxos_profile_id: "profile-created",
        },
      }),
    );
  });

  it("recovers from concurrent wallet creation unique conflicts", async () => {
    const createdByOtherRequest = { ...wallet, id: "wallet-race" };
    mockPrisma.cryptoWallet.findUnique
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce(createdByOtherRequest);
    mockPrisma.user.findUnique.mockResolvedValue({
      email: "test@example.com",
      firstName: "Test",
      lastName: "User",
    });
    mockPaxos.createIdentity.mockResolvedValue({ id: "identity-created" });
    mockPaxos.createProfile.mockResolvedValue({ id: "profile-created" });
    mockPrisma.cryptoWallet.create.mockRejectedValue({ code: "P2002" });

    await expect(cryptoService.ensureWalletForUser("user-1")).resolves.toBe(createdByOtherRequest);
  });

  it("audits wallet provisioning failures", async () => {
    mockPrisma.cryptoWallet.findUnique.mockResolvedValue(null);
    mockPrisma.user.findUnique.mockResolvedValue({
      email: "test@example.com",
      firstName: "Test",
      lastName: "User",
    });
    mockPaxos.createIdentity.mockRejectedValue(new Error("identity failed"));

    await expect(cryptoService.ensureWalletForUser("user-1")).rejects.toThrow("identity failed");
    expect(mockAudit.log).toHaveBeenCalledWith(
      expect.objectContaining({
        action: "WALLET_PROVISION_FAILED",
        userId: "user-1",
        metadata: expect.objectContaining({ message: "identity failed" }),
      }),
    );
  });

  it("returns a normalized public price payload", async () => {
    const price = await cryptoService.getPrice("btc");

    expect(mockPaxos.getMarketPrice).toHaveBeenCalledWith("btc");
    expect(price).toEqual({
      asset: "BTC",
      market: "BTCUSD",
      price: 50000,
      source: "paxos",
      updated_at: "2026-06-06T00:00:00Z",
    });
  });
});
