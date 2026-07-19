// src/integrations/integrations.service.ts
// Minimal adapter to call mock providers. Replace with real HTTP clients.
class IntegrationsService {
  async call(provider: string, action: string, _payload: any) {
    
    // Mock behaviors for dev/testing
    if (provider === "akoya") {
      // return a fake credit summary
      if (action === "getAccountDetails") {
        return {
          score: 75,
          lastActivityDays: 2,
          accounts: [],
        };
      }
    }

    if (provider === "moralis") {
      if (action === "getWalletBalance") {
        return { eth: 0.12, usdEstimate: 350 };
      }
    }

    if (provider === "fingpt") {
      if (action === "suggestPurchase") {
        return { approved: true, score: 80, reason: "Good history" };
      }
    }

    return null;
  }
}

export default new IntegrationsService();

