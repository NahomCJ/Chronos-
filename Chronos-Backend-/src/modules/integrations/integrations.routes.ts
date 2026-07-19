// src/integrations/integrations.routes.ts
import { Router } from "express";
import IntegrationsController from "./integrations.controller";

const router = Router();

/**
 * Unified integration call endpoint
 * Expects body:
 * {
 *   service: "akoya" | "moralis" | "fingpt",
 *   method: string,
 *   params: object
 * }
 */
router.post("/call", IntegrationsController.callIntegration);

export default router;
