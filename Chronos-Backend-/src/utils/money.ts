// src/utils/money.ts
// Small helpers for money calculations. Use decimal.js for production.

export const roundToCents = (n: number) => {
  return Math.round(n * 100) / 100;
};

export const toDecimalString = (n: number) => {
  // keep two decimals as string for Prisma decimal
  return roundToCents(n).toFixed(2);
};
 