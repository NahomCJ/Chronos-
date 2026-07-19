export interface CreateUnitCustomerInput {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  ssn: string;
  dateOfBirth: string; // YYYY-MM-DD
  address: {
    street: string;
    city: string;
    state: string;
    postalCode: string;
    country: string;
  };
}

export interface UnitCustomerResult {
  unitCustomerId: string;
  unitApplicationId: string;
  unitApplicationStatus: string;
}

export interface CreateUnitAccountInput {
  unitCustomerId: string;
  depositProduct?: string;
}

export interface UnitAccountResult {
  unitAccountId: string;
  routingNumber: string;
  accountNumber: string;
  balance: number;
  status: string;
}

export interface CreateUnitCardInput {
  unitAccountId: string;
  shippingAddress?: {
    street: string;
    city: string;
    state: string;
    postalCode: string;
    country: string;
  };
}

export interface UnitCardResult {
  unitCardId: string;
  last4: string;
  status: string;
  type: string;
}

export interface CreateUnitTransferInput {
  fromUnitAccountId: string;
  toUnitAccountId?: string;
  toRoutingNumber?: string;
  toAccountNumber?: string;
  amount: number; // in cents
  description?: string;
  type: "ACH" | "WIRE" | "BOOK";
  direction?: "Debit" | "Credit";
  counterpartyName?: string;
  counterpartyAddress?: {
    street: string;
    city: string;
    state: string;
    postalCode: string;
    country: string;
  };
}

export interface UnitTransferResult {
  unitTransferId: string;
  status: string;
  amount: number;
  createdAt: string;
}

export interface UnitWebhookEvent {
  type: string;
  attributes: Record<string, any>;
  relationships?: Record<string, any>;
}
