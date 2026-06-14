import { Prisma } from "@prisma/client";
import prisma from "../../../models/prisma";

export class CryptoAuditService {
  async log(params: {
    action: string;
    userId?: string | null;
    amount?: number;
    asset?: string;
    metadata?: Record<string, unknown>;
  }): Promise<void> {
    try {
      await prisma.auditLog.create({
        data: {
          action: params.action,
          userId: params.userId || undefined,
          amount: params.amount,
          asset: params.asset,
          metadata: params.metadata as Prisma.InputJsonValue | undefined,
        },
      });
    } catch (err) {
      console.error("Failed to write crypto audit log", err);
    }
  }
}

export const cryptoAuditService = new CryptoAuditService();
export default cryptoAuditService;
