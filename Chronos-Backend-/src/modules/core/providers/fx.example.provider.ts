// (Optional template) src/modules/core-banking/services/providers/fx.example.provider.ts
import { FxAdapter, FxQuoteResponse, FxExecuteResponse } from "./fx.adapter";
import type { FxQuoteInput } from "../../types/fx.types";

class FxExampleProvider implements FxAdapter {
    name = "fx-example";
    async quote(input: FxQuoteInput): Promise<FxQuoteResponse> {
        // TODO: call provider API with axios using env creds
        return { providerRef: "prov_fx_123", rate: 1.095, buyAmount: 100, sellAmount: 109.5 };
    }
    async execute(providerRef: string): Promise<FxExecuteResponse> {
        return { providerRef, status: "FILLED" };
    }
}

export default new FxExampleProvider();
