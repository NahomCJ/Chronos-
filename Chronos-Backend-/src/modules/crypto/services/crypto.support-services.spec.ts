const mockPrisma = {
  auditLog: { create: jest.fn() },
  cryptoWallet: { findUnique: jest.fn() },
  bankingProfile: { findUnique: jest.fn() },
};

const mockPaxos = {
  getMarketPrice: jest.fn(),
  getAllMarketPrices: jest.fn(),
};

const mockCryptoService = {
  ensureWalletForUser: jest.fn(),
};

jest.mock("../../../models/prisma", () => ({
  __esModule: true,
  default: mockPrisma,
}));

jest.mock("./crypto.paxos.service", () => ({
  __esModule: true,
  default: mockPaxos,
}));

jest.mock("./crypto.service", () => ({
  __esModule: true,
  default: mockCryptoService,
}));

import auditService from "./crypto.audit.service";
import custodyService from "./crypto.custody.service";
import pricingService from "./crypto.pricing.service";
import riskService from "./crypto.risk.service";

describe("crypto support services", () => {
  let errorSpy: jest.SpyInstance;

  beforeEach(() => {
    jest.clearAllMocks();
    errorSpy = jest.spyOn(console, "error").mockImplementation(() => {});
  });

  afterEach(() => {
    errorSpy.mockRestore();
  });

  it("writes structured audit logs and omits null user ids", async () => {
    mockPrisma.auditLog.create.mockResolvedValue({});

    await auditService.log({
      action: "BUY_BTC",
      userId: null,
      amount: 5,
      asset: "BTC",
      metadata: { paxos_order_id: "order-1" },
    });

    expect(mockPrisma.auditLog.create).toHaveBeenCalledWith({
      data: {
        action: "BUY_BTC",
        userId: undefined,
        amount: 5,
        asset: "BTC",
        metadata: { paxos_order_id: "order-1" },
      },
    });
  });

  it("swallows audit-write failures so trading paths are not broken by logging", async () => {
    const error = new Error("db unavailable");
    mockPrisma.auditLog.create.mockRejectedValue(error);

    await expect(auditService.log({ action: "BUY_BTC_FAILED" })).resolves.toBeUndefined();

    expect(errorSpy).toHaveBeenCalledWith("Failed to write crypto audit log", error);
  });

  it("delegates pricing reads to Paxos service", async () => {
    mockPaxos.getMarketPrice.mockResolvedValue({ asset: "BTC", price: 65000 });
    mockPaxos.getAllMarketPrices.mockResolvedValue({ BTC: { asset: "BTC", price: 65000 } });

    await expect(pricingService.getPrice("BTC")).resolves.toEqual({ asset: "BTC", price: 65000 });
    await expect(pricingService.getAllPrices()).resolves.toEqual({
      BTC: { asset: "BTC", price: 65000 },
    });

    expect(mockPaxos.getMarketPrice).toHaveBeenCalledWith("BTC");
    expect(mockPaxos.getAllMarketPrices).toHaveBeenCalled();
  });

  it("delegates wallet provisioning and wallet lookup", async () => {
    const wallet = { id: "wallet-1", userId: "user-1" };
    mockCryptoService.ensureWalletForUser.mockResolvedValue(wallet);
    mockPrisma.cryptoWallet.findUnique.mockResolvedValue(wallet);

    await expect(custodyService.ensureWallet("user-1")).resolves.toBe(wallet);
    await expect(custodyService.getWallet("user-1")).resolves.toBe(wallet);

    expect(mockCryptoService.ensureWalletForUser).toHaveBeenCalledWith("user-1");
    expect(mockPrisma.cryptoWallet.findUnique).toHaveBeenCalledWith({
      where: { userId: "user-1" },
    });
  });

  it("allows approved KYC profiles and rejects unapproved profiles", async () => {
    mockPrisma.bankingProfile.findUnique.mockResolvedValue({
      status: "APPROVED",
      kycVerified: true,
    });
    await expect(riskService.assertKycCleared("user-1")).resolves.toBeUndefined();

    mockPrisma.bankingProfile.findUnique.mockResolvedValue({
      status: "PENDING",
      kycVerified: false,
    });
    await expect(riskService.assertKycCleared("user-1")).rejects.toMatchObject({
      code: "KYC_NOT_VERIFIED",
      status: 403,
    });
  });

  it("blocks AML-restricted assets", async () => {
    await expect(riskService.assertAmlOk("user-1", "BTC", "USD")).resolves.toBeUndefined();
    await expect(riskService.assertAmlOk("user-1", "XMR", "USD")).rejects.toMatchObject({
      code: "ASSET_RESTRICTED",
      status: 403,
    });
    await expect(riskService.assertAmlOk("user-1", "BTC", "ZEC")).rejects.toMatchObject({
      code: "ASSET_RESTRICTED",
      status: 403,
    });
  });
});
