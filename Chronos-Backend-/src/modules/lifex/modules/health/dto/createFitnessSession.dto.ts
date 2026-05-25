import { z } from "zod";

export const CreateFitnessSessionDTO = z.object({
  type: z.enum(["gym", "run", "swim", "cycling", "yoga"]),
  duration: z.number().int().positive(),
  caloriesBurned: z.number().positive()
});

export type CreateFitnessSessionInput =
  z.infer<typeof CreateFitnessSessionDTO>;
