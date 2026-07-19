export interface Transaction {
    fromWalletId: string;
    toWalletId: string;
    amount: number;
    currency: string;
    type: string;
    description?: string;
}
