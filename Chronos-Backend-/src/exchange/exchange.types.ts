// src/modules/exchange/exchange.types.ts
export interface ExchangeRate {
    baseCurrency: string;
    targetCurrency: string;
    rate: number;
}

export interface ExchangeRequest {
    fromCurrency: string;
    toCurrency: string;
    amount: number;
}
