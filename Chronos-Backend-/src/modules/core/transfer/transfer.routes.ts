import { Router } from "express"
import { transferController } from "./transfer.controller"
import { requireAuth } from '../../auth/middlewares/auth.middleware';

const router = Router()

// Base path will be /transfers

// Create a new transfer
router.post("/", requireAuth, transferController.create)

// List all user transfers (with pagination)
router.get("/", requireAuth, transferController.list)

// Get a single transfer by ID
router.get("/:id", requireAuth, transferController.get)
// Cancel a transfer
router.post("/:id/cancel", requireAuth, transferController.cancel)

export default router