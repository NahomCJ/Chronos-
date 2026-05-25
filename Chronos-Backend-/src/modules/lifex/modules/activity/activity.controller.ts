import { Request, Response } from "express";
import { ActivityService } from "./activity.service";

const service = new ActivityService();

export class ActivityController {
  list = async (req: any, res: Response) => {
    const { module } = req.query as { module?: string };
    const logs = await service.list(req.user.id, module);
    res.json(logs);
  };

  log = async (req: any, res: Response) => {
    const { module, type, title, metadata } = req.body;
    if (!module || !type || !title) {
      res.status(400).json({ error: "module, type, and title are required" });
      return;
    }
    const entry = await service.log(req.user.id, module, type, title, metadata);
    res.status(201).json(entry);
  };

  stats = async (req: any, res: Response) => {
    const data = await service.stats(req.user.id);
    res.json(data);
  };

  streak = async (req: any, res: Response) => {
    const data = await service.streak(req.user.id);
    res.json(data);
  };
}
