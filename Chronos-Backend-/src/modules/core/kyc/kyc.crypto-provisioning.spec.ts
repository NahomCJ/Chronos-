const mockPrisma = {
  bankingProfile: {
    findUnique: jest.fn(),
    update: jest.fn(),
    updateMany: jest.fn(),
    findMany: jest.fn(),
  },
  user: { findUnique: jest.fn() },
};

const mockPlaidClient = {
  identityVerificationGet: jest.fn(),
};

const mockCryptoService = {
  ensureWalletForUser: jest.fn(),
};

const mockNotifyUser = jest.fn();

jest.mock("../../../config/prisma", () => ({
  __esModule: true,
  default: mockPrisma,
}));

jest.mock("../../../config/plaid", () => ({
  plaidClient: mockPlaidClient,
}));

jest.mock("../../crypto/services/crypto.service", () => ({
  __esModule: true,
  default: mockCryptoService,
}));

jest.mock("../../notification/notificatoin.service", () => ({
  NotificationService: {
    notifyUser: mockNotifyUser,
  },
}));

jest.mock("../../notification/email.templates", () => ({
  kycApproved: jest.fn((name?: string) => `approved ${name || "there"}`),
  kycRejected: jest.fn((name?: string) => `rejected ${name || "there"}`),
  kycBankReauthRequired: jest.fn(() => "reauth required"),
}));

import { KycService } from "./kyc.service";

describe("KycService crypto wallet provisioning hooks", () => {
  let service: KycService;
  let warnSpy: jest.SpyInstance;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new KycService();
    warnSpy = jest.spyOn(console, "warn").mockImplementation(() => {});
    mockCryptoService.ensureWalletForUser.mockResolvedValue({ id: "wallet-1" });
    mockNotifyUser.mockResolvedValue(undefined);
  });

  afterEach(() => {
    warnSpy.mockRestore();
  });

  it("provisions a crypto wallet after admin KYC approval", async () => {
    const approvedProfile = {
      userId: "user-1",
      status: "APPROVED",
      kycVerified: true,
      riskLevel: "LOW",
    };
    mockPrisma.bankingProfile.update.mockResolvedValue(approvedProfile);

    await expect(service.approveKyc("user-1", "LOW")).resolves.toBe(approvedProfile);

    expect(mockPrisma.bankingProfile.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { userId: "user-1" },
        data: expect.objectContaining({
          status: "APPROVED",
          kycVerified: true,
          riskLevel: "LOW",
          approvedAt: expect.any(Date),
        }),
      }),
    );
    expect(mockCryptoService.ensureWalletForUser).toHaveBeenCalledWith("user-1");
  });

  it("does not fail admin KYC approval when wallet provisioning rejects", async () => {
    const approvedProfile = { userId: "user-1", status: "APPROVED", kycVerified: true };
    mockPrisma.bankingProfile.update.mockResolvedValue(approvedProfile);
    mockCryptoService.ensureWalletForUser.mockRejectedValue(new Error("Paxos unavailable"));

    await expect(service.approveKyc("user-1", "LOW")).resolves.toBe(approvedProfile);
    await Promise.resolve();

    expect(warnSpy).toHaveBeenCalledWith(
      "Crypto wallet provisioning failed for user-1: Paxos unavailable",
    );
  });

  it("provisions a crypto wallet when a Plaid IDV session completes successfully", async () => {
    mockPrisma.bankingProfile.findUnique.mockResolvedValue({ userId: "user-1", status: "PENDING" });
    mockPlaidClient.identityVerificationGet.mockResolvedValue({
      data: { status: "success" },
    });
    mockPrisma.bankingProfile.update.mockResolvedValue({});

    const result = await service.completeKycSession("user-1", "idv-1");

    expect(result).toEqual({ plaidStatus: "success", internalStatus: "APPROVED" });
    expect(mockPrisma.bankingProfile.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { userId: "user-1" },
        data: expect.objectContaining({
          plaidIdvId: "idv-1",
          plaidStatus: "success",
          status: "APPROVED",
          kycVerified: true,
          approvedAt: expect.any(Date),
        }),
      }),
    );
    expect(mockCryptoService.ensureWalletForUser).toHaveBeenCalledWith("user-1");
  });

  it("does not provision a crypto wallet when a Plaid IDV session fails", async () => {
    mockPrisma.bankingProfile.findUnique.mockResolvedValue({ userId: "user-1", status: "PENDING" });
    mockPlaidClient.identityVerificationGet.mockResolvedValue({
      data: { status: "failed" },
    });
    mockPrisma.bankingProfile.update.mockResolvedValue({});

    const result = await service.completeKycSession("user-1", "idv-1");

    expect(result).toEqual({ plaidStatus: "failed", internalStatus: "REJECTED" });
    expect(mockCryptoService.ensureWalletForUser).not.toHaveBeenCalled();
  });

  it("provisions wallets and sends notifications for approved Plaid webhook profiles", async () => {
    mockPlaidClient.identityVerificationGet.mockResolvedValue({
      data: { status: "success" },
    });
    mockPrisma.bankingProfile.updateMany.mockResolvedValue({ count: 2 });
    mockPrisma.bankingProfile.findMany.mockResolvedValue([
      { userId: "user-1" },
      { userId: "user-2" },
    ]);
    mockPrisma.user.findUnique
      .mockResolvedValueOnce({ firstName: "Ada" })
      .mockResolvedValueOnce({ firstName: "Grace" });

    await service.handlePlaidWebhook({
      webhook_type: "IDENTITY_VERIFICATION",
      webhook_code: "STATUS_UPDATED",
      identity_verification_id: "idv-1",
      environment: "sandbox",
    });

    expect(mockPrisma.bankingProfile.updateMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { plaidIdvId: "idv-1" },
        data: expect.objectContaining({
          status: "APPROVED",
          kycVerified: true,
        }),
      }),
    );
    expect(mockCryptoService.ensureWalletForUser).toHaveBeenCalledTimes(2);
    expect(mockCryptoService.ensureWalletForUser).toHaveBeenCalledWith("user-1");
    expect(mockCryptoService.ensureWalletForUser).toHaveBeenCalledWith("user-2");
    expect(mockNotifyUser).toHaveBeenCalledTimes(2);
  });

  it("ignores Plaid IDV webhook events that are not status updates", async () => {
    await service.handlePlaidWebhook({
      webhook_type: "IDENTITY_VERIFICATION",
      webhook_code: "STEP_UPDATED",
      identity_verification_id: "idv-1",
      environment: "sandbox",
    });

    expect(mockPlaidClient.identityVerificationGet).not.toHaveBeenCalled();
    expect(mockCryptoService.ensureWalletForUser).not.toHaveBeenCalled();
  });
});
