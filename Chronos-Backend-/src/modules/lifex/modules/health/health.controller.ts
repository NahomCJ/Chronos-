import { Request, Response } from "express";
import { HealthService } from "./health.service";
import { LogMetricDTO } from "./dto/logMetric.dto";
import { CreateFitnessSessionDTO } from "./dto/createFitnessSession.dto";
import { LogDietDTO } from "./dto/logDiet.dto";
import { HsaTransactionDTO } from "./dto/hsa.dto";
import { MedicalRecordDTO } from "./dto/medicalRecord.dto";
import { EnrollWellnessDTO } from "./dto/wellnessProgram.dto";
import { LogHabitDTO } from "./dto/habit.dto";

const service = new HealthService();

export class HealthController {
  // ---------------- Dashboard ----------------
  dashboard = async (req: any, res: Response) => {
    const data = await service.dashboard(req.user.id);
    res.json(data);
  };

  // ---------------- Health Metrics ----------------
  createMetric = async (req: any, res: Response) => {
    const data = LogMetricDTO.parse(req.body);
    const metric = await service.createMetric(req.user.id, data);
    res.json(metric);
  };

  listMetrics = async (req: any, res: Response) => {
    const metrics = await service.listMetrics(req.user.id);
    res.json(metrics);
  };

  // ---------------- Fitness ----------------
  logFitness = async (req: any, res: Response) => {
    const data = CreateFitnessSessionDTO.parse(req.body);
    const session = await service.logFitness(req.user.id, data);
    res.json(session);
  };

  listFitness = async (req: any, res: Response) => {
    const sessions = await service.listFitness(req.user.id);
    res.json(sessions);
  };

  // ---------------- Diet ----------------
  logDiet = async (req: any, res: Response) => {
    const data = LogDietDTO.parse(req.body);
    const log = await service.logDiet(req.user.id, data);
    res.json(log);
  };

  listDiet = async (req: any, res: Response) => {
    const logs = await service.listDiet(req.user.id);
    res.json(logs);
  };

  // ---------------- HSA ----------------
  getHsa = async (req: any, res: Response) => {
    const hsa = await service.getHsa(req.user.id);
    res.json(hsa);
  };

  depositHsa = async (req: any, res: Response) => {
    const { amount } = HsaTransactionDTO.parse(req.body);
    const updated = await service.depositHsa(req.user.id, amount);
    res.json(updated);
  };

  withdrawHsa = async (req: any, res: Response) => {
    const { amount } = HsaTransactionDTO.parse(req.body);
    const updated = await service.withdrawHsa(req.user.id, amount);
    res.json(updated);
  };

  // ---------------- Medical ----------------
  addMedical = async (req: any, res: Response) => {
    const data = MedicalRecordDTO.parse(req.body);
    const record = await service.addMedical(req.user.id, data);
    res.json(record);
  };

  listMedical = async (req: any, res: Response) => {
    const records = await service.listMedical(req.user.id);
    res.json(records);
  };

  // ---------------- Wellness ----------------
  listWellness = async (_req: Request, res: Response) => {
    const programs = await service.listWellness();
    res.json(programs);
  };

  enrollWellness = async (req: any, res: Response) => {
    const data = EnrollWellnessDTO.parse(req.body);
    const enrollment = await service.enrollWellness(req.user.id, data);
    res.json(enrollment);
  };

  // ---------------- Habits ----------------
  logHabit = async (req: any, res: Response) => {
    const data = LogHabitDTO.parse(req.body);
    const habit = await service.logHabit(req.user.id, data);
    res.json(habit);
  };

  listHabits = async (req: any, res: Response) => {
    const habits = await service.listHabits(req.user.id);
    res.json(habits);
  };

  // ---------------- Gyms ----------------
  gyms = async (req: Request, res: Response) => {
    const city = typeof req.query.city === "string" ? req.query.city : undefined;
    const gyms = await service.listGyms(city);
    res.json(gyms);
  };

  // ---------------- Insurance Marketplace ----------------
  enrollInsurance = async (req: any, res: Response) => {
    const { provider, planName, coverageType, monthlyPremium } = req.body;
    if (!provider || !planName || !coverageType || monthlyPremium === undefined) {
      res.status(400).json({ error: "provider, planName, coverageType and monthlyPremium are required" });
      return;
    }
    res.status(201).json(await service.enrollInsurance(req.user.id, { provider, planName, coverageType, monthlyPremium: Number(monthlyPremium) }));
  };

  myInsurance = async (req: any, res: Response) => {
    res.json(await service.myInsurance(req.user.id));
  };

  // ---------------- Nutrition Partners ----------------
  connectNutritionPartner = async (req: any, res: Response) => {
    const { partnerName, category } = req.body;
    if (!partnerName) { res.status(400).json({ error: "partnerName is required" }); return; }
    res.status(201).json(await service.connectNutritionPartner(req.user.id, { partnerName, category }));
  };

  myNutritionConnections = async (req: any, res: Response) => {
    res.json(await service.myNutritionConnections(req.user.id));
  };

  // ---------------- Wearables ----------------
  wearableProviders = async (_req: Request, res: Response) => {
    res.json(service.listWearableProviders());
  };

  connectWearable = async (req: any, res: Response) => {
    const { provider } = req.body;
    if (!provider) { res.status(400).json({ error: "provider is required" }); return; }
    res.status(201).json(await service.connectWearable(req.user.id, provider));
  };

  myWearableConnections = async (req: any, res: Response) => {
    res.json(await service.myWearableConnections(req.user.id));
  };

  syncWearableMetrics = async (req: any, res: Response) => {
    const { provider, metrics } = req.body;
    if (!provider || !Array.isArray(metrics)) { res.status(400).json({ error: "provider and metrics are required" }); return; }
    res.status(201).json(await service.syncWearableMetrics(req.user.id, provider, metrics));
  };

  // ---------------- Insights ----------------
  insights = async (req: any, res: Response) => {
    res.json(await service.getInsights(req.user.id));
  };

  // ---------------- Notifications ----------------
  notifications = async (req: any, res: Response) => {
    const notifications = await service.notifications(req.user.id);
    res.json(notifications);
  };

  // ---------------- Reports ----------------
  generateReports = async (req: any, res: Response) => {
    const report = await service.generateReports(req.user.id);
    res.json(report);
  };

  aiInsights = async (req: any, res: Response) => {
    const insights = await service.aiInsights(req.user.id);
    res.json(insights);
  };
}
