// src/core/transfer/utils/transfer.helpers.ts
import Decimal from "decimal.js";

export function calculateFee(amountStr: string, feeRate: number) {
    const amount = new Decimal(amountStr);
    const fee = amount.mul(new Decimal(feeRate));
    return fee.toFixed(8);
}

export function validatePositiveAmount(amountStr: string) {
    try {
        const d = new Decimal(amountStr);
        return d.gt(0);
    } catch (e) {
        return false;
    }
}
