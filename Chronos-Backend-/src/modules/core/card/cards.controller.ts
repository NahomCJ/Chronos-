// src/controllers/cards.controller.ts
import { Request, Response } from 'express';
import * as cardService from './card.service';
import { IssueCardDTO, ReplaceCardDTO, SetCardStatusDTO } from './card.types';

export const issueCard = async (req: Request, res: Response) => {
  const data: IssueCardDTO = req.body;
  const result = await cardService.issueCard(data);
  res.status(result.status).json(result.data);
};

export const listCards = async (req: Request, res: Response) => {
  const params = {
    accountId: req.query.accountId as string,
    userId: req.query.userId as string,
    type: req.query.type as string,
  };
  const result = await cardService.listCards(params);
  res.status(result.status).json(result.data);
};

export const getCardById = async (req: Request, res: Response) => {
  const result = await cardService.getCardById(req.params.id);
  res.status(result.status).json(result.data);
};

export const setCardStatus = async (req: Request, res: Response) => {
  const data: SetCardStatusDTO = req.body;
  const result = await cardService.setCardStatus(req.params.id, data.status);
  res.status(result.status).json(result.data);
};

export const replaceCard = async (req: Request, res: Response) => {
  const data: ReplaceCardDTO = req.body;
  const result = await cardService.replaceCard(req.params.id, data);
  res.status(result.status).json(result.data);
};

export const changePin = async (req: Request, res: Response) => {
  const userId = (req as any).user?.id as string;
  const { newPin } = req.body;
  const result = await cardService.changePin(req.params.id, userId, newPin);
  res.status(result.status).json(result.data);
};

export const setSpendingLimits = async (req: Request, res: Response) => {
  const userId = (req as any).user?.id as string;
  const { dailyLimit, monthlyLimit } = req.body;
  const result = await cardService.setSpendingLimits(
    req.params.id,
    userId,
    dailyLimit,
    monthlyLimit
  );
  res.status(result.status).json(result.data);
};
