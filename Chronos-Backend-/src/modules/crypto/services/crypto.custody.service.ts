import prisma from "../../../models/prisma";
import MoralisClient from "../integrations/moralis.client";

export class CryptoCustodyService {
  async ensureWallet(userId: string, preferred?: { type?: "CUSTODIAL" | "NONCUSTODIAL" }) {
    // Prefer custodial by default
    const existing = await prisma.cryptoWallet.findFirst({ where: { userId, type: preferred?.type ?? "CUSTODIAL" } });
    if (existing) return existing;

    // Create new custodial wallet via Moralis (or your wallet service)
    const address = await MoralisClient.createCustodialWallet(userId);
    return prisma.cryptoWallet.create({
      data: {
        userId,
        type: "CUSTODIAL",
        address,
        provider: "Moralis",
      },
    });
  }

  async creditAsset(walletId: string, currency: string, amount: number, txHash?: string) {
    // Record in DB; if custodial, update internal ledger; if non-custodial, skip balance but store activity
    await prisma.cryptoTransaction.create({
      data: {
        walletId,
        type: "DEPOSIT",
        amount,
        currency,
        txHash: txHash || null,
        status: "COMPLETED",
      },
    });
  }

  async debitAsset(walletId: string, currency: string, amount: number) {
    // Optional: maintain internal balances table for custodial wallets
    // For simplicity, just log a withdrawal tx (real systems: check and update ledger)
    await prisma.cryptoTransaction.create({
      data: {
        walletId,
        type: "WITHDRAW",
        amount,
        currency,
        status: "PENDING",
      },
    });
  }
}

export default new CryptoCustodyService();
