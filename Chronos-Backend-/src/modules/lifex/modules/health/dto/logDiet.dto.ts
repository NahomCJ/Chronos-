import { z } from "zod";

export const LogDietDTO = z.object({
  mealType: z.enum(["breakfast", "lunch", "dinner", "snack"]),
  calories: z.number().positive(),
  nutrients: z.record(z.any())
});

export type LogDietInput = z.infer<typeof LogDietDTO>;

