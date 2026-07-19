import prisma from "../../../config/prisma";
import { NotificationType } from "@prisma/client";

export async function createNotification(
  userId: string,
  type: NotificationType,
  title: string,
  body: string,
  data?: Record<string, any>
) {
  return prisma.notification.create({
    data: { userId, type, title, body, data: data ?? {} },
  });
}

export async function getNotifications(
  userId: string,
  unreadOnly = false,
  page = 1,
  limit = 20
) {
  const where: any = { userId };
  if (unreadOnly) where.read = false;

  const [total, items] = await Promise.all([
    prisma.notification.count({ where }),
    prisma.notification.findMany({
      where,
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * limit,
      take: limit,
    }),
  ]);

  return {
    data: items,
    unreadCount: await prisma.notification.count({ where: { userId, read: false } }),
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
      hasNext: page * limit < total,
    },
  };
}

export async function markAsRead(id: string, userId: string) {
  const notification = await prisma.notification.findFirst({
    where: { id, userId },
  });
  if (!notification) throw new Error("Notification not found");

  return prisma.notification.update({
    where: { id },
    data: { read: true },
  });
}

export async function markAllAsRead(userId: string) {
  const result = await prisma.notification.updateMany({
    where: { userId, read: false },
    data: { read: true },
  });
  return { updated: result.count };
}

export async function deleteNotification(id: string, userId: string) {
  const notification = await prisma.notification.findFirst({
    where: { id, userId },
  });
  if (!notification) throw new Error("Notification not found");
  await prisma.notification.delete({ where: { id } });
}
