import { Request, Response } from 'express';
import * as AkoyaService from './akoya.service';

export const getAccounts = (req: Request, res: Response) => {
  const data = AkoyaService.fetchAccounts();
  res.json(data);
};

export const getBalances = (req: Request, res: Response) => {
  const data = AkoyaService.fetchBalances();
  res.json(data);
};

export const getTransactions = (req: Request, res: Response) => {
  const data = AkoyaService.fetchTransactions();
  res.json(data);
};

export const getStatements = (req: Request, res: Response) => {
  const data = AkoyaService.fetchStatements();
  res.json(data);
};

export const getInvestments = (req: Request, res: Response) => {
  const data = AkoyaService.fetchInvestments();
  res.json(data);
};

export const getCustomerInfo = (req: Request, res: Response) => {
  const data = AkoyaService.fetchCustomerInfo();
  res.json(data);
};
