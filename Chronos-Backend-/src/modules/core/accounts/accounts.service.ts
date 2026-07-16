// src/core/accounts/accounts.service.ts

import prisma from '../../../config/prisma';
import { CreateAccountDTO, UpdateAccountDTO } from './accounts.type';

/**
 * Create a new account (JWT-safe)
 */
export const createAccount = async (
  userId: string,
  data: CreateAccountDTO
) => {
  try {
    const accountNumber =
      'AC' + Math.floor(100000000 + Math.random() * 900000000);

    const newAccount = await prisma.account.create({
      data: {
        type: data.type,
        accountNumber,
        tier: data.tier || 'basic',
        user: {
          connect: { id: userId },
        },
        wallets: {
          create: [
            {
              currency: data.currency || 'USD',
              type: 'FIAT',
              status: 'ACTIVE',
            },
          ],
        },
      },
      include: { wallets: true },
    });

    return {
      status: 201,
      data: { message: 'Account created', account: newAccount },
    };
  } catch (error: any) {
    return {
      status: 500,
      data: { message: 'Failed to create account', error: error.message },
    };
  }
};

/**
 * Fetch all accounts for logged-in user
 */
export const getAllAccounts = async (userId: string) => {
  const accounts = await prisma.account.findMany({
    where: { userId },
    include: { wallets: true },
  });

  return {
    status: 200,
    data: { accounts },
  };
};

/**
 * Fetch single account (ownership enforced)
 */
export const getAccountById = async (
  userId: string,
  id: string
) => {
  const account = await prisma.account.findFirst({
    where: { id, userId },
    include: { wallets: true },
  });

  if (!account) {
    return { status: 404, data: { message: 'Account not found' } };
  }

  return { status: 200, data: { account } };
};

/**
 * Freeze account (ownership enforced)
 */
export const freezeAccount = async (
  userId: string,
  id: string
) => {
  const updated = await prisma.account.updateMany({
    where: { id, userId },
    data: { status: 'SUSPENDED' },
  });

  if (!updated.count) {
    return { status: 404, data: { message: 'Account not found' } };
  }

  return { status: 200, data: { message: 'Account frozen' } };
};

/**
 * Close account (ownership enforced)
 */
export const closeAccount = async (
  userId: string,
  id: string
) => {
  const updated = await prisma.account.updateMany({
    where: { id, userId },
    data: { status: prisma.accountStatus.CLOSED },
  });

  if (!updated.count) {
    return { status: 404, data: { message: 'Account not found' } };
  }

  return { status: 200, data: { message: 'Account closed' } };
};

/**
 * Update account details (ownership enforced)
 */
export const updateAccount = async (userId: string, updates: Partial<UpdateAccountDTO>) => {
  try {
    // Find the account belonging to this user
    const account = await prisma.account.findFirst({
      where: { id: updates.id, userId },
    });

    if (!account) {
      return { status: 404, data: { message: 'Account not found or not owned by user' } };
    }

    // Only update fields that are allowed
    const { id, ...data } = updates;

    const updated = await prisma.account.update({
      where: { id: account.id },
      data,
    });

    return { status: 200, data: { message: 'Account updated', account: updated } };
  } catch (error: any) {
    return { status: 500, data: { message: 'Failed to update account', error: error.message } };
  }
};




/**
 * Upgrade account tier
 */
export const upgradeAccountTier = async (
  userId: string,
  id: string,
  tier: string
) => {
  const updated = await prisma.account.updateMany({
    where: { id, userId },
    data: { tier },
  });

  if (!updated.count) {
    return { status: 404, data: { message: 'Account not found' } };
  }

  return {
    status: 200,
    data: { message: `Account tier upgraded to ${tier}` },
  };
};

/**
 * Fetch account statements (ownership enforced)
 */
export const getAccountStatements = async (userId: string, accountId: string) => {
  try {
    const statements = await prisma.ledgerEntry.findMany({
      where: {
        wallet: {
          account: {
            id: accountId,
            userId
          }
        }
      },
      orderBy: {
        createdAt: "desc"
      }
    });

    return {
      status: 200,
      data: {
        message:
          statements.length === 0
            ? "No transactions yet"
            : "Statements fetched successfully",
        statements
      }
    };

  } catch (error: any) {
    return {
      status: 500,
      data: {
        message: "Failed to retrieve statements",
        error: error.message
      }
    };
  }
};
