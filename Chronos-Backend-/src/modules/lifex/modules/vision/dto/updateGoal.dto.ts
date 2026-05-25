import { z } from "zod";

export const updateGoalDto = z.object({
  title: z.string().optional(),
  description: z.string().optional(),
  status: z.enum(["ACTIVE", "COMPLETED", "PAUSED"]).optional()
});
