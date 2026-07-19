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

  donate = async (req: any, res: Response) => {
    const { charityName, category, amount, currency, recurring, frequency } = req.body;
    if (!charityName || !amount) { res.status(400).json({ error: "charityName and amount are required" }); return; }
    try {
      const donation = await service.donate(req.user.id, { charityName, category, amount: Number(amount), currency, recurring, frequency });
      res.status(201).json(donation);
    } catch (e: any) {
      res.status(400).json({ error: e.message });
    }
  };

  listDonations = async (req: any, res: Response) => {
    res.json(await service.listDonations(req.user.id));
  };

  contribute = async (req: any, res: Response) => {
    const { campaignTitle, campaignCategory, amount, currency } = req.body;
    if (!campaignTitle || !amount) { res.status(400).json({ error: "campaignTitle and amount are required" }); return; }
    try {
      const contribution = await service.contribute(req.user.id, { campaignTitle, campaignCategory, amount: Number(amount), currency });
      res.status(201).json(contribution);
    } catch (e: any) {
      res.status(400).json({ error: e.message });
    }
  };

  listContributions = async (req: any, res: Response) => {
    res.json(await service.listContributions(req.user.id));
  };

  bookTrip = async (req: any, res: Response) => {
    const { tripTitle, destination, travelers, totalAmount, currency } = req.body;
    if (!tripTitle || !totalAmount) { res.status(400).json({ error: "tripTitle and totalAmount are required" }); return; }
    try {
      const booking = await service.bookTrip(req.user.id, { tripTitle, destination, travelers: travelers ? Number(travelers) : undefined, totalAmount: Number(totalAmount), currency });
      res.status(201).json(booking);
    } catch (e: any) {
      res.status(400).json({ error: e.message });
    }
  };

  listTripBookings = async (req: any, res: Response) => {
    res.json(await service.listTripBookings(req.user.id));
  };

  checkout = async (req: any, res: Response) => {
    const { items, currency } = req.body;
    if (!Array.isArray(items) || items.length === 0) { res.status(400).json({ error: "items are required" }); return; }
    try {
      const order = await service.checkout(req.user.id, { items, currency });
      res.status(201).json(order);
    } catch (e: any) {
      res.status(400).json({ error: e.message });
    }
  };

  listOrders = async (req: any, res: Response) => {
    res.json(await service.listOrders(req.user.id));
  };

  getFaith = async (req: any, res: Response) => {
    res.json(await service.getFaith(req.user.id));
  };

  setFaith = async (req: any, res: Response) => {
    const { faith } = req.body;
    if (!faith) { res.status(400).json({ error: "faith is required" }); return; }
    res.json(await service.setFaith(req.user.id, faith));
  };
}
