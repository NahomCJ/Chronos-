// src/services/tickpay.service.ts
import prisma from "../models/prisma";
import OnboardingService from "./tickpay.onboard.service";
import ScoringService from "./tickpay.scoring.service";
import BillingService from "./tickpay.billing.service";
import NotificationService from "./tickpay.notification.service";
import AccountingService from "./tickpay.accounting.services";
import { toDecimalString } from "../../../utils/money";
import { auditLog } from "../utils/audit";

const FEE_RATE = parseFloat(process.env.TICKPAY_FEE_RATE || "0.005");

class TickPayService {

  /**
   * Create TickPay account after onboarding approval
   */
  async createAccount(userId: string) {
    const existing = await prisma.tickPayAccount.findUnique({ where: { userId } });
    if (existing) return existing;

    // 🔥 Fetch onboarding data
    const onboarding = await (OnboardingService as any).getStatus(userId);

    if (!onboarding) {
      throw new Error("User onboarding not found");
    }

    if (onboarding.status !== "APPROVED") {
      throw new Error("User is not approved by onboarding");
    }

    // creditLimit MUST come from onboarding
    const acct = await prisma.tickPayAccount.create({
      data: {
        userId,
        creditLimit: onboarding.creditLimit.toString(),
        balance: "0",
        status: "ACTIVE"
      },
    });

    await auditLog({
      actorId: null,
      accountId: acct.id,
      action: "CREATE_ACCOUNT",
      metadata: { userId, creditLimit: onboarding.creditLimit, score: onboarding.score }
    });

    return acct;
  }

  async getAccount(userId: string) {
  return prisma.tickPayAccount.findUnique({
    where: { userId },
    include: {
      transactions: {
        orderBy: { createdAt: "desc" }
      },
      feeInstallments: {
        orderBy: { dueDate: "asc" }
      },
      card: true
    },
  });
}


  /**
   * Issue virtual TickPay card
   */
  async issueTickPayCard(userId: string) {
    const acct = await prisma.tickPayAccount.findUnique({ where: { userId } });
    if (!acct) throw new Error("Account not found");

    const cardId = `tck_${Math.random().toString(36).slice(2, 10)}`;

    const card = await prisma.tickPayCard.create({
      data: {
        cardId,
        tickPayAccountId: acct.id,
      },
    });

    await auditLog({
      actorId: null,
      accountId: acct.id,
      action: "ISSUE_CARD",
      metadata: { cardId },
    });

    await NotificationService.notify(userId, "CARD_ISSUED", { cardId });

    return card;
  }

  /**
   * Create a purchase transaction
   */
 async createPurchase(
  userId: string,
  opts: { amount: number; currency?: string; merchant?: string; meta?: any }
) {
  const { amount, currency = "USD", merchant, meta } = opts;

  if (amount <= 0) throw new Error("Amount must be > 0");

  // Ensure account exists
  let acct = await prisma.tickPayAccount.findUnique({ where: { userId } });
  if (!acct) acct = await this.createAccount(userId);

  if (acct.status !== "ACTIVE") throw new Error("TickPay account not active");

  // Credit check
  const creditLimit = parseFloat(String(acct.creditLimit));
  const balance = parseFloat(String(acct.balance));
  const available = creditLimit - balance;
  if (amount > available) throw new Error("Insufficient TickPay credit");

  // Scoring
  const decision = await ScoringService.approvePurchase(userId, amount);
  if (!decision.approved) throw new Error(`Purchase denied: ${decision.reason}`);

  const totalFee = parseFloat((amount * FEE_RATE).toFixed(2));

  // Run everything in a transaction
  return await prisma.$transaction(async (tx) => {
    // Create purchase transaction
    const purchaseTx = await tx.tickPayTransaction.create({
      data: {
        tickPayAccountId: acct!.id,
        type: "PURCHASE",
        status: "COMPLETED",
        amount: toDecimalString(amount),
        currency,
        merchant,
        meta: { ...meta, fee: toDecimalString(totalFee) },
      },
    });

    // Update account balance
    const newBalance = (balance + amount).toFixed(8);
    await tx.tickPayAccount.update({
      where: { id: acct!.id },
      data: { balance: newBalance },
    });

    // Schedule fee installments using the same transaction
    const billing = await BillingService.scheduleFeeInstallments(
      tx,
      acct!.id,
      purchaseTx.id,
      amount
    );

    // Accounting entry
    
    await AccountingService.createLedgerEntry(
      acct!.id,
      "PRINCIPAL",
      toDecimalString(amount),
      { tx: purchaseTx.id }
    );

    // Audit log
    await auditLog({
      actorId: null,
      accountId: acct!.id,
      action: "PURCHASE_CREATED",
      metadata: { purchaseTxId: purchaseTx.id, amount },
    });

    // Notify user
    await NotificationService.notify(userId, "PURCHASE_CONFIRMED", {
      purchaseTx,
      billing,
    });

    return {
      purchaseTx,
      totalFee: toDecimalString(totalFee),
      perInstallment: billing.perInstallment,
      installments: billing.installments,
    };
  });
}



