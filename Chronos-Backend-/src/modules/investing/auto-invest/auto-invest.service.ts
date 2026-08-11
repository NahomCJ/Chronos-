import Decimal from "decimal.js";
import {
  AutoInvestAssetClass,
  AutoInvestCadence,
  AutoInvestExecution,
  AutoInvestGoal,
  AutoInvestPlanStatus,
  AutoInvestRiskProfile,
} from "@prisma/client";
import prisma from "../../../models/prisma";
import cryptoService from "../../crypto/services/crypto.service";
import { SUPPORTED_CRYPTO_ASSETS, SupportedCryptoAsset } from "../../crypto/services/crypto.paxos.service";
import { AutoInvestApiError } from "./auto-invest.errors";

// ============================================
// Allocation generation (pure, deterministic — no ML)
// ============================================

interface AssetClassWeights {
  crypto: number;
  stock: number;
  etf: number;
}

// Base asset-class weights by risk profile (percent of total plan).
const BASE_WEIGHTS: Record<AutoInvestRiskProfile, AssetClassWeights> = {
  CONSERVATIVE: { crypto: 10, stock: 30, etf: 60 },
  BALANCED: { crypto: 20, stock: 40, etf: 40 },
  AGGRESSIVE: { crypto: 35, stock: 45, etf: 20 },
};

// Goals with a shorter horizon shift weight out of crypto and into ETFs.
const GOAL_SHIFT_GOALS: AutoInvestGoal[] = ["SHORT_TERM", "RETIREMENT"];
const GOAL_SHIFT_PCT = 10;
const CRYPTO_FLOOR_PCT = 5;

interface SleeveAsset {
  symbol: string;
  name: string;
  weight: number; // percent of its sleeve, not of the total plan
  rationale: string;
}

// Stock sleeve is planned-only — no brokerage integration exists in this codebase.
const STOCK_SLEEVE: SleeveAsset[] = [
  { symbol: "AAPL", name: "Apple Inc.", weight: 25, rationale: "Blue-chip consumer tech exposure." },
  {
    symbol: "MSFT",
    name: "Microsoft Corporation",
    weight: 25,
    rationale: "Cloud and enterprise software leadership.",
  },
  {
    symbol: "AMZN",
    name: "Amazon.com, Inc.",
    weight: 25,
    rationale: "E-commerce and cloud infrastructure exposure.",
  },
  {
    symbol: "GOOGL",
    name: "Alphabet Inc. (Class A)",
    weight: 25,
    rationale: "Search, advertising, and AI platform leadership.",
  },
];

// ETF sleeve is planned-only — no brokerage integration exists in this codebase.
const ETF_SLEEVE: SleeveAsset[] = [
  {
    symbol: "VOO",
    name: "Vanguard S&P 500 ETF",
    weight: 50,
    rationale: "Core U.S. equity exposure for long-term growth.",
  },
  {
    symbol: "VTI",
    name: "Vanguard Total Stock Market ETF",
    weight: 30,
    rationale: "Broad U.S. total-market diversification.",
  },
  {
    symbol: "QQQ",
    name: "Invesco QQQ Trust",
    weight: 20,
    rationale: "Concentrated exposure to large-cap tech growth.",
  },
];

const CRYPTO_ASSET_NAMES: Record<string, string> = {
  BTC: "Bitcoin",
  ETH: "Ethereum",
  SOL: "Solana",
  UNI: "Uniswap",
  AAVE: "Aave",
  LINK: "Chainlink",
};

const CRYPTO_ASSET_RATIONALES: Record<string, string> = {
  BTC: "Bitcoin for high-growth, high-liquidity diversification.",
  ETH: "Ethereum for smart-contract platform growth.",
  SOL: "Solana for high-throughput smart-contract exposure.",
  UNI: "Uniswap for decentralized-exchange sector exposure.",
  AAVE: "Aave for decentralized-lending sector exposure.",
  LINK: "Chainlink for oracle/infrastructure sector exposure.",
};

/**
 * The crypto sleeve only ever contains assets the live Paxos trading pipeline
 * actually supports (`SUPPORTED_CRYPTO_ASSETS`). We prefer BTC/ETH (the two
 * majors) at 60/40 within the sleeve; if the live pipeline ever stops
 * supporting one of them, fall back to whatever the first two supported
 * assets actually are instead of hardcoding symbols that would fail to trade.
 */
function resolveCryptoSleeve(): SleeveAsset[] {
  const preferredMajors = (["BTC", "ETH"] as const).filter((asset) =>
    (SUPPORTED_CRYPTO_ASSETS as readonly string[]).includes(asset),
  ) as SupportedCryptoAsset[];

  const majors: SupportedCryptoAsset[] =
    preferredMajors.length === 2 ? preferredMajors : SUPPORTED_CRYPTO_ASSETS.slice(0, 2);

  const weights = [60, 40];
  return majors.map((symbol, index) => ({
    symbol,
    name: CRYPTO_ASSET_NAMES[symbol] || symbol,
    weight: weights[index],
    rationale: CRYPTO_ASSET_RATIONALES[symbol] || `${symbol} for crypto diversification.`,
  }));
}

