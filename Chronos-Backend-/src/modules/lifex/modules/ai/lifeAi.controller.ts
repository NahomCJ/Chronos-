import { Response } from "express";
import { LifeAiService } from "./lifeAi.service";

const service = new LifeAiService();

export class LifeAiController {
  insights = async (req: any, res: Response) => {
    const data = await service.getInsights(req.user.id);
    res.json(data);
  };

  chat = async (req: any, res: Response) => {
    const { message } = req.body;
    if (!message) { res.status(400).json({ error: "message is required" }); return; }
    const data = await service.coachReply(req.user.id, message);
    res.json(data);
  };

  weeklyPlan = async (req: any, res: Response) => {
    const data = await service.weeklyPlan(req.user.id);
    res.json(data);
  };
}
