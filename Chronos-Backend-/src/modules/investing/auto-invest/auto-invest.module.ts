import { Router } from "express";
import autoInvestRoutes from "./auto-invest.routes";

// Mounted at "/v1/auto-invest" (same level as the "/v1/crypto" mount in
// src/routes/index.ts) so the full path resolves to /api/v1/auto-invest/...
export const AutoInvestModule = (router: Router) => {
  router.use("/v1/auto-invest", autoInvestRoutes);
};

export default AutoInvestModule;
