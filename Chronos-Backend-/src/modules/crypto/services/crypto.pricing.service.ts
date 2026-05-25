import { addSeconds, isAfter } from "date-fns";
import prisma from "../../../models/prisma";
import { DexRouter } from "../integrations/routers/dex.router";
import { CexRouter } from "../integrations/routers/cex.router";

const QUOTE_TTL_SECONDS = Number(process.env.CRYPTO_QUOTE_TTL_SEC ?? 30);
const MAKER_FEE_BPS = Number(process.env.CRYPTO_MAKER_FEE_BPS ?? 10); // 0.10%
const TAKER_FEE_BPS = Number(process.env.CRYPTO_TAKER_FEE_BPS ?? 20); // 0.20%
const PLATFORM_SPREAD_BPS = Number(process.env.CRYPTO_PLATFORM_SPREAD_BPS ?? 5); // 0.05%

export type QuoteSide = "BUY" | "SELL";

export interface BestQuote {
  id: string;
  userId: string;
  side: QuoteSide;
  base: string;
  quote: string;
  baseAmount: number;
  price: number;             // gross price
  netPrice: number;          // after fees/spread
  provider: "DEX" | "CEX";
  providerRef?: string;      // route id or venue symbol
  expiresAt: Date;
  maxSlippageBps: number;
}

export class CryptoPricingService {
  private dex = new DexRouter();
  private cex = new CexRouter();

  async getBestQuote(params: {
    userId: string;
    side: QuoteSide;
    base: string;
    quote: string;
    amount: number;
    maxSlippageBps: number;
  }): Promise<BestQuote> {
    const { userId, side, base, quote, amount, maxSlippageBps } = params;

    // parallel venue quotes
    const [dexQ, cexQ] = await Promise.all([
      this.dex.getQuote({ side, base, quote, amount }),
      this.cex.getQuote({ side, base, quote, amount }),
    ]);

    const venueQuotes = [dexQ, cexQ].filter(Boolean) as Array<{
      venue: "DEX" | "CEX";
      price: number;
      providerRef?: string;
      feeBps: number;
    }>;

    if (venueQuotes.length === 0) throw new Error("No liquidity");

    // Apply fees and platform spread to compute net price
    const enriched = venueQuotes.map((q) => {
      const feeBps = q.feeBps + (side === "BUY" ? TAKER_FEE_BPS : MAKER_FEE_BPS) + PLATFORM_SPREAD_BPS;
      const feeFactor = 1 + feeBps / 10000;
      const netPrice = side === "BUY" ? q.price * feeFactor : q.price / feeFactor;
      return { ...q, netPrice };
    });

    // For BUY → choose lowest netPrice; for SELL → highest netPrice
    const best = enriched.reduce((acc, cur) => {
      if (!acc) return cur;
      if (params.side === "BUY") return cur.netPrice < acc.netPrice ? cur : acc;
      return cur.netPrice > acc.netPrice ? cur : acc;
    });

    const expiresAt = addSeconds(new Date(), QUOTE_TTL_SECONDS);

    const quote = await prisma.cryptoQuote.create({
      data: {
        userId,
        side,
        base,
        quote,
        baseAmount: amount,
        grossPrice: best.price,
        netPrice: best.netPrice,
        provider: best.venue,
        providerRef: best.providerRef || null,
        expiresAt,
        maxSlippageBps,
        status: "ACTIVE",
      },
    });

    return {
      id: quote.id,
      userId,
      side,
      base,
      quote,
      baseAmount: amount,
      price: best.price,
      netPrice: best.netPrice,
      provider: best.venue,
      providerRef: best.providerRef ?? undefined,
      expiresAt,
      maxSlippageBps,
    };
  }

  async assertQuoteActive(quoteId: string) {
    const q = await prisma.cryptoQuote.findUnique({ where: { id: quoteId } });
    if (!q) throw new Error("Quote not found");
    if (q.status !== "ACTIVE") throw new Error("Quote not active");
    if (isAfter(new Date(), q.expiresAt)) throw new Error("Quote expired");
    return q;
  }

  async markQuoteUsed(quoteId: string) {
    await prisma.cryptoQuote.update({ where: { id: quoteId }, data: { status: "USED" } });
  }
}

export default new CryptoPricingService();
