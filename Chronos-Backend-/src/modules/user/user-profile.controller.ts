import { Request, Response } from "express";
import { getUserProfile, updateUserProfile } from "./user-profile.service";

export async function getProfile(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  try {
    const profile = await getUserProfile(userId);
    res.status(200).json(profile);
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to fetch profile";
    res.status(500).json({ error: msg });
  }
}

export async function patchProfile(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  const { firstName, lastName, phone } = req.body;
  try {
    const updated = await updateUserProfile(userId, { firstName, lastName, phone });
    res.status(200).json(updated);
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to update profile";
    res.status(500).json({ error: msg });
  }
}
