export type Chain = "eth" | "polygon" | "bsc" | "avalanche" | "arbitrum" | "base";

export type WalletBalanceDTO = {
  address: string;
  chain: Chain;
  nativeBalanceWei: string;
  nativeBalance: string; // in ETH/MATIC/…
};

export type TokenBalanceDTO = {
  tokenAddress: string;
  symbol: string;
  name: string;
  decimals: number;
  balance: string;        // raw
  normalizedBalance: string;
};

export type NFTDTO = {
  tokenAddress: string;
  tokenId: string;
  contractType: string;
  name?: string;
  symbol?: string;
  metadata?: any;
};

export function mapNativeBalance(resp: any, address: string, chain: Chain): WalletBalanceDTO {
  const wei = resp?.balance?.toString?.() ?? resp?.balance ?? "0";
  const nativeBalance = (Number(wei) / 1e18).toString();
  return { address, chain, nativeBalanceWei: wei, nativeBalance };
}

export function mapTokenBalances(resp: any): TokenBalanceDTO[] {
  const list = Array.isArray(resp) ? resp : resp?.result || [];
  return list.map((t: any) => ({
    tokenAddress: t.token_address,
    symbol: t.symbol,
    name: t.name,
    decimals: Number(t.decimals ?? 18),
    balance: t.balance ?? "0",
    normalizedBalance: (Number(t.balance ?? 0) / Math.pow(10, Number(t.decimals ?? 18))).toString(),
  }));
}

export function mapNFTs(resp: any): NFTDTO[] {
  const list = Array.isArray(resp) ? resp : resp?.result || [];
  return list.map((n: any) => ({
    tokenAddress: n.token_address,
    tokenId: n.token_id,
    contractType: n.contract_type,
    name: n.name,
    symbol: n.symbol,
    metadata: parseSafe(n.metadata),
  }));
}

function parseSafe(x: any) { try { return typeof x === "string" ? JSON.parse(x) : x; } catch { return x; } }
