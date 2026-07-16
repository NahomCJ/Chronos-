// src/controllers/gov.controller.ts

import { Request, Response } from 'express';
import * as govService from './gov.service';

export const payTax = async (req: Request, res: Response) => {
    const payment = await govService.payGovernmentFee(req.body.userId, 'tax', req.body.amount);
    res.status(200).json({ message: 'Tax paid', payment });
};

export const payTransport = async (req: Request, res: Response) => {
    const payment = await govService.payGovernmentFee(req.body.userId, 'transport', req.body.amount);
    res.status(200).json({ message: 'Transport fee paid', payment });
};

export const payEducation = async (req: Request, res: Response) => {
    const payment = await govService.payGovernmentFee(req.body.userId, 'education', req.body.amount);
    res.status(200).json({ message: 'Education fee paid', payment });
};

export const payVisa = async (req: Request, res: Response) => {
    const payment = await govService.payGovernmentFee(req.body.userId, 'visa', req.body.amount);
    res.status(200).json({ message: 'Visa fee paid', payment });
};
