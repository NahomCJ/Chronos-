// src/modules/core-banking/services/providers/fx.mock.provider.ts
import { FxAdapter, FxQuoteResponse, FxExecuteResponse } from "./fx.adapter";
import type { FxQuoteInput } from "../../types/fx.types";

class FxMockProvider implements FxAdapter {
    name = "fx-mock";

    async quote(input: FxQuoteInput): Promise<FxQuoteResponse> {
        // Fake rate
        const rate = input.buyCurrency === input.sellCurrency ? 1 : 1.1;
        const providerRef = "fxmock_" + Math.random().toString(36).slice(2);

        const buyAmount =
            input.amountType === "BUY" ? input.amount : Number((input.amount / rate).toFixed(6));
        const sellAmount =
            input.amountType === "SELL" ? input.amount : Number((input.amount * rate).toFixed(6));

        const expiresAt = new Date(Date.now() + 5 * 60 * 1000).toISOString();

        return { providerRef, rate, buyAmount, sellAmount, expiresAt, raw: { input } };
    }

    async execute(providerRef: string): Promise<FxExecuteResponse> {
        // Randomly succeed
        const ok = Math.random() > 0.1;
        return { providerRef, status: ok ? "FILLED" : "FAILED" };
    }
}

export default new FxMockProvider();
