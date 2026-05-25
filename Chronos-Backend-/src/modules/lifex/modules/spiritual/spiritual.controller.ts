import { Response } from "express";
import { SpiritualService } from "./spiritual.service";

const service = new SpiritualService();

export class SpiritualController {
  dashboard = async (req: any, res: Response) => {
    const data = await service.dashboard(req.user.id);
    res.json(data);
  };

  logMeditation = async (req: any, res: Response) => {
    const { durationMin, type, notes, moodBefore, moodAfter } = req.body;
    if (!durationMin || !type) { res.status(400).json({ error: "durationMin and type are required" }); return; }
    const session = await service.logMeditation(req.user.id, { durationMin: Number(durationMin), type, notes, moodBefore, moodAfter });
    res.status(201).json(session);
  };

  listMeditations = async (req: any, res: Response) => {
    const sessions = await service.listMeditations(req.user.id);
    res.json(sessions);
  };

  meditationStats = async (req: any, res: Response) => {
    const stats = await service.meditationStats(req.user.id);
    res.json(stats);
  };

  addGratitude = async (req: any, res: Response) => {
    const { content } = req.body;
    if (!content) { res.status(400).json({ error: "content is required" }); return; }
    const entry = await service.addGratitude(req.user.id, content);
    res.status(201).json(entry);
  };

  listGratitude = async (req: any, res: Response) => {
    const entries = await service.listGratitude(req.user.id);
    res.json(entries);
  };

  createGoal = async (req: any, res: Response) => {
    const { title, description, frequency } = req.body;
    if (!title || !frequency) { res.status(400).json({ error: "title and frequency are required" }); return; }
    const goal = await service.createGoal(req.user.id, { title, description, frequency });
    res.status(201).json(goal);
  };

  listGoals = async (req: any, res: Response) => {
    const goals = await service.listGoals(req.user.id);
    res.json(goals);
  };

  updateGoalProgress = async (req: any, res: Response) => {
    const { progress } = req.body;
    if (progress === undefined) { res.status(400).json({ error: "progress is required" }); return; }
    const goal = await service.updateGoalProgress(req.params.goalId, Number(progress));
    res.json(goal);
  };

  streak = async (req: any, res: Response) => {
    const streak = await service.streak(req.user.id);
    res.json({ streak });
  };
}
