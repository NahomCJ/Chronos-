import { z } from "zod";

export const MedicalRecordDTO = z.object({
  recordType: z.enum(["diagnosis", "prescription", "lab", "vaccination"]),
  description: z.string().min(3),
  documentUrl: z.string().url().optional()
});

export type MedicalRecordInput = z.infer<typeof MedicalRecordDTO>;

