import { UnitCustomerResult, UnitAccountResult, UnitCardResult, UnitTransferResult } from "./unit.types";

export function mapCustomerToProfile(result: UnitCustomerResult) {
  return {
    unitCustomerId: result.unitCustomerId,
    unitApplicationId: result.unitApplicationId,
    unitApplicationStatus: result.unitApplicationStatus,
  };
}

export function mapUnitAccountToResponse(result: UnitAccountResult) {
  return {
    unitAccountId: result.unitAccountId,
    routingNumber: result.routingNumber,
    accountNumber: result.accountNumber,
    balance: (result.balance / 100).toFixed(2), // Unit stores cents
    status: result.status,
  };
}

export function mapUnitCardToResponse(result: UnitCardResult) {
  return {
    unitCardId: result.unitCardId,
    last4: result.last4,
    status: result.status,
    type: result.type === "individualDebitCard" ? "VIRTUAL" : "PHYSICAL",
  };
}

export function mapUnitTransferToResponse(result: UnitTransferResult) {
  return {
    unitTransferId: result.unitTransferId,
    status: result.status,
    amount: (result.amount / 100).toFixed(2),
    createdAt: result.createdAt,
  };
}
