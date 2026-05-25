import prisma from "../../../config/prisma";
import { getUserFinancialContext } from "../panther/core/data-retrieval.service";
import { runRiskFraudCheck } from "../panther/agents/banking/risk-fraud.agent";
import { AiAlertType, AiAlertDomain } from "@prisma/client";
import { createNotification } from "../../core/notifications/notifications.service";

export async function getActiveAlerts(userId: string) {
  return prisma.aiAlert.findMany({
    where: { userId, dismissed: false },
    orderBy: { createdAt: "desc" },
    take: 20,
  });
}

export async function dismissAlert(alertId: string, userId: string) {
  return prisma.aiAlert.updateMany({
    where: { id: alertId, userId },
    data: { dismissed: true },
  });
}

export async function generateAndStoreAlerts(userId: string): Promise<number> {
  const ctx = await getUserFinancialContext(userId);
  const risk = await runRiskFraudCheck(ctx, "text");

  const created: Array<{ type: AiAlertType; domain: AiAlertDomain; title: string; message: string }> = [];

  if (risk.level !== "LOW" && risk.flags.length > 0) {
    created.push({
      type: "FRAUD" as AiAlertType,
      domain: "BANKING" as AiAlertDomain,
      title: `Risk Level: ${risk.level}`,
      message: risk.summary,
    });
  }

  if (ctx.tickPay) {
    const utilization =
      ctx.tickPay.outstandingBalance / ctx.tickPay.creditLimit;
    if (utilization > 0.8) {
      created.push({
        type: "BNPL_RISK" as AiAlertType,
        domain: "TICKPAY" as AiAlertDomain,
        title: "TickPay Credit Nearly Full",
        message: `You have used ${(utilization * 100).toFixed(0)}% of your TickPay credit. Consider making a repayment before your next purchase.`,
      });
    }

    const overdue = ctx.tickPay.upcomingInstallments.filter(
      (i) => i.status === "DUE"
    );
    if (overdue.length > 0) {
      created.push({
        type: "BNPL_RISK" as AiAlertType,
        domain: "TICKPAY" as AiAlertDomain,
        title: "Installment Due",
        message: `You have ${overdue.length} TickPay installment(s) due. Pay now to avoid fees.`,
      });
    }
  }

  const mainWallet = ctx.wallets.find(
    (w) => w.type === "FIAT" || w.type === "SYSTEM"
  );
  if (mainWallet && mainWallet.balance < 50) {
    created.push({
      type: "CASHFLOW" as AiAlertType,
      domain: "BANKING" as AiAlertDomain,
      title: "Low Balance",
      message: `Your main wallet balance is $${mainWallet.balance.toFixed(2)}. Consider adding funds to avoid overdraft.`,
    });
  }

  if (created.length === 0) return 0;

  await prisma.aiAlert.createMany({
    data: created.map((a) => ({ ...a, userId })),
  });

  // Mirror each alert as an in-app notification
  await Promise.all(
    created.map((a) =>
      createNotification(userId, "AI_ALERT", a.title, a.message, {
        domain: a.domain,
        type: a.type,
      }).catch(() => {})
    )
  );

  return created.length;
}
