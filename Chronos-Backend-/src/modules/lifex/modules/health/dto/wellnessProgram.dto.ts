import { z } from "zod";

export const EnrollWellnessDTO = z.object({
  programId: z.string(),
});

export type EnrollWellnessInput = z.infer<typeof EnrollWellnessDTO>;
