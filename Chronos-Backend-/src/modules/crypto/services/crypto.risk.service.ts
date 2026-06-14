import prisma from "../../../models/prisma";
import { CryptoApiError } from "./crypto.errors";

export class CryptoRiskService {
  async assertKycCleared(userId: string) {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile?.kycVerified || profile.status !== "APPROVED") {
      throw new CryptoApiError("KYC_NOT_VERIFIED", "KYC approval is required before crypto trading.", 403);
    }
  }

  async assertAmlOk(_userId: string, base: string, quote: string) {
    const blocked = ["XMR", "ZEC"];
    if (blocked.includes(base.toUpperCase()) || blocked.includes(quote.toUpperCase())) {
      throw new CryptoApiError("ASSET_RESTRICTED", "Asset restricted by AML policy.", 403);
    }
  }
}

export const cryptoRiskService = new CryptoRiskService();
export default cryptoRiskService;
