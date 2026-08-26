// ============================================================
// Stock/ETF market data — live quotes, no API key required.
// Primary: Yahoo Finance's public batch quote endpoint.
// Fallback: Yahoo Finance's per-symbol chart endpoint (also public,
// used by libraries like yfinance when the quote endpoint's
// crumb/cookie requirement is enforced for a given IP).
// Mirrors the Paxos-primary/CoinGecko-fallback pattern in
// src/modules/crypto/services/crypto.paxos.service.ts.
// ============================================================

const TTL_MS = 15_000;

export const SUPPORTED_STOCKS = [
  { symbol: "AAPL", name: "Apple Inc.", kind: "STOCK" },
  { symbol: "MSFT", name: "Microsoft Corp.", kind: "STOCK" },
  { symbol: "GOOGL", name: "Alphabet Inc.", kind: "STOCK" },
  { symbol: "AMZN", name: "Amazon.com Inc.", kind: "STOCK" },
  { symbol: "NVDA", name: "NVIDIA Corp.", kind: "STOCK" },
  { symbol: "TSLA", name: "Tesla Inc.", kind: "STOCK" },
  { symbol: "META", name: "Meta Platforms Inc.", kind: "STOCK" },
  { symbol: "NFLX", name: "Netflix Inc.", kind: "STOCK" },
  { symbol: "DIS", name: "The Walt Disney Co.", kind: "STOCK" },
  { symbol: "JPM", name: "JPMorgan Chase & Co.", kind: "STOCK" },
  { symbol: "SPY", name: "SPDR S&P 500 ETF Trust", kind: "ETF" },
  { symbol: "QQQ", name: "Invesco QQQ Trust", kind: "ETF" },
  { symbol: "VTI", name: "Vanguard Total Stock Market ETF", kind: "ETF" },
  { symbol: "VOO", name: "Vanguard S&P 500 ETF", kind: "ETF" },
  { symbol: "ARKK", name: "ARK Innovation ETF", kind: "ETF" },
] as const;

export type SupportedStockSymbol = (typeof SUPPORTED_STOCKS)[number]["symbol"];

const SUPPORTED_SYMBOLS = new Set<string>(SUPPORTED_STOCKS.map((s) => s.symbol));

export interface StockQuote {
  symbol: string;
  price: number;
  changePct: number;
  currency: string;
  marketState: string;
}

interface CacheEntry {
  quote: StockQuote;
  ts: number;
}

const cache = new Map<string, CacheEntry>();

export function isSupportedSymbol(symbol: string): boolean {
  return SUPPORTED_SYMBOLS.has(symbol.toUpperCase());
}

async function fetchQuoteBatch(symbols: string[]): Promise<Record<string, StockQuote>> {
  const url = `https://query1.finance.yahoo.com/v7/finance/quote?symbols=${symbols.join(",")}`;
  const res = await fetch(url, {
    headers: {
      "User-Agent": "Mozilla/5.0 (compatible; Chronos-App/1.0)",
      Accept: "application/json",
    },
  });
  if (!res.ok) throw new Error(`Yahoo quote batch failed: ${res.status}`);
  const data = (await res.json()) as any;
  const results = data?.quoteResponse?.result ?? [];
  if (!Array.isArray(results) || results.length === 0) {
    throw new Error("Yahoo quote batch returned no results");
  }

  const out: Record<string, StockQuote> = {};
  for (const r of results) {
    if (!r?.symbol || typeof r.regularMarketPrice !== "number") continue;
    out[r.symbol] = {
      symbol: r.symbol,
      price: r.regularMarketPrice,
      changePct: r.regularMarketChangePercent ?? 0,
      currency: r.currency ?? "USD",
      marketState: r.marketState ?? "UNKNOWN",
    };
  }
  return out;
}

async function fetchQuoteChart(symbol: string): Promise<StockQuote> {
  const url = `https://query1.finance.yahoo.com/v8/finance/chart/${symbol}`;
  const res = await fetch(url, {
    headers: {
      "User-Agent": "Mozilla/5.0 (compatible; Chronos-App/1.0)",
      Accept: "application/json",
    },
  });
  if (!res.ok) throw new Error(`Yahoo chart failed for ${symbol}: ${res.status}`);
  const data = (await res.json()) as any;
  const meta = data?.chart?.result?.[0]?.meta;
  if (!meta || typeof meta.regularMarketPrice !== "number") {
    throw new Error(`Yahoo chart returned no price for ${symbol}`);
  }
  const price = meta.regularMarketPrice as number;
  const prevClose = (meta.chartPreviousClose ?? meta.previousClose ?? price) as number;
  const changePct = prevClose > 0 ? ((price - prevClose) / prevClose) * 100 : 0;
  return {
    symbol,
    price,
    changePct,
    currency: meta.currency ?? "USD",
    marketState: meta.marketState ?? "UNKNOWN",
  };
}

async function fetchLive(symbols: string[]): Promise<Record<string, StockQuote>> {
  try {
    const batch = await fetchQuoteBatch(symbols);
    // If the batch omitted any requested symbol, fall through to per-symbol for those.
    const missing = symbols.filter((s) => !batch[s]);
    if (missing.length === 0) return batch;

    const filled = await Promise.all(
      missing.map(async (s) => {
        try {
          return await fetchQuoteChart(s);
        } catch {
          return null;
        }
      }),
    );
    for (const q of filled) if (q) batch[q.symbol] = q;
    return batch;
  } catch {
    // Batch endpoint unavailable — fall back to per-symbol chart calls.
    const out: Record<string, StockQuote> = {};
    await Promise.all(
      symbols.map(async (s) => {
        try {
          out[s] = await fetchQuoteChart(s);
        } catch {
          // leave missing — caller decides how to handle a gap
        }
      }),
    );
    return out;
  }
}

/** Returns live quotes for the given symbols, using a short-lived cache to avoid hammering Yahoo. */
export async function getQuotes(symbols: string[]): Promise<Record<string, StockQuote>> {
  const now = Date.now();
  const stale = symbols.filter((s) => {
    const cached = cache.get(s);
    return !cached || now - cached.ts >= TTL_MS;
  });

  if (stale.length > 0) {
    const fresh = await fetchLive(stale);
    for (const [symbol, quote] of Object.entries(fresh)) {
      cache.set(symbol, { quote, ts: now });
    }
  }

  const out: Record<string, StockQuote> = {};
  for (const s of symbols) {
    const cached = cache.get(s);
    if (cached) out[s] = cached.quote;
  }
  return out;
}

export async function getQuote(symbol: string): Promise<StockQuote> {
  const upper = symbol.toUpperCase();
  const quotes = await getQuotes([upper]);
  const quote = quotes[upper];
  if (!quote) throw new Error(`No live quote available for ${upper}`);
  return quote;
}

export async function getAllQuotes(): Promise<Record<string, StockQuote>> {
  return getQuotes(SUPPORTED_STOCKS.map((s) => s.symbol));
}
