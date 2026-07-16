import { Request, Response } from 'express';
import * as currencyService from './currency.services';
import { ConvertCurrencyDTO } from './currency.types';

/**
 * GET /fx/latest?from=USD&to=EUR
 */
export const getLatestRate = async (req: Request, res: Response) => {
  const { from, to } = req.query as { from: string; to: string };
  const result = await currencyService.getLatestRate(from, to);
  res.status(result.status).json(result.data);
};

/**
 * POST /fx/convert
 * Body: { from, to, amount }
 */
export const convertCurrency = async (req: Request, res: Response) => {
  const data: ConvertCurrencyDTO = req.body;
  const result = await currencyService.convertCurrency(data);
  res.status(result.status).json(result.data);
};

/**
 * GET /fx/history?from=USD&to=EUR&start=YYYY-MM-DD&end=YYYY-MM-DD
 */
export const getCurrencyHistory = async (req: Request, res: Response) => {
  const { from, to, start, end } = req.query as {
    from: string;
    to: string;
    start: string;
    end: string;
  };
  const result = await currencyService.getCurrencyHistory(from, to, start, end);
  res.status(result.status).json(result.data);
};
