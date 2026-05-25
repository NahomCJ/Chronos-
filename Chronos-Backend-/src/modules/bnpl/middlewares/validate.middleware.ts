// src/middlewares/validate.middleware.ts
import { Request, Response, NextFunction } from "express";

/**
 * Placeholder validation middleware. Use Joi/Zod for real validation.
 */
export function validate(_schema: any) {
  return (_req: Request, _res: Response, next: NextFunction) => {
    // schema: { body: fn, params: fn }
    // For now, pass through
    next();
  };
}
// src/modules/bnpl/validators/tickpay.onboard.validator.ts
export type OnboardPayload = {
  employmentStatus: string;
  employerName?: string;
  monthlySalary?: number;
  incomeFrequency?: string;
  primaryIncomeSrc?: string;
  secondaryIncome?: number;
  bankName?: string;
  accountType?: string;
  monthlyRent?: number;
  monthlyUtilities?: number;
  otherObligations?: number;
  outstandingLoans?: number;
  avgMonthlySpending?: number;
  purpose?: string;
  spendingPrefs?: string;
  agreedTerms: boolean;
  agreedDataSharing: boolean;
  noRecentBankruptcy?: boolean;
};

export function validateOnboardPayload(body: any): { ok: true; data: OnboardPayload } | { ok: false; error: string } {
  if (!body) return { ok: false, error: "Empty body" };
  if (typeof body.agreedTerms !== "boolean" || typeof body.agreedDataSharing !== "boolean") {
    return { ok: false, error: "Must accept terms and data sharing (agreedTerms/agreedDataSharing booleans)" };
  }
  if (!body.employmentStatus || typeof body.employmentStatus !== "string") {
    return { ok: false, error: "employmentStatus is required string" };
  }

  // Basic numeric normalization (optional)
  const normalized = {
    employmentStatus: String(body.employmentStatus),
    employerName: body.employerName ? String(body.employerName) : undefined,
    monthlySalary: typeof body.monthlySalary === "number" ? body.monthlySalary : undefined,
    incomeFrequency: body.incomeFrequency ? String(body.incomeFrequency) : undefined,
    primaryIncomeSrc: body.primaryIncomeSrc ? String(body.primaryIncomeSrc) : undefined,
    secondaryIncome: typeof body.secondaryIncome === "number" ? body.secondaryIncome : undefined,
    bankName: body.bankName ? String(body.bankName) : undefined,
    accountType: body.accountType ? String(body.accountType) : undefined,
    monthlyRent: typeof body.monthlyRent === "number" ? body.monthlyRent : undefined,
    monthlyUtilities: typeof body.monthlyUtilities === "number" ? body.monthlyUtilities : undefined,
    otherObligations: typeof body.otherObligations === "number" ? body.otherObligations : undefined,
    outstandingLoans: typeof body.outstandingLoans === "number" ? body.outstandingLoans : undefined,
    avgMonthlySpending: typeof body.avgMonthlySpending === "number" ? body.avgMonthlySpending : undefined,
    purpose: body.purpose ? String(body.purpose) : undefined,
    spendingPrefs: body.spendingPrefs ? String(body.spendingPrefs) : undefined,
    agreedTerms: Boolean(body.agreedTerms),
    agreedDataSharing: Boolean(body.agreedDataSharing),
    noRecentBankruptcy: typeof body.noRecentBankruptcy === "boolean" ? body.noRecentBankruptcy : undefined,
  };

  return { ok: true, data: normalized };
}
