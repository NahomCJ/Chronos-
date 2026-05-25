import { Request, Response } from "express";
import * as svc from "../services/tutors.service";


export const list = async (req: Request, res: Response) => {
const tutors = await svc.listTutors({ subject: req.query.subject as string, minRating: req.query.minRating ? Number(req.query.minRating) : undefined });
res.json(tutors);
};


export const detail = async (req: Request, res: Response) => {
const t = await svc.getTutor(req.params.id);
if (!t) return res.status(404).json({ error: "Not found" });
res.json(t);
};


export const create = async (req: Request, res: Response) => {
const t = await svc.createTutor(req.body);
res.status(201).json(t);
};


export const schedule = async (req: Request, res: Response) => {
const userId = (req as any).user?.id;
if (!userId) return res.status(401).json({ error: "Unauthorized" });
const { scheduledAt, durationMinutes } = req.body;
const session = await svc.scheduleSession(req.params.id, userId, new Date(scheduledAt), Number(durationMinutes));
res.status(201).json(session);
};


export const sessions = async (req: Request, res: Response) => {
const userId = (req as any).user?.id;
if (!userId) return res.status(401).json({ error: "Unauthorized" });
const s = await svc.getUserSessions(userId);
res.json(s);
};