import { Router } from "express";
import { VisionController } from "./vision.controller";
import { requireAuth } from "../../../auth/middlewares/auth.middleware";


const router = Router();
const c = new VisionController();



// Dashboard
router.get("/home", requireAuth, c.home);

// Vision Boards
router.get("/boards", requireAuth, c.getBoards);
router.post("/boards", requireAuth, c.createBoard);
// Goals
router.get("/goals", requireAuth, c.getGoals);
router.post("/goals", requireAuth, c.createGoal);
router.put("/goals/:id", requireAuth, c.updateGoal);
// Milestones
router.get("/milestones", requireAuth, c.getMilestones);
router.post("/milestones", requireAuth, c.createMilestone);
router.put("/milestones/:id", requireAuth, c.updateMilestone);

// Habits
router.get("/habits", requireAuth, c.getHabits);
router.post("/habits", requireAuth, c.createHabit);
router.put("/habits/:id", requireAuth, c.updateHabit);

// Mentorship
router.get("/mentorship", requireAuth, c.getMentorships);
router.post("/mentorship/register", requireAuth, c.registerMentorship);

// Courses
router.get("/courses", requireAuth, c.getCourses);
router.post("/courses/enroll", requireAuth, c.enrollCourse);

// Community
router.get("/community", requireAuth, c.getCommunities);
router.post("/community/join", requireAuth, c.joinCommunity);

// Reports
router.get("/reports", requireAuth, c.getReports);
router.get("/ai/recommendations", requireAuth, c.getAIRecommendations);


export default router;
