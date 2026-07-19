// src/modules/core/wallet/wallet.service.ts

import { PrismaClient, WalletStatus, WalletType } from "@prisma/client";
import { CreateWalletInput, WalletDTO } from "./wallet.types";

const prisma = new PrismaClient();

class WalletService {
  // ===============================
  // Create Wallet
  // ===============================
  async createWallet(
    input: CreateWalletInput,
    userId: string
  ): Promise<WalletDTO> {
    if (!userId) {
      throw new Error("Unauthorized");
    }

    // Verify account ownership
    const account = await prisma.account.findUnique({
      where: { id: input.accountId },
    });

    if (!account || account.userId !== userId) {
      throw new Error("Account not found or unauthorized");
    }

    // Prevent duplicate wallet (accountId + currency + type is unique)
    const existingWallet = await prisma.wallet.findFirst({
      where: {
        accountId: input.accountId,
        currency: input.currency,
        type: input.type as WalletType,
      },
    });

    if (existingWallet) {
      throw new Error("Wallet already exists for this currency and type");
    }

    const wallet = await prisma.wallet.create({
      data: {
        accountId: input.accountId,
        currency: input.currency,
        type: input.type as WalletType,
        status: WalletStatus.ACTIVE,
      },
    });

    return this.mapWallet(wallet);
  }

  // ===============================
  // Get Wallets by Account
  // ===============================
  async getWallets(
    accountId: string,
    userId: string
  ): Promise<WalletDTO[]> {
    if (!userId) {
      throw new Error("Unauthorized");
    }

    const account = await prisma.account.findUnique({
      where: { id: accountId },
    });

    if (!account || account.userId !== userId) {
      throw new Error("Account not found or unauthorized");
    }

    const wallets = await prisma.wallet.findMany({
      where: { accountId },
      orderBy: { createdAt: "desc" },
    });

    return wallets.map((wallet) => this.mapWallet(wallet));
  }

  // ===============================
  // Get Single Wallet by ID
  // ===============================
  async getWalletById(
    walletId: string,
    userId: string
  ): Promise<WalletDTO> {
    if (!userId) {
      throw new Error("Unauthorized");
    }

    const wallet = await prisma.wallet.findUnique({
      where: { id: walletId },
      include: { account: true },
    });

    if (!wallet || wallet.account.userId !== userId) {
      throw new Error("Wallet not found or unauthorized");
    }

    return this.mapWallet(wallet);
  }

  // ===============================
  // Freeze Wallet
  // ===============================
  async freezeWallet(walletId: string, userId: string): Promise<WalletDTO> {
    const wallet = await prisma.wallet.findUnique({
      where: { id: walletId },
      include: { account: true },
    });

    if (!wallet || wallet.account.userId !== userId) {
      throw new Error("Wallet not found or unauthorized");
    }

    const updated = await prisma.wallet.update({
      where: { id: walletId },
      data: { status: WalletStatus.FROZEN },
    });

    return this.mapWallet(updated);
  }

  // ===============================
  // Close Wallet
  // ===============================
  async closeWallet(walletId: string, userId: string): Promise<WalletDTO> {
    const wallet = await prisma.wallet.findUnique({
      where: { id: walletId },
      include: { account: true },
    });

    if (!wallet || wallet.account.userId !== userId) {
      throw new Error("Wallet not found or unauthorized");
    }

    const updated = await prisma.wallet.update({
      where: { id: walletId },
      data: { status: WalletStatus.INACTIVE },
    });

    return this.mapWallet(updated);
  }

  // ===============================
  // Private Mapper
  // ===============================
  private mapWallet(wallet: any): WalletDTO {
    return {
      id: wallet.id,
      accountId: wallet.accountId,
      currency: wallet.currency,
      type: wallet.type,
      status: wallet.status,
      createdAt: wallet.createdAt.toISOString(),
      updatedAt: wallet.updatedAt.toISOString(),
    };
  }
}

export const walletService = new WalletService();