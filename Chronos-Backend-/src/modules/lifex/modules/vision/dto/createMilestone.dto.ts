import { z } from "zod";

export const createMilestoneDto = z.object({
  goalId: z.string().uuid(),
  title: z.string(),
  description: z.string(),
  dueDate: z.string().datetime()
});

