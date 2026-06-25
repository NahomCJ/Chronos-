// Unit BaaS service unit tests (mocked — no real API calls)
import { UnitService } from "./unit.service";
import * as clientModule from "./unit.client";

jest.mock("./unit.client");

const mockCreate = jest.fn();
const mockGet = jest.fn();
const mockList = jest.fn();
const mockFreeze = jest.fn();
const mockUnfreeze = jest.fn();

const mockClient = {
  applications: { create: mockCreate },
  customers: { get: mockGet },
  accounts: { create: mockCreate, get: mockGet, list: mockList },
  cards: { create: mockCreate, get: mockGet, freeze: mockFreeze, unfreeze: mockUnfreeze },
  payments: { create: mockCreate, get: mockGet },
  transactions: { list: mockList },
};

(clientModule.getUnitClient as jest.Mock).mockReturnValue(mockClient);

describe("UnitService", () => {
  let service: UnitService;

  beforeEach(() => {
    service = new UnitService();
    jest.clearAllMocks();
  });

  describe("createIndividualCustomer", () => {
    it("returns customerId from application response", async () => {
      mockCreate.mockResolvedValue({
        data: {
          id: "app_123",
          attributes: { status: "Approved" },
          relationships: { customer: { data: { id: "cust_456" } } },
        },
      });

      const result = await service.createIndividualCustomer({
        firstName: "John",
        lastName: "Doe",
        email: "john@example.com",
        phone: "5105550100",
        ssn: "000000002",
        dateOfBirth: "1990-01-01",
        address: { street: "123 Main St", city: "Oakland", state: "CA", postalCode: "94610", country: "US" },
      });

      expect(result.unitApplicationId).toBe("app_123");
      expect(result.unitCustomerId).toBe("cust_456");
      expect(result.unitApplicationStatus).toBe("Approved");
    });

    it("throws if Unit returns no data", async () => {
      mockCreate.mockResolvedValue({ data: null });
      await expect(service.createIndividualCustomer({} as any)).rejects.toThrow(
        "Unit application creation failed"
      );
    });
  });

  describe("createDepositAccount", () => {
    it("maps account response correctly", async () => {
      mockCreate.mockResolvedValue({
        data: {
          id: "acc_789",
          attributes: {
            routingNumber: "021000021",
            accountNumber: "1000000001",
            balance: 0,
            status: "Open",
          },
        },
      });

      const result = await service.createDepositAccount({
        unitCustomerId: "cust_456",
      });

      expect(result.unitAccountId).toBe("acc_789");
      expect(result.routingNumber).toBe("021000021");
    });

    it("throws if Unit returns no data", async () => {
      mockCreate.mockResolvedValue({ data: null });
      await expect(service.createDepositAccount({ unitCustomerId: "x" })).rejects.toThrow(
        "Unit account creation failed"
      );
    });
  });

  describe("issueDebitCard", () => {
    it("creates a virtual card by default", async () => {
      mockCreate.mockResolvedValue({
        data: {
          id: "card_abc",
          type: "individualDebitCard",
          attributes: { last4Digits: "1234", status: "Active" },
        },
      });

      const result = await service.issueDebitCard({ unitAccountId: "acc_789" });
      expect(result.unitCardId).toBe("card_abc");
      expect(result.last4).toBe("1234");
      expect(result.type).toBe("individualDebitCard");
    });
  });

  describe("createTransfer - BOOK", () => {
    it("initiates a book payment", async () => {
      mockCreate.mockResolvedValue({
        data: {
          id: "pmt_001",
          attributes: { status: "Sent", amount: 5000, createdAt: "2026-06-22T00:00:00Z" },
        },
      });

      const result = await service.createTransfer({
        fromUnitAccountId: "acc_a",
        toUnitAccountId: "acc_b",
        amount: 5000,
        type: "BOOK",
      });

      expect(result.unitTransferId).toBe("pmt_001");
      expect(result.amount).toBe(5000);
    });
  });

  describe("freezeCard / unfreezeCard", () => {
    it("calls freeze on the client", async () => {
      mockFreeze.mockResolvedValue({ data: {} });
      await service.freezeCard("card_abc");
      expect(mockFreeze).toHaveBeenCalledWith("card_abc");
    });

    it("calls unfreeze on the client", async () => {
      mockUnfreeze.mockResolvedValue({ data: {} });
      await service.unfreezeCard("card_abc");
      expect(mockUnfreeze).toHaveBeenCalledWith("card_abc");
    });
  });
});
