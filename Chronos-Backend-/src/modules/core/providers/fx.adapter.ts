// src/modules/core-banking/services/providers/fx.adapter.ts
import type { FxQuoteInput } from "../../types/fx.types";

export type FxQuoteResponse = {
    providerRef: string;
    rate: number;
    buyAmount: number;
    sellAmount: number;
    expiresAt?: string; // ISO timestamp
    raw?: any;
};

export type FxExecuteResponse = {
    providerRef: string;
    status: "EXECUTING" | "FILLED" | "FAILED" | "CANCELED";
    raw?: any;
};

export interface FxAdapter {
    name: string;
    quote(input: FxQuoteInput): Promise<FxQuoteResponse>;
    execute(providerRef: string): Promise<FxExecuteResponse>;
}
