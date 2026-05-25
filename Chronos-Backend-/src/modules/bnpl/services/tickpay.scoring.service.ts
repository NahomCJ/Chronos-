// src/services/tickpay.scoring.service.ts
// Small rule-based scoring for v1. Replace with ML/FinGPT later.

import IntegrationsService from "../utils/integrations.stub";

type Decision = { approved: boolean; reason?: string; score?: number; recommendedLimit?: number };

class ScoringService {
  async approvePurchase(userId: string, amount: number): Promise<Decision> {
    // call Akoya (or mock)
    const report = await IntegrationsService.call("akoya", "getAccountDetails", { userId }).catch(() => null);
    const score = report?.score ?? 50;

    // simple rule: require score >= 40 and amount <= recommendedLimit
    const recommendedLimit = Math.max(100, (score / 100) * 1000); // example
    const approved = score >= 40 && amount <= recommendedLimit;

    return {
      approved,
      reason: approved ? "OK" : "Score too low or amount exceeds recommended limit",
      score,
      recommendedLimit,
    };
  }
}

export default new ScoringService();
