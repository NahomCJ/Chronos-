import { RequestHandler, Router } from "express";
import controller from "./stocks.controller";
import { requireAuth } from "../../../middlewares/auth.middleware";

const router = Router();
const auth = requireAuth as unknown as RequestHandler;

// Live quotes — public, no auth required (same convention as
// crypto's GET /v1/crypto/price/:asset).
router.get("/quotes", controller.listSupported.bind(controller));
router.get("/quotes/:symbol", controller.quote.bind(controller));

router.get("/portfolio", auth, controller.portfolio.bind(controller));
router.get("/orders", auth, controller.orders.bind(controller));
router.post("/orders/buy", auth, controller.buy.bind(controller));
router.post("/orders/sell", auth, controller.sell.bind(controller));

export default router;
