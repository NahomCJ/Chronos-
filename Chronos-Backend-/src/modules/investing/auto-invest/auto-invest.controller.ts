import { Request, Response } from "express";
import { AutoInvestAssetClass, AutoInvestCadence, AutoInvestGoal, AutoInvestRiskProfile } from "@prisma/client";
import autoInvestService, { generateAllocation } from "./auto-invest.service";
import { isAutoInvestApiError } from "./auto-invest.errors";

const RISK_PROFILES = Object.values(AutoInvestRiskProfile);
const GOALS = Object.values(AutoInvestGoal);
const CADENCES = Object.values(AutoInvestCadence);
const ASSET_CLASSES = Object.values(AutoInvestAssetClass);

function getUserId(req: Request): string | undefined {
  return (req as any).user?.id || (req as any).user?.userId || (req as any).user?.sub;
}

function handleError(res: Response, err: unknown) {
  if (isAutoInvestApiError(err)) {
    return res.status(err.status).json({ code: err.code, message: err.message, details: err.details });
  }
  const message = err instanceof Error ? err.message : "Internal server error";
  return res.status(500).json({ code: "AUTO_INVEST_ERROR", message });
}

function isPositiveNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value) && value > 0;
}

function validateRiskProfile(value: unknown): value is AutoInvestRiskProfile {
  return typeof value === "string" && (RISK_PROFILES as string[]).includes(value);
}

function validateGoal(value: unknown): value is AutoInvestGoal {
  return typeof value === "string" && (GOALS as string[]).includes(value);
}

function validateCadence(value: unknown): value is AutoInvestCadence {
  return typeof value === "string" && (CADENCES as string[]).includes(value);
}

function validateAllocations(value: unknown): value is Array<{
  assetClass: AutoInvestAssetClass;
  symbol: string;
  name: string;
  percentage: number;
  rationale?: string;
}> {
  if (!Array.isArray(value) || value.length === 0) return false;
  return value.every(
    (row) =>
      row &&
      typeof row === "object" &&
      typeof row.symbol === "string" &&
      row.symbol.length > 0 &&
      typeof row.name === "string" &&
      row.name.length > 0 &&
      typeof row.percentage === "number" &&
      Number.isFinite(row.percentage) &&
      (ASSET_CLASSES as string[]).includes(row.assetClass) &&
      (row.rationale === undefined || typeof row.rationale === "string"),
  );
}

export class AutoInvestController {
  async allocationPreview(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });

      const { riskProfile, goal, amountUsd } = req.body || {};
      if (!validateRiskProfile(riskProfile)) {
        return res.status(400).json({
          code: "INVALID_RISK_PROFILE",
          message: `riskProfile must be one of: ${RISK_PROFILES.join(", ")}`,
        });
      }
      if (!validateGoal(goal)) {
        return res.status(400).json({ code: "INVALID_GOAL", message: `goal must be one of: ${GOALS.join(", ")}` });
      }
      if (!isPositiveNumber(amountUsd)) {
        return res.status(400).json({ code: "INVALID_AMOUNT", message: "amountUsd must be a positive number." });
      }

      const allocations = generateAllocation(riskProfile, goal, amountUsd);
      return res.json({ riskProfile, goal, amountUsd, allocations });
    } catch (err) {
      return handleError(res, err);
    }
  }

  async createPlan(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });

      const { riskProfile, goal, amountUsd, cadence, allocations } = req.body || {};
      if (!validateRiskProfile(riskProfile)) {
        return res.status(400).json({
          code: "INVALID_RISK_PROFILE",
          message: `riskProfile must be one of: ${RISK_PROFILES.join(", ")}`,
        });
      }
      if (!validateGoal(goal)) {
        return res.status(400).json({ code: "INVALID_GOAL", message: `goal must be one of: ${GOALS.join(", ")}` });
      }
      if (!isPositiveNumber(amountUsd)) {
        return res.status(400).json({ code: "INVALID_AMOUNT", message: "amountUsd must be a positive number." });
      }
      if (!validateCadence(cadence)) {
        return res
          .status(400)
          .json({ code: "INVALID_CADENCE", message: `cadence must be one of: ${CADENCES.join(", ")}` });
      }
      if (!validateAllocations(allocations)) {
        return res.status(400).json({
          code: "INVALID_ALLOCATIONS",
          message:
            "allocations must be a non-empty array of { assetClass, symbol, name, percentage, rationale? } rows.",
        });
      }

      const plan = await autoInvestService.createPlan(userId, {
        riskProfile,
        goal,
        amountUsd,
        cadence,
        allocations,
      });
      return res.status(201).json(plan);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async confirmPlan(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const result = await autoInvestService.confirmPlan(userId, req.params.id as string);
      return res.json(result);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async getActivePlan(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const plan = await autoInvestService.getActivePlan(userId);
      if (!plan) return res.status(404).json({ code: "NO_ACTIVE_PLAN", message: "No active auto-invest plan." });
      return res.json(plan);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async getPlanById(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const plan = await autoInvestService.getPlanById(userId, req.params.id as string);
      return res.json(plan);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async pausePlan(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const plan = await autoInvestService.pausePlan(userId, req.params.id as string);
      return res.json(plan);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async resumePlan(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const plan = await autoInvestService.resumePlan(userId, req.params.id as string);
      return res.json(plan);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async cancelPlan(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const plan = await autoInvestService.cancelPlan(userId, req.params.id as string);
      return res.json(plan);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async triggerNextRound(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const result = await autoInvestService.triggerNextRound(userId, req.params.id as string);
      return res.json(result);
    } catch (err) {
      return handleError(res, err);
    }
  }

  async listExecutions(req: Request, res: Response) {
    try {
      const userId = getUserId(req);
      if (!userId) return res.status(401).json({ code: "UNAUTHORIZED", message: "Unauthorized" });
      const executions = await autoInvestService.listExecutions(userId, req.params.id as string);
      return res.json({ executions });
    } catch (err) {
      return handleError(res, err);
    }
  }
}

export const autoInvestController = new AutoInvestController();
export default autoInvestController;
