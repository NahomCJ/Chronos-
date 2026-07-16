import { Request, Response } from 'express';
import * as dwmService from '../services/dwm.service';

export const getDWMSummary = async (req: Request, res: Response) => {
    const data = await dwmService.getSummary(req.query.userId as string);
    res.status(200).json(data);
};

export const postDWMAdvice = async (req: Request, res: Response) => {
    const data = await dwmService.getAdvice(req.body.userId);
    res.status(200).json(data);
};

export const trackGoal = async (req: Request, res: Response) => {
    const data = await dwmService.trackGoal(req.body);
    res.status(200).json(data);
};

export const setupAutoSave = async (req: Request, res: Response) => {
    const data = await dwmService.setupAutoSave(req.body);
    res.status(200).json(data);
};
