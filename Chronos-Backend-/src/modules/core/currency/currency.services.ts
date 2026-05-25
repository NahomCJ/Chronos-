import prisma from '../../../config/prisma';
import { ExchangeRateDTO } from './currency.types';
import { cached } from '../../core/cache';

/**
 * Get latest FX rate between two currencies
 */
export const getLatestRate = async (base: string, quote: string) => {
  try {
    const rate = await cached(`currency:rate:${base}:${quote}`, 300, () =>
      prisma.exchangeRate.findFirst({
        where: { baseCurrency: base, quoteCurrency: quote },
        orderBy: { createdAt: 'desc' }
      })
    );

    if (!rate) {
      return { status: 404, data: { message: 'Exchange rate not available' } };
    }

    return { status: 200, data: { rate } };
  } catch (error: any) {
    return { status: 500, data: { message: 'Failed to fetch latest rate', error: error.message } };
  }
};

/**
 * Convert amount from one currency to another
 */
export const convertCurrency = async (data: { from: string; to: string; amount: number }) => {
  try {
    const { from, to, amount } = data;

    const rate = await cached(`currency:rate:${from}:${to}`, 300, () =>
      prisma.exchangeRate.findFirst({
        where: { baseCurrency: from, quoteCurrency: to },
        orderBy: { createdAt: 'desc' }
      })
    );

    if (!rate) throw new Error('Exchange rate not available');

    const converted = Number(amount) * Number(rate.rate);

    return { status: 200, data: { from, to, amount, converted, rate: Number(rate.rate) } };
  } catch (error: any) {
    return { status: 500, data: { message: 'Failed to convert currency', error: error.message } };
  }
};

/**
 * Get historical exchange rates between two currencies
 */
export const getCurrencyHistory = async (base: string, quote: string, start: string, end: string) => {
  try {
    const history = await prisma.exchangeRate.findMany({
      where: {
        baseCurrency: base,
        quoteCurrency: quote,
        createdAt: { gte: new Date(start), lte: new Date(end) }
      },
      orderBy: { createdAt: 'asc' }
    });

    return { status: 200, data: { history } };
  } catch (error: any) {
    return { status: 500, data: { message: 'Failed to fetch currency history', error: error.message } };
  }
};
