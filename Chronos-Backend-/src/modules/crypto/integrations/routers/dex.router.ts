import MoralisClient from "../moralis.client";
import { VenueQuote, VenueSide } from "../providers/pricing.types";

export class DexRouter {
  async getQuote(params: { side: VenueSide; base: string; quote: string; amount: number }): Promise<VenueQuote | null> {
    try {
      const q = await MoralisClient.getSwapQuote(params.base, params.quote, params.amount, params.side);
      return {
        venue: "DEX",
        price: q.price,
        feeBps: q.feeBps ?? 15,
        providerRef: q.routeId,
      };
    } catch (e) {
      return null;
    }
  }

  async execute(params: {
    routeId: string;
    side: VenueSide;
    base: string;
    quote: string;
    amount: number;
    maxSlippageBps: number;
    walletAddress: string;
  }): Promise<{ txHash: string }> {
    return MoralisClient.executeSwap(params);
  }
}
