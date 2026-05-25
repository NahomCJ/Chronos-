import { z } from "zod";

export const QuoteRequestSchema = z.object({
  userId: z.string().uuid(),
  side: z.enum(["BUY", "SELL"]),
  base: z.string().toUpperCase().min(2).max(10),   // e.g., BTC
  quote: z.string().toUpperCase().min(2).max(10),  // e.g., USDC
  amount: z.number().positive(),                   // base amount (for BUY: receive base; SELL: sell base)
  maxSlippageBps: z.number().int().min(5).max(1000).default(50), // 0.50% default
});

export const ExecuteRequestSchema = z.object({
  userId: z.string().uuid(),
  quoteId: z.string().uuid(),
  idempotencyKey: z.string().min(8),
  walletId: z.string().uuid().optional(), // optional for custodial default
  paymentSource: z.enum(["CUSTODIAL_WALLET", "NONCUSTODIAL_WALLET", "CARD", "TICKPAY"]).default("CUSTODIAL_WALLET"),
});
