// src/modules/core-banking/validators/fx.validators.ts
import { z } from "zod";

export const fxQuoteSchema = z.object({
    userId: z.string().min(1),
    fromAccountId: z.string().min(1),
    toAccountId: z.string().min(1),
    buyCurrency: z.string().min(3).max(4),
    sellCurrency: z.string().min(3).max(4),
    amount: z.number().positive(),
    amountType: z.enum(["BUY", "SELL"]),
    meta: z.record(z.any()).optional(),
});

export const fxExecuteSchema = z.object({
    orderId: z.string().min(1),
});
