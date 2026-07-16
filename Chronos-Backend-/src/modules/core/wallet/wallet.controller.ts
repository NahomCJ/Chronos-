// src/modules/core/wallet/wallet.controller.ts

import { Request, Response } from "express";
import { walletService } from "./wallet.service";

class WalletController {
  // =====================================
  // Create Wallet
  // =====================================
  async create(req: Request, res: Response) {
    try {
      const userId = req.user.id;
      const { accountId, currency, type } = req.body;

      if (!accountId || !currency || !type) {
        return res.status(400).json({
          message: "accountId, currency and type are required",
        });
      }

      const wallet = await walletService.createWallet(
        { accountId, currency, type },
        userId
      );

      return res.status(201).json(wallet);
    } catch (err: any) {
      return res.status(400).json({
        message: err.message || "Failed to create wallet",
      });
    }
  }

  // =====================================
  // List Wallets by Account
  // =====================================
  async listByAccount(req: Request, res: Response) {
    try {
      const userId = req.user.id;
      const { accountId } = req.params;

      if (!accountId) {
        return res.status(400).json({
          message: "accountId is required",
        });
      }

      const wallets = await walletService.getWallets(accountId, userId);

      return res.status(200).json(wallets);
    } catch (err: any) {
      return res.status(400).json({
        message: err.message || "Failed to fetch wallets",
      });
    }
  }

  // =====================================
  // Get Single Wallet
  // =====================================
  async getById(req: Request, res: Response) {
    try {
      const userId = req.user.id;
      const { walletId } = req.params;

      if (!walletId) {
        return res.status(400).json({
          message: "walletId is required",
        });
      }

      const wallet = await walletService.getWalletById(walletId, userId);

      return res.status(200).json(wallet);
    } catch (err: any) {
      return res.status(400).json({
        message: err.message || "Failed to fetch wallet",
      });
    }
  }

  // =====================================
  // Freeze Wallet
  // =====================================
  async freeze(req: Request, res: Response) {
    try {
      const userId = req.user.id;
      const { walletId } = req.params;

      const wallet = await walletService.freezeWallet(walletId, userId);

      return res.status(200).json(wallet);
    } catch (err: any) {
      return res.status(400).json({
        message: err.message || "Failed to freeze wallet",
      });
    }
  }

  // =====================================
  // Close Wallet
  // =====================================
  async close(req: Request, res: Response) {
    try {
      const userId = req.user.id;
      const { walletId } = req.params;

      const wallet = await walletService.closeWallet(walletId, userId);

      return res.status(200).json(wallet);
    } catch (err: any) {
      return res.status(400).json({
        message: err.message || "Failed to close wallet",
      });
    }
  }
}

export const walletController = new WalletController();