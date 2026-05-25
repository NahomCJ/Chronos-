// src/modules/core/onboarding/bank-deposit.service.ts
//
// ACH Bank → Chronos Deposit Flow (Plaid Transfer API)
//
// Overview:
//   Users link their bank via Plaid (POST /kyc/bank/connect).
//   They can then initiate an ACH pull: money moves from their
//   external bank account → Chronos-held account → credits their Wallet.
//
// Flow per deposit:
//   1. Validate user has KYC approved + bank linked (plaidAccessToken exists)
//   2. Create a Plaid Transfer Authorization (risk check)
//   3. Create a Plaid Transfer (ACH DEBIT — pull from user's bank)
//   4. Record CoreTransaction (status: PENDING) + BankDeposit record in DB
//   5. Plaid fires TRANSFER webhook when ACH settles (1-3 business days)
//      → webhook handler credits the user's USD wallet (see handleTransferWebhook)
//
// Sandbox:
//   - Set PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV=sandbox in .env
//   - Use Plaid sandbox to simulate settlement:
//       POST https://sandbox.plaid.com/sandbox/transfer/simulate
//       { "transfer_id": "...", "event_type": "settled" }
//   - Or use Plaid Dashboard → Sandbox → Simulate Transfer Event
//
// Production:
//   - Swap in real PLAID_CLIENT_ID + PLAID_SECRET (same code, different keys)
//   - Enable webhook signature verification: PLAID_VERIFY_WEBHOOKS=true
//   - ACH settles in 1-3 business days

import { PrismaClient, Prisma } from "@prisma/client";
import { plaidClient } from "../../../config/plaid";
import { v4 as uuidv4 } from "uuid";

const prisma = new PrismaClient();

const MIN_DEPOSIT_USD = Number(process.env.DEPOSIT_MIN_AMOUNT ?? 1);
const MAX_DEPOSIT_USD = Number(process.env.DEPOSIT_MAX_AMOUNT ?? 25000);

export interface InitiateBankDepositInput {
  amount: number;     // USD amount (e.g. 500.00)
  description?: string;
}

export interface BankDepositResult {
  depositId: string;         // our internal CoreTransaction id
  plaidTransferId: string;   // Plaid transfer id for tracking
  amount: number;
  currency: string;
  status: "PENDING";
  estimatedSettlement: string;
  message: string;
}

export class BankDepositService {

  // ─── Initiate ACH deposit ─────────────────────────────────────────────────

  async initiate(userId: string, input: InitiateBankDepositInput): Promise<BankDepositResult> {
    const { amount, description } = input;

    // ── Guard: amount limits ────────────────────────────────────────────────
    if (amount < MIN_DEPOSIT_USD) {
      throw new Error(`Minimum deposit amount is $${MIN_DEPOSIT_USD}.`);
    }
    if (amount > MAX_DEPOSIT_USD) {
      throw new Error(`Maximum single deposit is $${MAX_DEPOSIT_USD}. Contact support for larger transfers.`);
    }

    // ── Guard: KYC + bank link ──────────────────────────────────────────────
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) {
      throw new Error("Banking profile not found. Complete onboarding first.");
    }
    if (!profile.kycVerified) {
      throw new Error("Identity verification (KYC) must be approved before depositing.");
    }
    if (!profile.plaidAccessToken || !profile.plaidAccountId) {
      throw new Error(
        "No bank account linked. Call POST /onboarding/link-bank and then POST /kyc/bank/connect first."
      );
    }

    // ── Guard: user has an active USD wallet ────────────────────────────────
    const wallet = await this.findOrErrorUsdWallet(userId);

    // ── Idempotency key ─────────────────────────────────────────────────────
    const idempotencyKey = uuidv4();

    // ── Step 1: Plaid Transfer Authorization ────────────────────────────────
    // Plaid checks if the transfer is likely to succeed (NSF risk, account validity).
    let authorizationId: string;
    try {
      const authResponse = await plaidClient.transferAuthorizationCreate({
        access_token: profile.plaidAccessToken,
        account_id: profile.plaidAccountId,
        type: "debit" as any,           // pull from user's bank
        network: "ach" as any,
        amount: amount.toFixed(2),
        ach_class: "ppd" as any,        // personal — standard ACH
        user: {
          legal_name: `${(await prisma.user.findUnique({ where: { id: userId } }))?.firstName ?? ""} ${(await prisma.user.findUnique({ where: { id: userId } }))?.lastName ?? ""}`.trim(),
        },
      });

      const decision = authResponse.data.authorization.decision;
      if (decision !== "approved") {
        throw new Error(
          `Bank transfer authorization declined (${decision}). ` +
          "This may be due to insufficient funds or account restrictions. Please try a smaller amount."
        );
      }
      authorizationId = authResponse.data.authorization.id;
    } catch (err: any) {
      if (err.message.includes("declined")) throw err;
      throw new Error(`Plaid authorization failed: ${err?.response?.data?.error_message ?? err.message}`);
    }

