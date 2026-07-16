// src/core/deposit/deposit.types.ts

export interface CreateDepositDTO {
  walletId: string
  amount: number
  currency: string
  reference?: string
  note?: string
  source?: string // e.g., "BANK", "CARD", "CRYPTO"
}