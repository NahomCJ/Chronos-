// src/modules/exchange/exchange.module.ts
import { Router } from "express";
import exchangeRoutes from "./routes/exchange.routes";

const exchangeModule = Router();

exchangeModule.use("/exchange", exchangeRoutes);

export default exchangeModule;
