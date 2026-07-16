import { Request, Response } from 'express';
import { AutonomousInvestorService } from './autonomousInvestor.service';

const service = new AutonomousInvestorService();

export class AutonomousInvestorController {
    async createSettings(req: Request, res: Response) {
        const settings = await service.createSettings(req.body);
        res.json(settings);
    }

    async getSettings(req: Request, res: Response) {
        const settings = await service.getSettings(req.params.userId);
        res.json(settings);
    }

    async updateSettings(req: Request, res: Response) {
        const settings = await service.updateSettings(req.params.userId, req.body);
        res.json(settings);
    }

    async generateInvestmentPlan(req: Request, res: Response) {
        const plan = await service.generateInvestmentPlan(req.params.userId);
        res.json(plan);
    }
}
