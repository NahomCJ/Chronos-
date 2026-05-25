import prisma from "../../../models/prisma";

export class CryptoAuditService {
  async emit(event: string, payload: Record<string, any>) {
    await prisma.auditLog.create({
      data: {
        source: "CRYPTO",
        event,
        payload,
      },
    });
  }
}

export default new CryptoAuditService();
