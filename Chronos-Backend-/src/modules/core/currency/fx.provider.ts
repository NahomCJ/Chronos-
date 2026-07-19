import axios from 'axios';

// Example: you can replace with OpenExchangeRates, Fixer, or any FX API
const API_KEY = process.env.FX_API_KEY || 'YOUR_API_KEY';
const BASE_URL = 'https://open.er-api.com/v6/latest'; // Example free API

export const fxProvider = {
  /**
   * Fetch latest rates for a base currency
   */
  async fetchRates(baseCurrency: string) {
    try {
      const response = await axios.get(`${BASE_URL}/${baseCurrency}`);
      if (response.data && response.data.result === 'success') {
        return response.data.rates; // returns object: { USD: 1, EUR: 0.92, GBP: 0.81, ... }
      }
      throw new Error('Failed to fetch FX rates');
    } catch (error: any) {
      throw new Error(`FX provider error: ${error.message}`);
    }
  },
};
