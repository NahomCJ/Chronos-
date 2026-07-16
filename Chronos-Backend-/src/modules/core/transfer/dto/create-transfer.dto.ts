// src/core/transfer/dto/create-transfer.dto.ts
export type TransferType = "INTERNAL" | "EXTERNAL" | "P2P";

export interface CreateTransferDto {
    type: TransferType;
    fromAccountId: string;
    // either toAccountId (internal/p2p) OR toExternal (external bank details)
    toAccountId?: string | null;
    toExternal?: Record<string, any> | null;
    amount: string; // use string to preserve precision
    currency: string;
    note?: string;
    reference?: string; // idempotency key / client reference
    metadata?: Record<string, any>;
}
