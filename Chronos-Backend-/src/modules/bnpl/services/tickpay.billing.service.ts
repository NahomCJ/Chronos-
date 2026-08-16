import prisma from "../models/prisma";
import { toDecimalString } from "../../../utils/money";

const FEE_RATE = parseFloat(process.env.TICKPAY_FEE_RATE || "0.005");
const INSTALLMENTS = parseInt(process.env.TICKPAY_FEE_INSTALLMENTS || "3", 10);
const BILL_CYCLE_MONTHS = parseInt(process.env.TICKPAY_BILL_CYCLE_MONTHS || "1", 10);

class BillingService {
  /**
   * Schedule fee installments for a purchase within a transaction
   */
  async scheduleFeeInstallments(
    tx: typeof prisma,  // pass the transaction object
    tickPayAccountId: string,
    purchaseTxId: string,
    amount: number
  ) {
    const totalFee = round(amount * FEE_RATE, 2);
    const per = Math.floor((totalFee / INSTALLMENTS) * 100) / 100;
    let remaining = totalFee;

    const installmentData = [];
    for (let i = 1; i <= INSTALLMENTS; i++) {
      const due = new Date();
      due.setMonth(due.getMonth() + i * BILL_CYCLE_MONTHS);

      const feeAmount = i === INSTALLMENTS ? round(remaining, 2) : per;
      remaining = round(remaining - feeAmount, 2);

      installmentData.push({
        tickPayAccountId,
        purchaseTxId,
        amount: toDecimalString(feeAmount),
        dueDate: due,
        status: "SCHEDULED" as const,
      });
    }

    // Single batched insert instead of one INSERT per installment — same
    // effect, one round trip. createManyAndReturn (Prisma 6, Postgres) gives
    // back the inserted rows (with ids) so callers keep getting full records.
    const installments = await tx.tickPayFeeInstallment.createManyAndReturn({
      data: installmentData,
    });
    installments.sort((a, b) => a.dueDate.getTime() - b.dueDate.getTime());

    return {
      totalFee: toDecimalString(totalFee),
      perInstallment: toDecimalString(round(totalFee / INSTALLMENTS, 2)),
      installments,
    };
  }
}

function round(v: number, d = 2) {
  return Math.round(v * Math.pow(10, d)) / Math.pow(10, d);
}

export default new BillingService();
