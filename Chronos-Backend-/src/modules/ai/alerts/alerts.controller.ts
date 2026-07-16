import { Request, Response } from "express";
import {
  getActiveAlerts,
  dismissAlert,
  generateAndStoreAlerts,
} from "./alerts.service";

export async function listAlerts(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  try {
    const alerts = await getActiveAlerts(userId);
    res.status(200).json({ alerts });
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to fetch alerts";
    res.status(500).json({ error: msg });
  }
}

export async function dismiss(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  const id = req.params["id"] as string;

  try {
    await dismissAlert(id, userId);
    res.status(200).json({ success: true });
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to dismiss alert";
    res.status(500).json({ error: msg });
  }
}

export async function generateAlerts(
  req: Request,
  res: Response
): Promise<void> {
  const userId = (req as any).user?.id as string;
  try {
    const count = await generateAndStoreAlerts(userId);
    res.status(200).json({ generated: count });
  } catch (err) {
    const msg =
      err instanceof Error ? err.message : "Failed to generate alerts";
    res.status(500).json({ error: msg });
  }
}
