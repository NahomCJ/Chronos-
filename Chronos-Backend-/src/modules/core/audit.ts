import prisma from "../models/prisma";

export async function auditLog(params: {
  userId?: string | null;
  actorId?: string | null;
  scope: string;           // "TICKPAY"
  action: string;          // "PURCHASE" | "REPAYMENT" | ...
  entityId?: string | null;
  metadata?: Record<string, any>;
}) {
  try {
    await prisma.auditLog.create({
      data: {
        userId: params.userId || null,
        actorId: params.actorId || null,
        scope: params.scope,
        action: params.action,
        entityId: params.entityId || null,
        metadata: params.metadata || {},
      },
    });
  } catch (e) {
    // never throw; logging must not break the flow
    console.error("auditLog error:", e);
  }
}
