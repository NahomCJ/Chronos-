// src/core/bill/bill.types.ts

/**
 * Bill record structure
 */
export interface BillPaymentDTO {
  userId: string;           // from JWT, do not provide manually
  provider: string;         // e.g., "Electricity", "Water", "Internet"
  amount: number;           // bill amount
  reference?: string;       // optional external reference
  timestamp?: Date;         // optional, default to now if not provided
}

/**
 * Full Bill response (includes DB ID)
 */
export interface BillPayment extends BillPaymentDTO {
  id: string;               // Prisma-generated ID
  createdAt: Date;
  updatedAt: Date;
}
export interface BillPaymentDTO {
  providerId: string;
  amount: number;
}


