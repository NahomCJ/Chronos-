// src/core/transfer/routes/transfer.routes.ts
import { Router } from "express";
import transferController from "../controllers/transfer.controller";


const router = Router();

router.post("/", transferController.create.bind(transferController));
router.get("/", transferController.list.bind(transferController));
router.get("/:id", transferController.get.bind(transferController));
router.post("/:id/cancel", transferController.cancel.bind(transferController));


// Admin-only retry (protect with admin middleware or RBAC)
router.post("/:id/retry", transferController.retryExecution.bind(transferController));

export default router;
