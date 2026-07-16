import { Router } from "express";
import { FamilyController } from "./family.controller";
import { requireAuth } from "../../../auth/middlewares/auth.middleware";

const router = Router();
const ctrl = new FamilyController();

router.get("/", requireAuth, ctrl.myGroups);
router.post("/", requireAuth, ctrl.createGroup);
router.get("/:groupId", requireAuth, ctrl.getGroup);

router.post("/:groupId/members", requireAuth, ctrl.addMember);
router.delete("/:groupId/members/:userId", requireAuth, ctrl.removeMember);

router.get("/:groupId/goals", requireAuth, ctrl.listGoals);
router.post("/:groupId/goals", requireAuth, ctrl.createGoal);
router.post("/goals/:goalId/contribute", requireAuth, ctrl.contributeGoal);

router.get("/:groupId/budgets", requireAuth, ctrl.listBudgets);
router.post("/:groupId/budgets", requireAuth, ctrl.createBudget);

export default router;
