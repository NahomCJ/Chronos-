// ============================================================
// Fee & Spread Configuration
// All rates are externalized via environment variables.
// NEVER hardcode fee rates.
// ============================================================

export const feeConfig = {
  defaultRate: parseFloat(process.env.FEE_RATE_DEFAULT ?? '0.005'),  // 0.5%
  minRate:     parseFloat(process.env.FEE_RATE_MIN    ?? '0.002'),  // 0.2%
  maxRate:     parseFloat(process.env.FEE_RATE_MAX    ?? '0.010'),  // 1.0%
  spreadRate:  parseFloat(process.env.SPREAD_RATE     ?? '0.002'),  // 0.2%
};

// Daily trading limits by user tier
export const tradingLimits = {
  standard:     parseFloat(process.env.DAILY_TRADE_LIMIT_STANDARD     ?? '10000'),
  verified_plus: parseFloat(process.env.DAILY_TRADE_LIMIT_VERIFIED_PLUS ?? '50000'),
};

// Supported assets
export const SUPPORTED_ASSETS = ['BTC', 'ETH', 'SOL', 'UNI', 'AAVE', 'LINK'] as const;
export type SupportedAsset = typeof SUPPORTED_ASSETS[number];
