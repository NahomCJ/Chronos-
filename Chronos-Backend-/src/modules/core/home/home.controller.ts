import { Request, Response } from "express";
import { getHomeSummary, getSpendingAnalysis, getOffers } from "./home.service";

export async function homeSummary(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  try {
    const data = await getHomeSummary(userId);
    res.status(200).json(data);
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to fetch summary";
    res.status(500).json({ error: msg });
  }
}

export async function spendingAnalysis(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  try {
    const data = await getSpendingAnalysis(userId);
    res.status(200).json(data);
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to fetch spending analysis";
    res.status(500).json({ error: msg });
  }
}

export async function offers(req: Request, res: Response): Promise<void> {
  try {
    const data = await getOffers();
    res.status(200).json({ offers: data });
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to fetch offers";
    res.status(500).json({ error: msg });
  }
}
