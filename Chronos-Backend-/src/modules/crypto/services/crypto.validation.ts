import { z } from "zod";
import { SUPPORTED_CRYPTO_ASSETS } from "./crypto.paxos.service";

export const AssetSchema = z
  .string()
  .trim()
  .transform((value) => value.toUpperCase())
  .refine((value) => SUPPORTED_CRYPTO_ASSETS.includes(value as any), {
    message: `asset must be one of: ${SUPPORTED_CRYPTO_ASSETS.join(", ")}`,
  });

export const BuyRequestSchema = z.object({
  asset: AssetSchema,
  amount_usd: z.number().positive().min(5),
});

export const SellRequestSchema = z.object({
  asset: AssetSchema,
  amount_crypto: z.number().positive(),
});

export const HistoryQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(25),
  asset: AssetSchema.optional(),
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
  cursor: z.string().optional(),
});

export type BuyRequest = z.infer<typeof BuyRequestSchema>;
export type SellRequest = z.infer<typeof SellRequestSchema>;
export type HistoryQuery = z.infer<typeof HistoryQuerySchema>;