  /**
   * Repayment logic
   */
  async createRepayment(
    userId: string,
    opts: { amount: number; currency?: string; source?: string; meta?: any }
  ) {
    const { amount, currency = "USD", source, meta } = opts;

    if (amount <= 0) throw new Error("Amount must be > 0");

    const acct = await prisma.tickPayAccount.findUnique({ where: { userId } });
    if (!acct) throw new Error("Account not found");

    return prisma.$transaction(async (tx) => {
      const dueFees = await tx.tickPayFeeInstallment.findMany({
        where: { tickPayAccountId: acct.id, status: { in: ["SCHEDULED", "DUE"] } },
        orderBy: { dueDate: "asc" },
      });

      let remaining = amount;

      // Priority pay fee installments
      for (const fee of dueFees) {
        const feeAmt = parseFloat(String(fee.amount));

        if (remaining >= feeAmt) {
          await tx.tickPayFeeInstallment.update({
            where: { id: fee.id },
            data: { status: "PAID", paidAt: new Date() },
          });

          remaining = +(remaining - feeAmt).toFixed(2);

        } else break;
      }

      // Apply rest to principal
      let appliedToPrincipal = 0;

      if (remaining > 0) {
        const currentBalance = parseFloat(String(acct.balance));
        const reduce = Math.min(currentBalance, remaining);
        const newBalance = (currentBalance - reduce).toFixed(8);

        await tx.tickPayAccount.update({
          where: { id: acct.id },
          data: { balance: newBalance },
        });

        appliedToPrincipal = reduce;
        remaining = +(remaining - reduce).toFixed(2);
      }

      const repaymentTx = await tx.tickPayTransaction.create({
        data: {
          tickPayAccountId: acct.id,
          type: "REPAYMENT",
          status: "COMPLETED",
          amount: toDecimalString(amount),
          currency,
          meta: {
            source,
            appliedToPrincipal,
            leftover: remaining,
            ...meta,
          },
        },
      });

      await AccountingService.createLedgerEntry(
        acct.id,
        "PRINCIPAL",
        toDecimalString(appliedToPrincipal),
        { repaymentTx: repaymentTx.id }
      );

      await auditLog({
        actorId: null,
        accountId: acct.id,
        action: "REPAYMENT",
        metadata: { repaymentTxId: repaymentTx.id, amount },
      });

      await NotificationService.notify(userId, "REPAYMENT_RECEIVED", {
        repaymentTx,
        appliedToPrincipal,
      });

      return {
        repaymentTx,
        appliedAmount: amount - remaining,
        leftover: remaining,
      };
    });
  }

  /**
   * Refund purchase
   */
  async refundPurchase(userId: string, purchaseTxId: string, amount: number) {
    const acct = await prisma.tickPayAccount.findUnique({ where: { userId } });
    if (!acct) throw new Error("Account not found");

    return prisma.$transaction(async (tx) => {
      const txPurchase = await tx.tickPayTransaction.findUnique({
        where: { id: purchaseTxId },
      });

      if (!txPurchase) {
        throw new Error("Purchase transaction not found");
      }

      const currentBalance = parseFloat(String(acct.balance));
      const reduce = Math.min(currentBalance, amount);
      const newBalance = (currentBalance - reduce).toFixed(8);

      await tx.tickPayAccount.update({
        where: { id: acct.id },
        data: { balance: newBalance },
      });

      const refundTx = await tx.tickPayTransaction.create({
        data: {
          tickPayAccountId: acct.id,
          type: "REFUND",
          status: "COMPLETED",
          amount: toDecimalString(reduce),
          currency: txPurchase.currency,
          meta: { originalPurchase: purchaseTxId },
        },
      });

      await AccountingService.createLedgerEntry(
        acct.id,
        "ADJUST",
        toDecimalString(reduce),
        { refundTx: refundTx.id }
      );

      await auditLog({
        actorId: null,
        accountId: acct.id,
        action: "REFUND",
        metadata: {
          refundTxId: refundTx.id,
          original: purchaseTxId,
        },
      });

      await NotificationService.notify(userId, "REFUND_PROCESSED", {
        refundTx,
      });

      return refundTx;
    });
  }

 // src/services/tickpay.service.ts
async listTransactions(userId: string, limit = 50) {
  const acct = await prisma.tickPayAccount.findUnique({ where: { userId } });
  if (!acct) throw new Error("Account not found");

  return prisma.tickPayTransaction.findMany({
    where: { tickPayAccountId: acct.id },
    orderBy: { createdAt: "desc" },
    take: limit,
  });
}

async listFees(userId: string) {
  const acct = await prisma.tickPayAccount.findUnique({ where: { userId } });
  if (!acct) throw new Error("Account not found");

  return prisma.tickPayFeeInstallment.findMany({
    where: { tickPayAccountId: acct.id },
    orderBy: { dueDate: "asc" },
  });
}


  async suspendAccount(userId: string) {
    const acct = await prisma.tickPayAccount.update({
      where: { userId },
      data: { status: "SUSPENDED" },
    });

    await auditLog({ actorId: null, accountId: acct.id, action: "SUSPEND" });

    await NotificationService.notify(userId, "ACCOUNT_SUSPENDED", {
      account: acct,
    });

    return acct;
  }

  async resumeAccount(userId: string) {
    const acct = await prisma.tickPayAccount.update({
      where: { userId },
      data: { status: "ACTIVE" },
    });

    await auditLog({ actorId: null, accountId: acct.id, action: "RESUME" });

    await NotificationService.notify(userId, "ACCOUNT_RESUMED", {
      account: acct,
    });

    return acct;
  }
}

export default new TickPayService();