export interface GeneratedAllocation {
  assetClass: AutoInvestAssetClass;
  symbol: string;
  name: string;
  /** Share of the TOTAL plan amount, 0-100. */
  percentage: number;
  /** Dollar amount within the total plan amountUsd (derived, not persisted). */
  amountUsd: number;
  rationale: string;
}

export function generateAllocation(
  riskProfile: AutoInvestRiskProfile,
  goal: AutoInvestGoal,
  amountUsd: number,
): GeneratedAllocation[] {
  const base = BASE_WEIGHTS[riskProfile];
  let cryptoWeight = base.crypto;
  let stockWeight = base.stock;
  let etfWeight = base.etf;

  if (GOAL_SHIFT_GOALS.includes(goal)) {
    const shift = Math.min(GOAL_SHIFT_PCT, cryptoWeight - CRYPTO_FLOOR_PCT);
    if (shift > 0) {
      cryptoWeight -= shift;
      etfWeight += shift;
    }
  }

  const total = new Decimal(amountUsd);
  const rows: GeneratedAllocation[] = [];

  const pushRow = (assetClass: AutoInvestAssetClass, asset: SleeveAsset, sleeveWeight: number) => {
    const percentage = new Decimal(sleeveWeight).mul(asset.weight).div(100);
    rows.push({
      assetClass,
      symbol: asset.symbol,
      name: asset.name,
      percentage: percentage.toDecimalPlaces(2).toNumber(),
      amountUsd: total.mul(percentage).div(100).toDecimalPlaces(2).toNumber(),
      rationale: asset.rationale,
    });
  };

  for (const asset of resolveCryptoSleeve()) pushRow("CRYPTO", asset, cryptoWeight);
  for (const asset of STOCK_SLEEVE) pushRow("STOCK", asset, stockWeight);
  for (const asset of ETF_SLEEVE) pushRow("ETF", asset, etfWeight);

  return rows;
}

// ============================================
// Cadence helpers
// ============================================

const CADENCE_DAYS: Record<AutoInvestCadence, number | null> = {
  ONE_TIME: null,
  WEEKLY: 7,
  BIWEEKLY: 14,
  MONTHLY: 30,
};

function computeNextRoundAt(cadence: AutoInvestCadence): Date | null {
  const days = CADENCE_DAYS[cadence];
  if (days === null) return null;
  const next = new Date();
  next.setDate(next.getDate() + days);
  return next;
}

// ============================================
// Plan CRUD + round execution
// ============================================

interface CreatePlanAllocationInput {
  assetClass: AutoInvestAssetClass;
  symbol: string;
  name: string;
  percentage: number;
  rationale?: string;
}

interface CreatePlanInput {
  riskProfile: AutoInvestRiskProfile;
  goal: AutoInvestGoal;
  amountUsd: number;
  cadence: AutoInvestCadence;
  allocations: CreatePlanAllocationInput[];
}

const PLAN_INCLUDE = {
  allocations: true,
  executions: { orderBy: { executedAt: "desc" as const } },
};

async function createPlan(userId: string, input: CreatePlanInput) {
  return prisma.autoInvestPlan.create({
    data: {
      userId,
      riskProfile: input.riskProfile,
      goal: input.goal,
      amountUsd: input.amountUsd,
      cadence: input.cadence,
      status: "PENDING_CONFIRMATION",
      allocations: {
        create: input.allocations.map((allocation) => ({
          assetClass: allocation.assetClass,
          symbol: allocation.symbol,
          name: allocation.name,
          percentage: allocation.percentage,
          rationale: allocation.rationale,
        })),
      },
    },
    include: PLAN_INCLUDE,
  });
}

async function getActivePlan(userId: string) {
  return prisma.autoInvestPlan.findFirst({
    where: { userId, status: { notIn: ["CANCELLED", "COMPLETED"] } },
    orderBy: { createdAt: "desc" },
    include: PLAN_INCLUDE,
  });
}

async function requireOwnedPlan(userId: string, planId: string) {
  const plan = await prisma.autoInvestPlan.findUnique({ where: { id: planId } });
  if (!plan) throw new AutoInvestApiError("PLAN_NOT_FOUND", "Auto-invest plan not found.", 404);
  if (plan.userId !== userId) {
    throw new AutoInvestApiError("FORBIDDEN", "This plan does not belong to you.", 403);
  }
  return plan;
}

async function getPlanById(userId: string, planId: string) {
  await requireOwnedPlan(userId, planId);
  return prisma.autoInvestPlan.findUnique({ where: { id: planId }, include: PLAN_INCLUDE });
}

async function pausePlan(userId: string, planId: string) {
  const plan = await requireOwnedPlan(userId, planId);
  if (plan.status !== "ACTIVE") {
    throw new AutoInvestApiError(
      "INVALID_PLAN_STATUS",
      `Plan must be ACTIVE to pause (current: ${plan.status}).`,
      400,
    );
  }
  return prisma.autoInvestPlan.update({
    where: { id: planId },
    data: { status: "PAUSED" },
    include: PLAN_INCLUDE,
  });
}

