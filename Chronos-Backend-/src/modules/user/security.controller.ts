import { Request, Response } from 'express';
import * as security from '../services/security.service';

export const enable2FA = (req: Request, res: Response) => {
    const result = security.enable2FA(req.body.userId, req.body.method);
    res.status(200).json(result);
};

export const verify2FA = (req: Request, res: Response) => {
    const result = security.verify2FA(req.body.userId, req.body.code);
    res.status(200).json(result);
};

export const sendNotification = (req: Request, res: Response) => {
    const result = security.sendNotification(req.body.userId, req.body.message);
    res.status(200).json(result);
};

export const getHistory = (req: Request, res: Response) => {
    const result = security.getNotificationHistory(req.query.userId as string);
    res.status(200).json(result);
};
