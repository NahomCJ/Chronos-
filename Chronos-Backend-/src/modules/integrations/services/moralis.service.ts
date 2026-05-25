import axios, { AxiosError } from "axios";
import { MORALIS_API_KEY, MORALIS_API_URL } from "../../config/moralis.config";
import { Chain, mapNativeBalance, mapNFTs, mapTokenBalances } from "../dto/moralis.dto";

function headers() {
  if (!MORALIS_API_KEY) throw new Error("Moralis API key missing");
  return { "X-API-Key": MORALIS_API_KEY, "Content-Type": "application/json" };
}

async function get(url: string) {
  try {
    const res = await axios.get(url, { headers: headers(), timeout: 12000 });
    return res.data;
  } catch (e) {
    const err = e as AxiosError;
    const msg = (err.response?.data as any)?.message || err.message;
    throw new Error(`Moralis GET failed: ${msg}`);
  }
}

class MoralisService {
  // Native balance (ETH, MATIC, etc.)
  async getNativeBalance(params: { address: string; chain: Chain }) {
    const url = `${MORALIS_API_URL}/${params.address}/balance?chain=${params.chain}`;
    const data = await get(url);
    return mapNativeBalance(data, params.address, params.chain);
  }

  // ERC20 balances
  async getTokenBalances(params: { address: string; chain: Chain }) {
    const url = `${MORALIS_API_URL}/${params.address}/erc20?chain=${params.chain}`;
    const data = await get(url);
    return mapTokenBalances(data);
  }

  // NFTs
  async getNFTs(params: { address: string; chain: Chain }) {
    const url = `${MORALIS_API_URL}/nft/${params.address}?chain=${params.chain}`;
    const data = await get(url);
    return mapNFTs(data);
  }

  // Token transfers (placeholder — implement with Moralis EVM endpoints if needed)
  async getTokenTransfers(params: { address: string; chain: Chain }) {
    const url = `${MORALIS_API_URL}/${params.address}?chain=${params.chain}`;
    const data = await get(url);
    return data;
  }
}

export default new MoralisService();
