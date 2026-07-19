import { Request, Response } from "express";
import { VisionService } from "./vision.service";
import { ReportsService } from "./reports.service";
import { AIService } from "./ai/ai.service";
import { createGoalDto } from "./dto/createGoal.dto";
import { createMilestoneDto } from "./dto/createMilestone.dto";
import { createHabitDto } from "./dto/createHabit.dto";

const service = new VisionService();
const reports = new ReportsService();
const ai = new AIService();

export class VisionController {
  // ---------------- Dashboard ----------------
  home = async (req: any, res: Response) => {
    try {
      const data = await service.dashboard(req.user.id);
      res.json(data);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Failed to load dashboard" });
    }
  };

  // ---------------- Vision Boards ----------------
  getBoards = async (req: any, res: Response) => {
    const boards = await service.getBoards(req.user.id);
    res.json(boards);
  };

  createBoard = async (req: any, res: Response) => {
    const board = await service.createBoard(req.user.id, req.body);
    res.json(board);
  };

  // ---------------- Goals ----------------
  getGoals = async (req: any, res: Response) => {
    const goals = await service.getGoals(req.user.id);
    res.json(goals);
  };

  createGoal = async (req: any, res: Response) => {
    const data = createGoalDto.parse(req.body);
    const goal = await service.createGoal(req.user.id, data);
    res.json(goal);
  };

  updateGoal = async (req: any, res: Response) => {
    const goal = await service.updateGoal(req.params.id, req.body);
    res.json(goal);
  };

  // ---------------- Milestones ----------------
  getMilestones = async (req: any, res: Response) => {
    const milestones = await service.getMilestones(req.query.goalId);
    res.json(milestones);
  };

  createMilestone = async (req: any, res: Response) => {
    const data = createMilestoneDto.parse(req.body);
    const milestone = await service.createMilestone(data);
    res.json(milestone);
  };

  updateMilestone = async (req: any, res: Response) => {
    const milestone = await service.updateMilestone(req.params.id, req.body);
    res.json(milestone);
  };

  // ---------------- Habits ----------------
  getHabits = async (req: any, res: Response) => {
    const habits = await service.getHabits(req.user.id);
    res.json(habits);
  };

  createHabit = async (req: any, res: Response) => {
    const data = createHabitDto.parse(req.body);
    const habit = await service.createHabit(req.user.id, data);
    res.json(habit);
  };

  updateHabit = async (req: any, res: Response) => {
    const habit = await service.updateHabit(req.params.id, req.body);
    res.json(habit);
  };

  // ---------------- Mentorship ----------------
  getMentorships = async (_req: Request, res: Response) => {
    const mentorships = await service.getMentorships();
    res.json(mentorships);
  };

  registerMentorship = async (_req: Request, res: Response) => {
    res.json({ success: true });
  };

  // ---------------- Courses ----------------
  getCourses = async (_req: Request, res: Response) => {
    const courses = await service.getCourses();
    res.json(courses);
  };

  enrollCourse = async (_req: Request, res: Response) => {
    res.json({ success: true });
  };

  // ---------------- Communities ----------------
  getCommunities = async (_req: Request, res: Response) => {
    const communities = await service.getCommunities();
    res.json(communities);
  };

  joinCommunity = async (_req: Request, res: Response) => {
    res.json({ success: true });
  };

  // ---------------- Reports ----------------
  getReports = async (req: any, res: Response) => {
    const report = await reports.generate(req.user.id);
    res.json(report);
  };

  // ---------------- AI Recommendations ----------------
  getAIRecommendations = async (req: any, res: Response) => {
    const recommendations = await ai.generate(req.user.id);
    res.json(recommendations);
  };
}
