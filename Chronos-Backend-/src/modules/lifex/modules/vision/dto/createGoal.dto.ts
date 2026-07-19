import { z } from "zod";

export const createGoalDto = z.object({
  title: z.string().min(3),
  description: z.string(),
  category: z.enum([
    "CAREER",
    "PERSONAL",
    "FINANCE",
    "HEALTH",
    "SOCIAL",
    "SPIRITUAL"
  ]),
  startDate: z.string().datetime(),
  endDate: z.string().datetime()
});
