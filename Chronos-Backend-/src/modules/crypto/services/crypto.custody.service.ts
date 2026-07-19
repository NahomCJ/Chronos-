import prisma from "../../../models/prisma";
import cryptoService from "./crypto.service";

export class CryptoCustodyService {
  async ensureWallet(userId: string) {
    return cryptoService.ensureWalletForUser(userId);
  }

  async getWallet(userId: string) {
    return prisma.cryptoWallet.findUnique({ where: { userId } });
  }
}

export const cryptoCustodyService = new CryptoCustodyService();
export default cryptoCustodyService;
