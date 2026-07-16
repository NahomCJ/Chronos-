// src/services/tickpay.accounting.service.ts
import prisma from "../models/prisma";

/**
 * Creates a simple ledger entry when balances change.
 */
class AccountingService {
  async createLedgerEntry(accountId: string, type: "PRINCIPAL" | "FEE" | "ADJUST", amount: string, meta: any = {}) {
    // You may want a dedicated model; for now we use prisma.transferTransaction as placeholder or create a new model later.
    // We'll create a minimal table later in Prisma schema. For now write to audit as placeholder.
    await prisma.tickPayAudit.create({
      data: {
        accountId,
        actorId: null,
        action: `LEDGER_${type}`,
        payload: { amount, meta },
      },
    });
  }
}

export default new AccountingService();
