import { z } from "zod";

export const LogHabitDTO = z.object({
  habitName: z.string(),
  progress: z.number().min(0).max(100),
  completedAt: z.date().optional(),
});

export type LogHabitInput = z.infer<typeof LogHabitDTO>;
