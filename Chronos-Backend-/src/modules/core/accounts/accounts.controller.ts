// src/core/accounts/accounts.controller.ts

import { Request, Response } from "express";
import * as accountService from "./accounts.service";
import { CreateAccountDTO, UpdateAccountDTO } from "./accounts.type";

/**
 * Helper to safely extract userId
 */
const getUserId = (req: Request): string => {
  if (!req.user?.id) {
    throw new Error("Unauthorized");
  }
  return req.user.id;
};

/**
 * Create a new account
 */
export const createAccount = async (req: Request, res: Response) => {
  try {
    const userId = getUserId(req);
    const data: CreateAccountDTO = req.body;

    const result = await accountService.createAccount(userId, data);
    res.status(result.status).json(result.data);
  } catch (error: any) {
    res.status(500).json({
      message: error.message || "Failed to create account",
    });
  }
};

/**
 * Fetch all accounts (for logged-in user only)
 */
export const getAllAccounts = async (req: Request, res: Response) => {
  try {
    const userId = getUserId(req);

    const result = await accountService.getAllAccounts(userId);
    res.status(result.status).json(result.data);
  } catch (error: any) {
    res.status(500).json({
      message: error.message || "Failed to fetch accounts",
    });
  }
};

/**
 * Get account by ID
 */
export const getAccountById = async (req: Request, res: Response) => {
  try {
    const userId = getUserId(req);
    const accountId = req.params.id;

    const result = await accountService.getAccountById(userId, accountId);
    res.status(result.status).json(result.data);
  } catch (error: any) {
    res.status(500).json({
      message: error.message || "Failed to fetch account",
    });
  }
};

/**
 * Freeze account
 */
export const freezeAccount = async (req: Request, res: Response) => {
  try {
    const userId = getUserId(req);
    const accountId = req.params.id;

    const result = await accountService.freezeAccount(userId, accountId);
    res.status(result.status).json(result.data);
  } catch (error: any) {
    res.status(500).json({
      message: error.message || "Failed to freeze account",
    });
  }
};

/**
 * Close account
 */
export const closeAccount = async (req: Request, res: Response) => {
  try {
    const userId = getUserId(req);
    const accountId = req.params.id;

    const result = await accountService.closeAccount(userId, accountId);
    res.status(result.status).json(result.data);
  } catch (error: any) {
    res.status(500).json({
      message: error.message || "Failed to close account",
    });
  }
};

/**
 * Update account
 */
export const updateAccount = async (req: Request, res: Response) => {
  try {
    const userId = req.user.id; // From JWT middleware
    const updates = req.body;   // Partial fields to update
    const result = await accountService.updateAccount(userId, updates);
    res.status(result.status).json(result.data);
  } catch (error: any) {
    res.status(500).json({ message: 'Failed to update account', error: error.message });
  }
};

/**
 * Get account statements
 */
export const getAccountStatements = async (req: Request, res: Response) => {
  try {
    const userId = req.user.id;        // From JWT middleware
    const accountId = req.params.id;   // From route param

    if (!accountId) {
      return res.status(400).json({
        message: "Account ID is required",
      });
    }

    const result = await accountService.getAccountStatements(userId, accountId);

    return res.status(result.status).json(result.data);

  } catch (error: any) {
    return res.status(500).json({
      message: "Failed to fetch account statements",
      error: error.message,
    });
  }
};

/**
 * Upgrade account tier
 */
export const upgradeAccountTier = async (req: Request, res: Response) => {
  try {
    const userId = getUserId(req);
    const accountId = req.params.id;
    const { tier } = req.body;

    const result = await accountService.upgradeAccountTier(
      userId,
      accountId,
      tier
    );

    res.status(result.status).json(result.data);
  } catch (error: any) {
    res.status(500).json({
      message: error.message || "Failed to upgrade tier",
    });
  }
};
