// src/modules/exchange/routes/exchange.routes.ts
import { Router } from "express";
import { ExchangeController } from "../controllers/exchange.controller";

const router = Router();
const exchangeController = new ExchangeController();

router.post("/rate", exchangeController.createRate.bind(exchangeController));
router.get("/rate/:baseCurrency/:targetCurrency", exchangeController.getRate.bind(exchangeController));
router.post("/exchange", exchangeController.exchange.bind(exchangeController));

export default router;
