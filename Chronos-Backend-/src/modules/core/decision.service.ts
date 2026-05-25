// src/modules/core-banking/services/decision.service.ts
import Integrations from "../../../integrations/integrations.service";

export class DecisionService {
    // Very simple example: pull last 90d transactions & compute a soft max
    async getMaxTransferForUser(userId: string, currency = "USD"): Promise<number> {
        try {
            const accounts = await Integrations.call("akoya", "fetchAccounts", { userId });
            const primary = Array.isArray(accounts) ? accounts[0] : accounts?.accounts?.[0];
            if (!primary) return 0;

            const tx = await Integrations.call("akoya", "fetchTransactions", { accountId: primary.id });
            // Example heuristic: average of credits last 3 months * 0.5
            const credits = (tx?.transactions || tx || [])
                .filter((t: any) => t.amount > 0 && t.currency === currency);
            const sum = credits.reduce((a: number, c: any) => a + Number(c.amount || 0), 0);
            const avg = credits.length ? sum / credits.length : 0;
            return Math.max(0, Math.round(avg * 0.5 * 100) / 100);
        } catch {
            return 0;
        }
    }
}

export default new DecisionService();
