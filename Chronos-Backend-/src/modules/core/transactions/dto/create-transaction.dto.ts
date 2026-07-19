export class CreateTransactionDto {
    readonly fromWalletId: string;
    readonly toWalletId: string;
    readonly amount: number;
    readonly currency: string;
    readonly type: string;
    readonly description?: string;
}
