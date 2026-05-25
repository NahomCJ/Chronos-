// src/modules/core-banking/services/providers/baas.mock.provider.ts
import { BaaSAdapter, ProviderTransferResponse } from "./baas.adapter";
import type { InitiateTransferInput } from "../../types/transfer.types";

class MockProvider implements BaaSAdapter {
    name = "mock";

    async initiateTransfer(input: InitiateTransferInput): Promise<ProviderTransferResponse> {
        // Simulate latency & success
        const id = "mock_" + Math.random().toString(36).slice(2);
        return { id, status: "PROCESSING", raw: { echo: input } };
    }

    async getTransferStatus(providerRef: string): Promise<ProviderTransferResponse> {
        // Randomly complete
        const done = Math.random() > 0.3;
        return { id: providerRef, status: done ? "COMPLETED" : "PROCESSING" };
    }
}

export default new MockProvider();
