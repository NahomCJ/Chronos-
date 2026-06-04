import { Router } from "express";
import { requireAuth } from "../auth/middlewares/auth.middleware";
import { getProfile, patchProfile } from "./user-profile.controller";

const router = Router();

router.get("/me", requireAuth, getProfile);
router.patch("/me", requireAuth, patchProfile);

export default router;
