import { Router } from "express";
import { requireAuth } from "../../auth/middlewares/auth.middleware";
import { list, read, readAll, remove } from "./notifications.controller";

const router = Router();

router.get("/", requireAuth, list);
router.patch("/read-all", requireAuth, readAll);
router.patch("/:id/read", requireAuth, read);
router.delete("/:id", requireAuth, remove);

export default router;
