import { Response } from "express";
import { FamilyService } from "./family.service";

const service = new FamilyService();

export class FamilyController {
  createGroup = async (req: any, res: Response) => {
    const { name } = req.body;
    if (!name) { res.status(400).json({ error: "name is required" }); return; }
    const group = await service.createGroup(req.user.id, name);
    res.status(201).json(group);
  };

  myGroups = async (req: any, res: Response) => {
    const groups = await service.getMyGroups(req.user.id);
    res.json(groups);
  };

  getGroup = async (req: any, res: Response) => {
    const group = await service.getGroup(req.params.groupId);
    if (!group) { res.status(404).json({ error: "Group not found" }); return; }
    res.json(group);
  };

  addMember = async (req: any, res: Response) => {
    const { userId } = req.body;
    if (!userId) { res.status(400).json({ error: "userId is required" }); return; }
    const member = await service.addMember(req.params.groupId, userId);
    res.status(201).json(member);
  };

  removeMember = async (req: any, res: Response) => {
    await service.removeMember(req.params.groupId, req.params.userId);
    res.json({ success: true });
  };

  listGoals = async (req: any, res: Response) => {
    const goals = await service.listGoals(req.params.groupId);
    res.json(goals);
  };

  createGoal = async (req: any, res: Response) => {
    const goal = await service.createGoal(req.params.groupId, req.body);
    res.status(201).json(goal);
  };

  contributeGoal = async (req: any, res: Response) => {
    const { amount } = req.body;
    if (!amount) { res.status(400).json({ error: "amount is required" }); return; }
    const updated = await service.contributeGoal(req.params.goalId, Number(amount));
    res.json(updated);
  };

  listBudgets = async (req: any, res: Response) => {
    const budgets = await service.listBudgets(req.params.groupId);
    res.json(budgets);
  };

  createBudget = async (req: any, res: Response) => {
    const budget = await service.createBudget(req.params.groupId, req.body);
    res.status(201).json(budget);
  };
}
