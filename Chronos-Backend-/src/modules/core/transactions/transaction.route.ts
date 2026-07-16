import { Router } from "express"
import { transactionsController } from "./transaction.controller"
import { requireAuth } from '../../auth/middlewares/auth.middleware';

const router = Router()

router.get("/", requireAuth, transactionsController.list)

router.get("/:id", requireAuth, transactionsController.get)

router.get("/wallet/:walletId", requireAuth, transactionsController.walletActivity)

export default router