// src/modules/nft/routes/nft.routes.ts
import { Router } from "express";
import NFTController from "../controllers/nft.controller";

const router = Router();

router.get("/user-nfts", NFTController.getUserNFTs);
router.get("/metadata", NFTController.getNFTMetadata);
router.post("/mint", NFTController.mintNFT);

export default router;
