// src/core/bill/bill.controller.ts

import { Request, Response } from 'express';
import * as billService from './bills.service';
import { BillPaymentDTO } from './bill.types';

/**
 * Get all bill providers
 */
export const getProviders = async (_req: Request, res: Response) => {
  const result = await billService.getProviders();
  return res.status(result.status).json(result.data);
};

/**
 * Pay a bill
 */
export const payBill = async (req: Request, res: Response) => {
  const userId = req.user?.id; // from JWT middleware

  if (!userId) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  const data: BillPaymentDTO = req.body;

  if (!data.providerId || !data.amount) {
    return res.status(400).json({
      message: 'providerId and amount are required',
    });
  }

  const result = await billService.payBill(userId, data);
  return res.status(result.status).json(result.data);
};

/**
 * Get logged-in user's bill history
 */
export const getHistory = async (req: Request, res: Response) => {
  const userId = req.user?.id;

  if (!userId) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  const result = await billService.getHistory(userId);
  return res.status(result.status).json(result.data);
};