async function resumePlan(userId: string, planId: string) {
  const plan = await requireOwnedPlan(userId, planId);
  if (plan.status !== "PAUSED") {
    throw new AutoInvestApiError(
      "INVALID_PLAN_STATUS",
      `Plan must be PAUSED to resume (current: ${plan.status}).`,
      400,
    );
  }
  return prisma.autoInvestPlan.update({
    where: { id: planId },
    data: { status: "ACTIVE" },
    include: PLAN_INCLUDE,
  });
}

async function cancelPlan(userId: string, planId: string) {
  await requireOwnedPlan(userId, planId);
  return prisma.autoInvestPlan.update({
    where: { id: planId },
    data: { status: "CANCELLED" },
    include: PLAN_INCLUDE,
  });
}

async function listExecutions(userId: string, planId: string) {
  await requireOwnedPlan(userId, planId);
  return prisma.autoInvestExecution.findMany({
    where: { planId },
    orderBy: { executedAt: "desc" },
  });
}

/**
 * Executes one investment round for a plan: for each CRYPTO allocation, calls
 * the existing live Paxos buy pipeline (compliance/KYC/balance checks stay
 * intact because we call it as-is); for each STOCK/ETF allocation, records a
 * PLANNED execution only (no brokerage integration exists). A failed crypto
 * leg is recorded as FAILED and does not stop the remaining legs.
 */
async function executeRound(userId: string, planId: string, allowedStatuses: AutoInvestPlanStatus[]) {
  const plan = await prisma.autoInvestPlan.findUnique({
    where: { id: planId },
    include: { allocations: true },
  });
  if (!plan) throw new AutoInvestApiError("PLAN_NOT_FOUND", "Auto-invest plan not found.", 404);
  if (plan.userId !== userId) {
    throw new AutoInvestApiError("FORBIDDEN", "This plan does not belong to you.", 403);
  }
  if (!allowedStatuses.includes(plan.status)) {
    throw new AutoInvestApiError(
      "INVALID_PLAN_STATUS",
      `Plan must be ${allowedStatuses.join(" or ")} to execute a round (current: ${plan.status}).`,
      400,
    );
  }

  const roundNumber = plan.roundsCompleted + 1;
  const planAmountUsd = new Decimal(plan.amountUsd.toString());
  const executions: AutoInvestExecution[] = [];

  for (const allocation of plan.allocations) {
    const legAmountUsd = planAmountUsd.mul(allocation.percentage.toString()).div(100);

    if (allocation.assetClass === "CRYPTO") {
      try {
        const result = await cryptoService.buy(userId, {
          asset: allocation.symbol,
          amount_usd: legAmountUsd.toDecimalPlaces(2).toNumber(),
        });
        executions.push(
          await prisma.autoInvestExecution.create({
            data: {
              planId: plan.id,
              roundNumber,
              assetClass: "CRYPTO",
              symbol: allocation.symbol,
              amountUsd: legAmountUsd.toFixed(2),
              status: "EXECUTED",
              tradeId: result.trade_id,
            },
          }),
        );
      } catch (err) {
        const failureReason = err instanceof Error ? err.message : "Crypto buy failed.";
        executions.push(
          await prisma.autoInvestExecution.create({
            data: {
              planId: plan.id,
              roundNumber,
              assetClass: "CRYPTO",
              symbol: allocation.symbol,
              amountUsd: legAmountUsd.toFixed(2),
              status: "FAILED",
              failureReason,
            },
          }),
        );
      }
    } else {
      // STOCK / ETF — no brokerage integration exists. Planned only.
      executions.push(
        await prisma.autoInvestExecution.create({
          data: {
            planId: plan.id,
            roundNumber,
            assetClass: allocation.assetClass,
            symbol: allocation.symbol,
            amountUsd: legAmountUsd.toFixed(2),
            status: "PLANNED",
          },
        }),
      );
    }
  }

  const isOneTime = plan.cadence === "ONE_TIME";
  const updatedPlan = await prisma.autoInvestPlan.update({
    where: { id: plan.id },
    data: {
      roundsCompleted: roundNumber,
      status: isOneTime ? "COMPLETED" : "ACTIVE",
      nextRoundAt: isOneTime ? null : computeNextRoundAt(plan.cadence),
    },
    include: PLAN_INCLUDE,
  });

  return { plan: updatedPlan, executions };
}

async function confirmPlan(userId: string, planId: string) {
  return executeRound(userId, planId, ["PENDING_CONFIRMATION"]);
}

async function triggerNextRound(userId: string, planId: string) {
  return executeRound(userId, planId, ["ACTIVE"]);
}

export const autoInvestService = {
  generateAllocation,
  createPlan,
  getActivePlan,
  getPlanById,
  pausePlan,
  resumePlan,
  cancelPlan,
  listExecutions,
  confirmPlan,
  triggerNextRound,
};

export default autoInvestService;
