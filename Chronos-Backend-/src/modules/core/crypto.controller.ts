import { Request, Response } from 'express';
import * as cryptoService from '../services/crypto.service';

export const getWallet = async (req: Request, res: Response) => {
    const wallet = await cryptoService.getWallet(req.query.userId as string);
    res.status(200).json({ wallet });
};

export const getMarket = async (_: Request, res: Response) => {
    const rates = await cryptoService.getMarketRates();
    res.status(200).json({ rates });
};

export const buy = async (req: Request, res: Response) => {
    const { userId, crypto, fiatAmount } = req.body;
    const result = await cryptoService.buyCrypto(userId, crypto, fiatAmount);
    res.status(200).json(result);
};

export const sell = async (req: Request, res: Response) => {
    const { userId, crypto, amount } = req.body;
    const result = await cryptoService.sellCrypto(userId, crypto, amount);
    res.status(200).json(result);
};

export const send = async (req: Request, res: Response) => {
    const { userId, crypto, amount, toUserId } = req.body;
    const result = await cryptoService.sendCrypto(userId, crypto, amount, toUserId);
    res.status(200).json(result);
};
