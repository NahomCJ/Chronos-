export interface Wallet {
  userId: string;
  type: string;
  balance: number;
  currency: string;
  transactions: any[];
}
