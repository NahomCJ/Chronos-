// src/controllers/tickpay.admin.controller.ts
import { Request, Response } from "express";
import prisma from "../models/prisma";
import { auditLog } from "../utils/audit";

class TickPayAdminController {
  async listAccounts(_req: Request, res: Response) {
    const accounts = await prisma.tickPayAccount.findMany({
      include: { user: true, feeInstallments: true, transactions: true },
      orderBy: { createdAt: "desc" },
    });
    res.json(accounts);
  }

  async setCreditLimit(req: Request, res: Response) {
    const { userId } = req.params;
    const { creditLimit } = req.body;
    const acct = await prisma.tickPayAccount.update({ where: { userId }, data: { creditLimit: String(creditLimit) } });
    await auditLog({ actorId: (req as any).user?.id || null, accountId: acct.id, action: "ADMIN_SET_LIMIT", metadata: { creditLimit } });
    res.json(acct);
  }

  async waiveFee(req: Request, res: Response) {
    const { feeId } = req.params;
    const fee = await prisma.tickPayFeeInstallment.update({
      where: { id: feeId },
      data: { status: "WAIVED", paidAt: new Date() }, // WAIVED represented as PAID for now
    });
    await auditLog({ actorId: (req as any).user?.id || null, accountId: fee.tickPayAccountId, action: "ADMIN_WAIVE_FEE" });
    res.json(fee);
  }

  async cancelFee(req: Request, res: Response) {
    const { feeId } = req.params;
    const fee = await prisma.tickPayFeeInstallment.update({
      where: { id: feeId },
      data: { status: "CANCELLED" },
    });
    await auditLog({ actorId: (req as any).user?.id || null, accountId: fee.tickPayAccountId, action: "ADMIN_CANCEL_FEE" });
    res.json(fee);
  }

  async suspend(req: Request, res: Response) {
    const { userId } = req.params;
    const acct = await prisma.tickPayAccount.update({ where: { userId }, data: { status: "SUSPENDED" } });
    await auditLog({ actorId: (req as any).user?.id || null, accountId: acct.id, action: "ADMIN_SUSPEND" });
    res.json(acct);
  }

  async resume(req: Request, res: Response) {
    const { userId } = req.params;
    const acct = await prisma.tickPayAccount.update({ where: { userId }, data: { status: "ACTIVE" } });
    await auditLog({ actorId: (req as any).user?.id || null, accountId: acct.id, action: "ADMIN_RESUME" });
    res.json(acct);
  }
}

export default new TickPayAdminController();
