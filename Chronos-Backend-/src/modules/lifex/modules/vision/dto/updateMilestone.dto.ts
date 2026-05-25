import { z } from "zod";

export const updateMilestoneDto = z.object({
  status: z.enum(["PENDING", "COMPLETED", "MISSED"])
});

