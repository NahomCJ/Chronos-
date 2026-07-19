// src/core/cards/cards.service.ts
import prisma from '../../../config/prisma';
import { CardType as PrismaCardType, CardStatus } from '@prisma/client';
import { IssueCardDTO, ReplaceCardDTO } from './card.types';
import * as bcrypt from 'bcrypt';
import { NotificationService } from '../../notification/notificatoin.service';
import * as T from '../../notification/email.templates';

export const issueCard = async (data: IssueCardDTO) => {
  const account = await prisma.account.findUnique({ where: { id: data.accountId } });
  if (!account) return { status: 404, data: { message: 'Account not found' } };

  const cardType = PrismaCardType[data.type as keyof typeof PrismaCardType] ?? PrismaCardType.VIRTUAL;
  const card = await prisma.card.create({
    data: {
      accountId: data.accountId,
      brand: data.brand,
      last4: data.last4,
      type: cardType,
      status: CardStatus.ACTIVE,
    },
  });

  NotificationService.notifyUser(account.userId, {
    subject: `Your ${cardType} Card is Ready`,
    title: "Card Issued",
    message: T.cardIssued(cardType, data.last4),
  }).catch(() => {});

  return { status: 201, data: { card } };
};

export const listCards = async (params: { accountId?: string; userId?: string; type?: string }) => {
  const where: any = {};
  if (params.accountId) where.accountId = params.accountId;
  if (params.userId) where.account = { userId: params.userId };
  if (params.type) where.type = PrismaCardType[params.type as keyof typeof PrismaCardType];

  const cards = await prisma.card.findMany({ where, orderBy: { createdAt: 'desc' } });
  return { status: 200, data: { cards } };
};

export const getCardById = async (id: string) => {
  const card = await prisma.card.findUnique({ where: { id } });
  if (!card) return { status: 404, data: { message: 'Card not found' } };
  return { status: 200, data: { card } };
};

export const setCardStatus = async (id: string, status: string, userId?: string) => {
  const card = await prisma.card.findUnique({ where: { id }, include: { account: true } });
  if (!card) return { status: 404, data: { message: 'Card not found' } };

  const newStatus = CardStatus[status as keyof typeof CardStatus];
  const updated = await prisma.card.update({
    where: { id },
    data: { status: newStatus },
  });

  if (newStatus === CardStatus.FROZEN) {
    const ownerId = userId || card.account?.userId;
    if (ownerId) {
      NotificationService.notifyUser(ownerId, {
        subject: "Your Card has been Frozen",
        title: "Card Frozen",
        message: T.cardFrozen(card.last4),
      }).catch(() => {});
    }
  }

  return { status: 200, data: { card: updated } };
};

export const replaceCard = async (id: string, data: ReplaceCardDTO) => {
  const old = await prisma.card.findUnique({ where: { id }, include: { account: true } });
  if (!old) return { status: 404, data: { message: 'Card not found' } };

  const newCard = await prisma.$transaction(async (tx) => {
    await tx.card.update({ where: { id: old.id }, data: { status: CardStatus.FROZEN } });
    return tx.card.create({
      data: {
        accountId: old.accountId,
        brand: data.brand,
        last4: data.last4,
        type: PrismaCardType[data.type as keyof typeof PrismaCardType] ?? PrismaCardType.VIRTUAL,
        status: CardStatus.ACTIVE,
      },
    });
  });

  if (old.account?.userId) {
    NotificationService.notifyUser(old.account.userId, {
      subject: "Your Card has been Replaced",
      title: "Card Replaced",
      message: T.cardReplaced(data.last4),
    }).catch(() => {});
  }

  return { status: 201, data: { newCard } };
};

export const changePin = async (id: string, userId: string, newPin: string) => {
  if (!/^\d{4}$/.test(newPin)) {
    return { status: 400, data: { error: "PIN must be exactly 4 digits" } };
  }

  const card = await prisma.card.findFirst({
    where: { id, account: { userId } },
  });
  if (!card) return { status: 404, data: { error: "Card not found" } };

  const pinHash = await bcrypt.hash(newPin, 10);
  await prisma.card.update({ where: { id }, data: { pinHash } });

  NotificationService.notifyUser(userId, {
    subject: "Your card PIN was updated",
    title: "PIN Changed",
    message: T.pinChanged(card.last4),
  }).catch(() => {});

  return { status: 200, data: { message: "PIN updated successfully" } };
};

export const setSpendingLimits = async (
  id: string,
  userId: string,
  dailyLimit?: number,
  monthlyLimit?: number
) => {
  const card = await prisma.card.findFirst({
    where: { id, account: { userId } },
  });
  if (!card) return { status: 404, data: { error: "Card not found" } };

  const updated = await prisma.card.update({
    where: { id },
    data: {
      ...(dailyLimit !== undefined && { dailyLimit }),
      ...(monthlyLimit !== undefined && { monthlyLimit }),
    },
    select: { id: true, brand: true, last4: true, dailyLimit: true, monthlyLimit: true },
  });

  return { status: 200, data: { card: updated } };
};
