// src/modules/nft/services/nft.service.ts
import Moralis, { initMoralis } from "../integrations/moralis.client";

export class NFTService {
  constructor() {
    initMoralis(); // ensure Moralis is initialized
  }

  // Fetch NFTs for a wallet address
  async getUserNFTs(address: string, chain: string = "eth") {
    const response = await Moralis.EvmApi.nft.getWalletNFTs({
      address,
      chain,
    });
    return response.result;
  }

  // Get NFT metadata by token address & token ID
  async getNFTMetadata(tokenAddress: string, tokenId: string, chain: string = "eth") {
    const response = await Moralis.EvmApi.nft.getNFTMetadata({
      address: tokenAddress,
      tokenId,
      chain,
    });
    return response.result;
  }

  // Create/mint NFT (optional for your marketplace)
  async mintNFT(toAddress: string, metadataUri: string, chain: string = "eth") {
    const response = await Moralis.EvmApi.nft.mintNFT({
      to: toAddress,
      metadataUri,
      chain,
    });
    return response.result;
  }
}

export default new NFTService();
