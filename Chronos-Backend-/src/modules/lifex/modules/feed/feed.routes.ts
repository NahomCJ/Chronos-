import { Router } from "express";
import { FeedController } from "./feed.controller";
import { requireAuth } from "../../../auth/middlewares/auth.middleware";

const router = Router();
const ctrl = new FeedController();

router.get("/", requireAuth, ctrl.personal);
router.get("/community", requireAuth, ctrl.community);
router.get("/summary", requireAuth, ctrl.summary);

export default router;