    // ── Step 2: Create Plaid Transfer (ACH pull) ────────────────────────────
    let plaidTransferId: string;
    try {
      const transferResponse = await plaidClient.transferCreate({
        idempotency_key: idempotencyKey,
        access_token: profile.plaidAccessToken,
        account_id: profile.plaidAccountId,
        authorization_id: authorizationId,
        type: "debit" as any,
        network: "ach" as any,
        amount: amount.toFixed(2),
        description: description ?? "Chronos deposit",
        ach_class: "ppd" as any,
        user: {
          legal_name: `${(await prisma.user.findUnique({ where: { id: userId } }))?.firstName ?? ""} ${(await prisma.user.findUnique({ where: { id: userId } }))?.lastName ?? ""}`.trim(),
        },
      });
      plaidTransferId = transferResponse.data.transfer.id;
    } catch (err: any) {
      throw new Error(`Failed to initiate bank transfer: ${err?.response?.data?.error_message ?? err.message}`);
    }

    // ── Step 3: Record in DB (PENDING — wallet credited on settlement webhook) ──
    const depositId = uuidv4();

    await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      await tx.coreTransaction.create({
        data: {
          id: depositId,
          userId,
          type: "DEPOSIT",
          status: "PENDING",
          reference: plaidTransferId,
          metadata: {
            source: "PLAID_ACH",
            walletId: wallet.id,
            amount: amount.toFixed(2),
            currency: "USD",
            plaidTransferId,
            plaidAuthorizationId: authorizationId,
            description: description ?? "Bank deposit",
          },
        },
      });
    });

    // Estimate settlement date (+3 business days)
    const estimatedSettlement = this.addBusinessDays(new Date(), 3).toISOString().split("T")[0];

    return {
      depositId,
      plaidTransferId,
      amount,
      currency: "USD",
      status: "PENDING",
      estimatedSettlement,
      message:
        "ACH transfer initiated. Funds will be credited to your wallet within 1-3 business days " +
        "once the transfer settles. In sandbox mode you can simulate settlement immediately.",
    };
  }

  // ─── Plaid TRANSFER webhook handler ──────────────────────────────────────
  //
  // Called by kyc.controller handleWebhook when webhook_type === "TRANSFER"
  // Plaid fires these events as the ACH moves through the network:
  //   pending → posted → settled  (success path)
  //   pending → failed/returned   (failure path)

  async handleTransferWebhook(body: {
    webhook_type: string;
    webhook_code: string;
    transfer_id: string;
    transfer_event_type?: string;
  }): Promise<void> {
    const { transfer_id, transfer_event_type } = body;
    if (!transfer_id) return;

    // Find the pending deposit by Plaid transfer ID
    const coreTx = await prisma.coreTransaction.findFirst({
      where: { reference: transfer_id, type: "DEPOSIT" },
    });
    if (!coreTx) return; // not our transfer

    const meta = coreTx.metadata as any;
    const eventType = transfer_event_type ?? body.webhook_code;

    if (eventType === "settled") {
      // ── Credit user's USD wallet ──────────────────────────────────────────
      await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
        // Mark transaction as COMPLETED
        await tx.coreTransaction.update({
          where: { id: coreTx.id },
          data: { status: "COMPLETED" },
        });

        // Credit ledger entry
        await tx.ledgerEntry.create({
          data: {
            transactionId: coreTx.id,
            walletId: meta.walletId,
            direction: "CREDIT",
            category: "ADJUSTMENT",
            amount: new Prisma.Decimal(meta.amount),
            currency: meta.currency ?? "USD",
            reference: transfer_id,
          },
        });
      });

      console.log(
        `[BankDeposit] ACH settled — $${meta.amount} credited to wallet ${meta.walletId} (user ${coreTx.userId})`
      );

    } else if (eventType === "failed" || eventType === "returned") {
      await prisma.coreTransaction.update({
        where: { id: coreTx.id },
        data: { status: "FAILED" },
      });
      console.warn(
        `[BankDeposit] ACH ${eventType} — transfer ${transfer_id} for user ${coreTx.userId}`
      );
    }
  }

  // ─── Deposit history ──────────────────────────────────────────────────────

  async listDeposits(userId: string, page = 1, limit = 20) {
    const deposits = await prisma.coreTransaction.findMany({
      where: { userId, type: "DEPOSIT" },
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * limit,
      take: limit,
    });

    return deposits.map((d) => {
      const meta = d.metadata as any;
      return {
        id: d.id,
        amount: meta?.amount ?? null,
        currency: meta?.currency ?? "USD",
        source: meta?.source ?? "BANK",
        plaidTransferId: meta?.plaidTransferId ?? null,
        status: d.status,
        createdAt: d.createdAt,
      };
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  private async findOrErrorUsdWallet(userId: string) {
    // Find user's primary USD FIAT wallet via account → wallet chain
    const account = await prisma.account.findFirst({
      where: { userId, status: "APPROVED" },
      include: { wallets: { where: { currency: "USD", status: "ACTIVE" } } },
    });
    const wallet = account?.wallets?.[0];
    if (!wallet) {
      throw new Error(
        "No active USD wallet found. Your account may still be pending approval."
      );
    }
    return wallet;
  }

  private addBusinessDays(date: Date, days: number): Date {
    let count = 0;
    const result = new Date(date);
    while (count < days) {
      result.setDate(result.getDate() + 1);
      const day = result.getDay();
      if (day !== 0 && day !== 6) count++; // skip Sat/Sun
    }
    return result;
  }
}

export const bankDepositService = new BankDepositService();
