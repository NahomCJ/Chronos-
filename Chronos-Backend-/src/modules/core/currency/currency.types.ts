export interface ExchangeRateDTO {
  baseCurrency: string;
  quoteCurrency: string;
  rate: number;
  provider?: string;
  timestamp?: Date;
}

export interface ConvertCurrencyDTO {
  from: string;
  to: string;
  amount: number;
}
