import { z } from "zod";

export const updateHabitDto = z.object({
  progress: z.number().min(0).max(100),
  status: z.enum(["ACTIVE", "COMPLETED", "PAUSED"]).optional()
});
