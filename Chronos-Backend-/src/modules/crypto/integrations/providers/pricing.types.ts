export type VenueSide = "BUY" | "SELL";

export interface VenueQuote {
  venue: "DEX" | "CEX";
  price: number;         // base/quote price
  feeBps: number;        // venue fee estimate
  providerRef?: string;  // route id, symbol, etc.
}
