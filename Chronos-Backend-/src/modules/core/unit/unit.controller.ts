import { Request, Response } from "express";
import prisma from "../../../config/prisma";
import {
  unitService,
  mapCustomerToProfile,
  mapUnitAccountToResponse,
  mapUnitCardToResponse,
  mapUnitTransferToResponse,
  UnitTransferResult,
} from "../providers/unit/unit.module";

// POST /api/unit/customers
export async function createCustomer(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id as string;
    const input = req.body;

    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) return res.status(404).json({ message: "Banking profile not found" });
    if (profile.unitCustomerId) {
      return res.status(409).json({ message: "Unit customer already exists", unitCustomerId: profile.unitCustomerId });
    }

    const result = await unitService.createIndividualCustomer(input);

    await prisma.bankingProfile.update({
      where: { userId },
      data: mapCustomerToProfile(result),
    });

    return res.status(201).json({ message: "Unit customer created", ...result });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to create Unit customer", error: err.message });
  }
}

// POST /api/unit/accounts
export async function createAccount(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id as string;
    const { depositProduct } = req.body;

    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile?.unitCustomerId) {
      return res.status(400).json({ message: "Unit customer not set up. Call POST /api/unit/customers first." });
    }

    const result = await unitService.createDepositAccount({
      unitCustomerId: profile.unitCustomerId,
      depositProduct,
    });

    await prisma.unitAccount.create({
      data: {
        bankingProfileId: profile.id,
        unitAccountId: result.unitAccountId,
        routingNumber: result.routingNumber,
        accountNumber: result.accountNumber,
        balance: result.balance,
        status: result.status,
      },
    });

    return res.status(201).json({ message: "Unit account created", account: mapUnitAccountToResponse(result) });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to create Unit account", error: err.message });
  }
}

// GET /api/unit/accounts
export async function listAccounts(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id as string;
    const profile = await prisma.bankingProfile.findUnique({
      where: { userId },
      include: { unitAccounts: true },
    });
    if (!profile) return res.status(404).json({ message: "Banking profile not found" });
    return res.json({
      accounts: profile.unitAccounts.map((a) =>
        mapUnitAccountToResponse({
          unitAccountId: a.unitAccountId,
          routingNumber: a.routingNumber,
          accountNumber: a.accountNumber,
          balance: a.balance,
          status: a.status,
        })
      ),
    });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to list accounts", error: err.message });
  }
}

// GET /api/unit/accounts/:unitAccountId
export async function getAccount(req: Request, res: Response) {
  try {
    const unitAccountId = req.params.unitAccountId as string;
    const result = await unitService.getAccount(unitAccountId);
    return res.json({ account: mapUnitAccountToResponse(result) });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to get account", error: err.message });
  }
}

// POST /api/unit/cards
export async function issueCard(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id as string;
    const { unitAccountId, shippingAddress } = req.body;

    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) return res.status(404).json({ message: "Banking profile not found" });

    const result = await unitService.issueDebitCard({ unitAccountId, shippingAddress });

    await prisma.unitCard.create({
      data: {
        bankingProfileId: profile.id,
        unitAccountId,
        unitCardId: result.unitCardId,
        last4: result.last4,
        type: result.type === "individualDebitCard" ? "VIRTUAL" : "PHYSICAL",
        status: result.status,
      },
    });

    return res.status(201).json({ message: "Card issued", card: mapUnitCardToResponse(result) });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to issue card", error: err.message });
  }
}

// GET /api/unit/cards
export async function listCards(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id as string;
    const profile = await prisma.bankingProfile.findUnique({
      where: { userId },
      include: { unitCards: true },
    });
    if (!profile) return res.status(404).json({ message: "Banking profile not found" });
    return res.json({
      cards: profile.unitCards.map((c) =>
        mapUnitCardToResponse({
          unitCardId: c.unitCardId,
          last4: c.last4,
          status: c.status,
          type: c.type,
        })
      ),
    });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to list cards", error: err.message });
  }
}

// POST /api/unit/cards/:unitCardId/freeze
export async function freezeCard(req: Request, res: Response) {
  try {
    const unitCardId = req.params.unitCardId as string;
    await unitService.freezeCard(unitCardId);
    await prisma.unitCard.updateMany({ where: { unitCardId }, data: { status: "frozen" } });
    return res.json({ message: "Card frozen" });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to freeze card", error: err.message });
  }
}

// POST /api/unit/cards/:unitCardId/unfreeze
export async function unfreezeCard(req: Request, res: Response) {
  try {
    const unitCardId = req.params.unitCardId as string;
    await unitService.unfreezeCard(unitCardId);
    await prisma.unitCard.updateMany({ where: { unitCardId }, data: { status: "active" } });
    return res.json({ message: "Card unfrozen" });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to unfreeze card", error: err.message });
  }
}

// POST /api/unit/transfers
export async function createTransfer(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id as string;
    const input = req.body;

    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) return res.status(404).json({ message: "Banking profile not found" });

    const result = await unitService.createTransfer(input);

    await prisma.unitTransfer.create({
      data: {
        bankingProfileId: profile.id,
        unitAccountId: input.fromUnitAccountId as string,
        unitTransferId: result.unitTransferId,
        type: input.type as string,
        direction: (input.direction ?? "Debit") as string,
        amount: result.amount,
        description: input.description as string | undefined,
        status: result.status,
      },
    });

    return res.status(201).json({ message: "Transfer initiated", transfer: mapUnitTransferToResponse(result) });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to create transfer", error: err.message });
  }
}

// GET /api/unit/transfers
export async function listTransfers(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id as string;
    const profile = await prisma.bankingProfile.findUnique({
      where: { userId },
      include: { unitTransfers: true },
    });
    if (!profile) return res.status(404).json({ message: "Banking profile not found" });
    return res.json({
      transfers: profile.unitTransfers.map((t) =>
        mapUnitTransferToResponse({
          unitTransferId: t.unitTransferId,
          status: t.status,
          amount: t.amount,
          createdAt: t.createdAt.toISOString(),
        } as UnitTransferResult)
      ),
    });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to list transfers", error: err.message });
  }
}

// GET /api/unit/accounts/:unitAccountId/transactions
export async function listUnitTransactions(req: Request, res: Response) {
  try {
    const unitAccountId = req.params.unitAccountId as string;
    const limit = Number(Array.isArray(req.query.limit) ? req.query.limit[0] : req.query.limit ?? 20);
    const txns = await unitService.listTransactionsByAccount(unitAccountId, limit);
    return res.json({ transactions: txns });
  } catch (err: any) {
    return res.status(500).json({ message: "Failed to list transactions", error: err.message });
  }
}
