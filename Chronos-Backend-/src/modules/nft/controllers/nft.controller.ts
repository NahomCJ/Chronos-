// src/modules/nft/controllers/nft.controller.ts
import { Request, Response } from "express";
import NFTService from "../services/nft.service";

export class NFTController {
  async getUserNFTs(req: Request, res: Response) {
    try {
      const { address, chain } = req.query;
      if (!address) return res.status(400).json({ error: "Wallet address is required" });

      const nfts = await NFTService.getUserNFTs(address as string, (chain as string) || "eth");
      res.json({ nfts });
    } catch (err: any) {
      res.status(500).json({ error: err.message });
    }
  }

  async getNFTMetadata(req: Request, res: Response) {
    try {
      const { tokenAddress, tokenId, chain } = req.query;
      if (!tokenAddress || !tokenId)
        return res.status(400).json({ error: "tokenAddress & tokenId are required" });

      const metadata = await NFTService.getNFTMetadata(
        tokenAddress as string,
        tokenId as string,
        (chain as string) || "eth"
      );
      res.json({ metadata });
    } catch (err: any) {
      res.status(500).json({ error: err.message });
    }
  }

  async mintNFT(req: Request, res: Response) {
    try {
      const { toAddress, metadataUri, chain } = req.body;
      if (!toAddress || !metadataUri)
        return res.status(400).json({ error: "toAddress & metadataUri are required" });

      const mint = await NFTService.mintNFT(toAddress, metadataUri, chain || "eth");
      res.json({ mint });
    } catch (err: any) {
      res.status(500).json({ error: err.message });
    }
  }
}

export default new NFTController();
