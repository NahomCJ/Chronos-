import { z } from "zod";

export const createVisionBoardDto = z.object({
  title: z.string().min(3),
  description: z.string().optional(),
  imageUrls: z.array(z.string().url()).default([])
});
