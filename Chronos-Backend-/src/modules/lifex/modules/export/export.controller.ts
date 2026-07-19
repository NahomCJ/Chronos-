import { Response } from "express";
import { ExportService } from "./export.service";

const service = new ExportService();

export class ExportController {
  health = async (req: any, res: Response) => {
    const data = await service.healthData(req.user.id);
    res.json(data);
  };

  finance = async (req: any, res: Response) => {
    const data = await service.financeData(req.user.id);
    res.json(data);
  };

  education = async (req: any, res: Response) => {
    const data = await service.educationData(req.user.id);
    res.json(data);
  };

  vision = async (req: any, res: Response) => {
    const data = await service.visionData(req.user.id);
    res.json(data);
  };

  full = async (req: any, res: Response) => {
    const data = await service.fullExport(req.user.id);
    res.json(data);
  };
}
