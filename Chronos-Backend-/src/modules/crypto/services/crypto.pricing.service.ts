import paxos from "./crypto.paxos.service";

export class CryptoPricingService {
  async getPrice(asset: string) {
    return paxos.getMarketPrice(asset);
  }

  async getAllPrices() {
    return paxos.getAllMarketPrices();
  }
}

export const cryptoPricingService = new CryptoPricingService();
export default cryptoPricingService;
