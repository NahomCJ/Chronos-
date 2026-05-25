import { Request, Response } from "express";
import * as svc from "../services/loans.service";


export const linkManual = async (req: Request, res: Response) => {
const userId = (req as any).user?.id;
if (!userId) return res.status(401).json({ error: "Unauthorized" });
const payload = { ...req.body, userId };
const loan = await svc.linkLoanManual(payload);
res.status(201).json(loan);
};


export const list = async (req: Request, res: Response) => {
const userId = (req as any).user?.id;
if (!userId) return res.status(401).json({ error: "Unauthorized" });
const loans = await svc.listLoansForUser(userId);
res.json(loans);
};


export const repay = async (req: Request, res: Response) => {
const { amount } = req.body;
try {
const r = await svc.recordRepayment(req.params.id, Number(amount));
res.json(r);
} catch (err: any) {
res.status(400).json({ error: err.message });
}
};


export const schedule = async (req: Request, res: Response) => {
const s = svc.getAmortizationSchedule(req.params.id);
res.json(s);
};