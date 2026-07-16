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

  // Can they actually cover what's coming due? This is the "heads up before
  // you overspend" check for bills and debt the LifeX/Panther redesign needs.
  if (mainWallet) {
    const pendingBills = await prisma.billPayment.findMany({
      where: { userId, status: "PENDING" },
    });
    const upcomingBillsTotal = pendingBills.reduce(
      (sum, b) => sum + Number(b.amount),
      0
    );

    if (upcomingBillsTotal > 0) {
      if (upcomingBillsTotal > mainWallet.balance) {
        created.push({
          type: "CASHFLOW" as AiAlertType,
          domain: "BANKING" as AiAlertDomain,
          title: "Upcoming Bills Exceed Your Balance",
          message: `You have $${upcomingBillsTotal.toFixed(2)} in pending bills but only $${mainWallet.balance.toFixed(2)} available. Avoid non-essential spending until these clear.`,
        });
      } else if (upcomingBillsTotal > mainWallet.balance * 0.7) {
        created.push({
          type: "CASHFLOW" as AiAlertType,
          domain: "BANKING" as AiAlertDomain,
          title: "Bills Are Tight This Cycle",
          message: `Pending bills ($${upcomingBillsTotal.toFixed(2)}) take up most of your balance ($${mainWallet.balance.toFixed(2)}). Spend carefully until they clear.`,
        });
      }
    }

    const activeLoans = await prisma.loan.findMany({
      where: { userId, status: "ACTIVE" },
    });
    if (activeLoans.length > 0) {
      const totalDebt = activeLoans.reduce(
        (sum, l) => sum + Number(l.outstandingAmount),
        0
      );
      const soon = new Date();
      soon.setDate(soon.getDate() + 7);
      const dueSoon = activeLoans.filter((l) => l.dueDate <= soon);

      if (dueSoon.length > 0) {
        const dueSoonTotal = dueSoon.reduce(
          (sum, l) => sum + Number(l.outstandingAmount),
          0
        );
        created.push({
          type: "CASHFLOW" as AiAlertType,
          domain: "BANKING" as AiAlertDomain,
          title: `${dueSoon.length} Debt Payment${dueSoon.length > 1 ? "s" : ""} Due This Week`,
          message: `${dueSoon.map((l) => l.name).join(", ")} — $${dueSoonTotal.toFixed(2)} due within 7 days. Across all your debts you owe $${totalDebt.toFixed(2)}.`,
        });
      } else if (totalDebt > mainWallet.balance * 3) {
        created.push({
          type: "CASHFLOW" as AiAlertType,
          domain: "BANKING" as AiAlertDomain,
          title: "Debt Load Is Getting Heavy",
          message: `You're carrying $${totalDebt.toFixed(2)} across ${activeLoans.length} loan${activeLoans.length > 1 ? "s" : ""} against a $${mainWallet.balance.toFixed(2)} balance. Consider a payoff plan before taking on more.`,
        });
      }
    }
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
