export class WalletTransactionDto {
  readonly walletId: string;
  readonly amount: number;
  readonly type: 'credit' | 'debit';
  readonly description?: string;
}
