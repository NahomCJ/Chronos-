export interface CreateTransferDTO {
  fromWalletId: string
  toWalletId?: string      // optional for external
  toExternal?: { bank: string; account: string } // optional external
  amount: number
  currency: string
  note?: string
  reference?: string
}