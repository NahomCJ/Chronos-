import { Request, Response } from "express";
import * as svc from "../services/courses.service";
import * as enrollSvc from "../services/enrollments.service";
export const list = async (req: Request, res: Response) => {
const filter = {
provider: req.query.provider as string,
level: req.query.level as string,
tags: req.query.tags ? (req.query.tags as string).split(",") : undefined,
q: req.query.q as string,
page: req.query.page ? Number(req.query.page) : 1,
limit: req.query.limit ? Number(req.query.limit) : 20,
};


const result = await svc.listCourses(filter);
res.json(result);
};

export const detail = async (req: Request, res: Response) => {
const c = await svc.getCourseById(req.params.id);
if (!c) return res.status(404).json({ error: "Not found" });
res.json(c);
};


export const create = async (req: Request, res: Response) => {
const course = await svc.createLocalCourse(req.body);
res.status(201).json(course);
};


export const sync = async (_req: Request, res: Response) => {
const report = await svc.syncAllProviders();
res.json({ message: "sync complete", report });
};


export const enroll = async (req: Request, res: Response) => {
const userId = (req as any).user?.id;
if (!userId) return res.status(401).json({ error: "Unauthorized" });


try {
const e = await enrollSvc.enrollUser({ userId, courseId: req.params.id, autoEnrollExternal: !!req.body.autoEnrollExternal });
res.status(201).json(e);
} catch (err: any) {
res.status(400).json({ error: err.message });
}
};


export const listEnrollments = async (req: Request, res: Response) => {
const userId = (req as any).user?.id;
if (!userId) return res.status(401).json({ error: "Unauthorized" });
const items = await enrollSvc.listUserEnrollments(userId);
res.json(items);
};


export const updateProgress = async (req: Request, res: Response) => {
try {
const updated = await enrollSvc.updateProgress(req.params.id, Number(req.body.progress));
res.json(updated);
} catch (err: any) {
res.status(400).json({ error: err.message });
}
};