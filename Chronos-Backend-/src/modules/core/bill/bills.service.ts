// src/core/bill/bill.service.ts

import prisma from '../../../config/prisma';
import { BillPaymentDTO } from './bill.types';
import { NotificationService } from '../../notification/notificatoin.service';
import * as T from '../../notification/email.templates';

/**
 * Fetch all available bill providers (from DB)
 */
export const getProviders = async () => {
  try {
    const providers = await prisma.billProvider.findMany({
      orderBy: { createdAt: 'asc' },
    });

    return {
      status: 200,
      data: { providers },
    };
  } catch (error: any) {
    return {
      status: 500,
      data: { message: 'Failed to fetch providers', error: error.message },
    };
  }
};

/**
 * Pay a bill
 */
export const payBill = async (userId: string, data: BillPaymentDTO) => {
  try {
    const reference = 'REF-' + Math.floor(100000 + Math.random() * 900000);

    // Optional: validate provider exists
    const provider = await prisma.billProvider.findUnique({
      where: { id: data.providerId },
    });

    if (!provider) {
      return {
        status: 404,
        data: { message: 'Invalid bill provider' },
      };
    }

    const payment = await prisma.billPayment.create({
      data: {
        userId,
        providerId: data.providerId,
        amount: data.amount,
        reference,
        // status defaults to PENDING
        // createdAt handled by Prisma
      },
    });

    NotificationService.notifyUser(userId, {
      subject: `Bill Payment — $${data.amount} to ${provider.name}`,
      title: "Bill Payment",
      message: T.billPayment(provider.name, String(data.amount), reference),
    }).catch(() => {});

    return {
      status: 201,
      data: { message: 'Bill payment created', payment },
    };
  } catch (error: any) {
    return {
      status: 500,
      data: { message: 'Failed to pay bill', error: error.message },
    };
  }
};

/**
 * Get bill payment history for a user
 */
export const getHistory = async (userId: string) => {
  try {
    const history = await prisma.billPayment.findMany({
      where: { userId },
      include: {
        provider: true, // include provider details
      },
      orderBy: { createdAt: 'desc' },
    });

    return {
      status: 200,
      data: {
        message: history.length ? 'Bill history fetched' : 'No bills found',
        history,
      },
    };
  } catch (error: any) {
    return {
      status: 500,
      data: { message: 'Failed to fetch bill history', error: error.message },
    };
  }
};
