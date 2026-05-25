import { z } from "zod";

export const createHabitDto = z.object({
  habitName: z.string(),
  frequency: z.enum(["DAILY", "WEEKLY", "MONTHLY"]),
  progress: z.number().min(0).max(100)
});
