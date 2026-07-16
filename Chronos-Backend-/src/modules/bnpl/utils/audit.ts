// src/utils/audit.ts
import prisma from "../models/prisma";

export async function auditLog(payload: {
  actorId?: string | null;
  accountId?: string | null;
  scope?: string;
  action: string;
  entityId?: string | null;
  metadata?: any;
}) {
  try {
    await prisma.tickPayAudit.create({
      data: {
        accountId: payload.accountId ?? payload.entityId ?? "unknown",
        actorId: payload.actorId ?? null,
        action: `${payload.scope ?? "TICKPAY"}_${payload.action}`,
        payload: payload.metadata ?? {},
      },
    });
  } catch (err) {
    // non-blocking: log but don't throw
    // In prod: push to logging pipeline
    // eslint-disable-next-line no-console
    console.error("auditLog failed", err);
  }
}

