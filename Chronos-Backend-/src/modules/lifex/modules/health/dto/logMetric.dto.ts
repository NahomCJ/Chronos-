import { z } from "zod";

export const LogMetricDTO = z.object({
  metricType: z.enum(["weight", "sleep", "steps", "calories", "heart_rate"]),
  value: z.number(),
  unit: z.string(),
  recordedAt: z.date().optional(),
});

// ✅ TYPE EXPORT (THIS IS CRITICAL)
export type LogMetricInput = z.infer<typeof LogMetricDTO>;
