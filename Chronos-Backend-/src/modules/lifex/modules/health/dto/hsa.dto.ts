import { z } from "zod";

export const HsaTransactionDTO = z.object({
  amount: z.number().positive()
});

export type HsaTransactionInput = z.infer<typeof HsaTransactionDTO>;
