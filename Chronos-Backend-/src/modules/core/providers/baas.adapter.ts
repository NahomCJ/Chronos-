// src/modules/core-banking/services/providers/baas.adapter.ts
import type { InitiateTransferInput } from "../../types/transfer.types";

export type ProviderTransferResponse = {
    id: string;                  // provider reference id
    status: "PENDING" | "PROCESSING" | "COMPLETED" | "FAILED" | "CANCELED";
    raw?: any;
};

export interface BaaSAdapter {
    name: string;
    initiateTransfer(input: InitiateTransferInput): Promise<ProviderTransferResponse>;
    getTransferStatus(providerRef: string): Promise<ProviderTransferResponse>;
    // Optional: FX, quote, accounts, etc.
}
