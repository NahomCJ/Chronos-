import { getUnitClient } from "./unit.client";
import {
  CreateUnitCustomerInput,
  UnitCustomerResult,
  CreateUnitAccountInput,
  UnitAccountResult,
  CreateUnitCardInput,
  UnitCardResult,
  CreateUnitTransferInput,
  UnitTransferResult,
} from "./unit.types";

export class UnitService {
  // ── Customers ────────────────────────────────────────────────────────────────

  async createIndividualCustomer(
    input: CreateUnitCustomerInput
  ): Promise<UnitCustomerResult> {
    const client = getUnitClient();

    const res = await client.applications.create({
      type: "individualApplication",
      attributes: {
        ssn: input.ssn,
        fullName: { first: input.firstName, last: input.lastName },
        dateOfBirth: input.dateOfBirth,
        address: {
          street: input.address.street,
          city: input.address.city,
          state: input.address.state,
          postalCode: input.address.postalCode,
          country: input.address.country,
        },
        email: input.email,
        phone: { countryCode: "1", number: input.phone.replace(/\D/g, "") },
      },
    });

    if (!res.data) throw new Error("Unit application creation failed");

    const app = res.data as any;
    const customerId =
      app.relationships?.customer?.data?.id ?? null;

    return {
      unitCustomerId: customerId ?? app.id,
      unitApplicationId: app.id,
      unitApplicationStatus: app.attributes?.status ?? "pending",
    };
  }

  async getCustomer(unitCustomerId: string) {
    const client = getUnitClient();
    const res = await client.customers.get(unitCustomerId);
    return res.data;
  }

  // ── Accounts ─────────────────────────────────────────────────────────────────

  async createDepositAccount(
    input: CreateUnitAccountInput
  ): Promise<UnitAccountResult> {
    const client = getUnitClient();

    const res = await client.accounts.create({
      type: "depositAccount",
      attributes: {
        depositProduct: input.depositProduct ?? "checking",
      },
      relationships: {
        customer: {
          data: { type: "customer", id: input.unitCustomerId },
        },
      },
    });

    if (!res.data) throw new Error("Unit account creation failed");
    const acc = res.data as any;

    return {
      unitAccountId: acc.id,
      routingNumber: acc.attributes?.routingNumber ?? "",
      accountNumber: acc.attributes?.accountNumber ?? "",
      balance: acc.attributes?.balance ?? 0,
      status: acc.attributes?.status ?? "open",
    };
  }

  async getAccount(unitAccountId: string): Promise<UnitAccountResult> {
    const client = getUnitClient();
    const res = await client.accounts.get(unitAccountId);
    const acc = res.data as any;
    return {
      unitAccountId: acc.id,
      routingNumber: acc.attributes?.routingNumber ?? "",
      accountNumber: acc.attributes?.accountNumber ?? "",
      balance: acc.attributes?.balance ?? 0,
      status: acc.attributes?.status ?? "",
    };
  }

  async listAccountsByCustomer(unitCustomerId: string) {
    const client = getUnitClient();
    const res = await client.accounts.list({
      customerId: unitCustomerId,
    });
    return res.data;
  }

  // ── Cards ─────────────────────────────────────────────────────────────────────

  async issueDebitCard(input: CreateUnitCardInput): Promise<UnitCardResult> {
    const client = getUnitClient();

    const cardData: any = {
      type: "individualDebitCard",
      attributes: {},
      relationships: {
        account: {
          data: { type: "depositAccount", id: input.unitAccountId },
        },
      },
    };

    if (input.shippingAddress) {
      cardData.type = "individualPhysicalCard";
      cardData.attributes.shippingAddress = input.shippingAddress;
    }

    const res = await client.cards.create(cardData);
    if (!res.data) throw new Error("Unit card creation failed");
    const card = res.data as any;

    return {
      unitCardId: card.id,
      last4: card.attributes?.last4Digits ?? "",
      status: card.attributes?.status ?? "",
      type: card.type,
    };
  }

  async getCard(unitCardId: string): Promise<UnitCardResult> {
    const client = getUnitClient();
    const res = await client.cards.get(unitCardId);
    const card = res.data as any;
    return {
      unitCardId: card.id,
      last4: card.attributes?.last4Digits ?? "",
      status: card.attributes?.status ?? "",
      type: card.type,
    };
  }

  async freezeCard(unitCardId: string) {
    const client = getUnitClient();
    return client.cards.freeze(unitCardId);
  }

  async unfreezeCard(unitCardId: string) {
    const client = getUnitClient();
    return client.cards.unfreeze(unitCardId);
  }

  // ── Transfers / Payments ──────────────────────────────────────────────────────

  async createTransfer(
    input: CreateUnitTransferInput
  ): Promise<UnitTransferResult> {
    const client = getUnitClient();

    let res: any;

    if (input.type === "BOOK") {
      res = await client.payments.create({
        type: "bookPayment",
        attributes: {
          amount: input.amount,
          description: input.description ?? "Transfer",
          direction: input.direction ?? "Debit",
        },
        relationships: {
          account: {
            data: { type: "depositAccount", id: input.fromUnitAccountId },
          },
          counterpartyAccount: {
            data: {
              type: "depositAccount",
              id: input.toUnitAccountId!,
            },
          },
        },
      });
    } else if (input.type === "ACH") {
      res = await client.payments.create({
        type: "achPayment",
        attributes: {
          amount: input.amount,
          description: input.description ?? "ACH Transfer",
          direction: input.direction ?? "Debit",
          addenda: input.description,
        },
        relationships: {
          account: {
            data: { type: "depositAccount", id: input.fromUnitAccountId },
          },
          counterparty: {
            data: {
              type: "counterparty",
              id: input.toUnitAccountId!,
            },
          },
        },
      });
    } else {
      // WIRE — WireCounterparty requires { routingNumber, accountNumber, name, address }
      res = await client.payments.create({
        type: "wirePayment",
        attributes: {
          amount: input.amount,
          description: input.description ?? "Wire Transfer",
          counterparty: {
            routingNumber: input.toRoutingNumber!,
            accountNumber: input.toAccountNumber!,
            name: input.counterpartyName ?? "",
            address: input.counterpartyAddress ?? {
              street: "",
              city: "",
              state: "",
              postalCode: "",
              country: "US",
            },
          } as any,
        },
        relationships: {
          account: {
            data: { type: "depositAccount", id: input.fromUnitAccountId },
          },
        },
      });
    }

    if (!res.data) throw new Error("Unit transfer creation failed");
    const pmt = res.data as any;

    return {
      unitTransferId: pmt.id,
      status: pmt.attributes?.status ?? "pending",
      amount: pmt.attributes?.amount ?? input.amount,
      createdAt: pmt.attributes?.createdAt ?? new Date().toISOString(),
    };
  }

  async getTransfer(unitTransferId: string) {
    const client = getUnitClient();
    const res = await client.payments.get(unitTransferId);
    return res.data;
  }

  async listTransactionsByAccount(unitAccountId: string, limit = 20) {
    const client = getUnitClient();
    const res = await client.transactions.list({
      accountId: unitAccountId,
      pageLimit: limit,
    });
    return res.data;
  }
}

export const unitService = new UnitService();
