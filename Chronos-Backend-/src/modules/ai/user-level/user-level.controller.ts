import { Request, Response } from "express";
import { getUserLevel, setUserLevel, scoreQuiz } from "./user-level.service";
import { UserLevel } from "@prisma/client";

export async function getLevel(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  try {
    const level = await getUserLevel(userId);
    res.status(200).json({ level });
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to get user level";
    res.status(500).json({ error: msg });
  }
}

export async function setLevel(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  const { level } = req.body as { level?: UserLevel };

  const valid: UserLevel[] = ["BEGINNER", "INTERMEDIATE", "ADVANCED"];
  if (!level || !valid.includes(level)) {
    res.status(400).json({ error: "level must be BEGINNER, INTERMEDIATE, or ADVANCED" });
    return;
  }

  try {
    await setUserLevel(userId, level);
    res.status(200).json({ level });
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to set user level";
    res.status(500).json({ error: msg });
  }
}

export async function submitQuiz(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  const { answers } = req.body as { answers?: Record<string, string> };

  if (!answers || typeof answers !== "object") {
    res.status(400).json({ error: "answers object is required (q1-q5 with values a, b, or c)" });
    return;
  }

  try {
    const level = scoreQuiz(answers);
    await setUserLevel(userId, level);
    res.status(200).json({ level, message: `You've been placed at ${level} level.` });
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Quiz submission failed";
    res.status(500).json({ error: msg });
  }
}
