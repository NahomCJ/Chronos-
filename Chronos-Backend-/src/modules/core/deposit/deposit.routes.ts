// src/core/deposit/deposit.route.ts
import { Router } from "express"
import { depositController } from "./deposit.controller"
 import{requireAuth } from '../../auth/middlewares/auth.middleware';

const router = Router()

router.post("/", requireAuth, depositController.create)
router.get("/", requireAuth, depositController.list)
router.get("/:id", requireAuth, depositController.get)

export default router