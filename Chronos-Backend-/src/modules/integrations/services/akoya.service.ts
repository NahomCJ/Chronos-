import axios from "axios";
import { AKOYA_API_URL, AKOYA_CLIENT_ID, AKOYA_CLIENT_SECRET } from "../../config/akoya.config";

class AkoyaService {
  private async request(endpoint: string, method: "GET" | "POST" = "GET", data?: any) {
    const headers = {
      "Content-Type": "application/json",
      "Client-ID": AKOYA_CLIENT_ID,
      "Client-Secret": AKOYA_CLIENT_SECRET,
    };

    const url = `${AKOYA_API_URL}/${endpoint}`;

    const response = await axios({ url, method, headers, data });
    return response.data;
  }

  async fetchAccounts(params: { userId: string }) {
    // Example: fetch linked accounts for a user
    return this.request(`users/${params.userId}/accounts`);
  }

  async fetchTransactions(params: { accountId: string; startDate?: string; endDate?: string }) {
    return this.request(`accounts/${params.accountId}/transactions`);
  }

  // Additional Akoya methods can be added here
}

export default new AkoyaService();
