import { VenueQuote, VenueSide } from "../providers/pricing.types";
// You would wire real providers below
export class CexRouter {
  async getQuote(params: { side: VenueSide; base: string; quote: string; amount: number }): Promise<VenueQuote | null> {
    // Hit Coinbase/Binance pricing endpoints; here we mock:
    return {
      venue: "CEX",
      price: await this.mockPrice(params.base, params.quote),
      feeBps: 10,
      providerRef: "COINBASE",
    };
  }

  async execute(params: {
    side: VenueSide;
    base: string;
    quote: string;
    amount: number;
    maxSlippageBps: number;
    accountRef: string; // user account at exchange
  }): Promise<{ externalOrderId: string; fills: Array<{ price: number; qty: number }> }> {
    // Place order on exchange API (market/limit w/ slippage controls)
    return { externalOrderId: "mock-order-123", fills: [{ price: 100, qty: params.amount }] };
  }

  private async mockPrice(_base: string, _quote: string) {
    return 100 + Math.random(); // mock
  }
}
