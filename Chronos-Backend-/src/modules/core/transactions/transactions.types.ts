export interface TransactionQuery {
  type?: string
  status?: string
  direction?: string       // CREDIT | DEBIT
  walletId?: string
  currency?: string
  search?: string          // matches reference
  fromDate?: string        // ISO date string
  toDate?: string          // ISO date string
  minAmount?: number
  maxAmount?: number
  page?: number
  limit?: number
}
