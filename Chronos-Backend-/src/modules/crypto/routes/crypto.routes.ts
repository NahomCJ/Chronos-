import { RequestHandler, Router } from "express";
import controller from "../controllers/crypto.controller";
import { requireAuth } from "../../../middlewares/auth.middleware";

const router = Router();
const auth = requireAuth as unknown as RequestHandler;

router.get("/", auth, controller.dashboard.bind(controller));
router.post("/buy", auth, controller.buy.bind(controller));
router.post("/sell", auth, controller.sell.bind(controller));
router.get("/history", auth, controller.history.bind(controller));
router.get("/price/:asset", controller.price.bind(controller));

export default router;
