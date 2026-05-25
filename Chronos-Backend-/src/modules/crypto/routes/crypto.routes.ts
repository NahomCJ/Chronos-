import { Router } from "express";
import controller from "../controllers/crypto.controller";
import { authenticate } from "../../../middlewares/auth.middleware";

const r = Router();

r.post("/quote", authenticate, (req, res) => controller.quote(req, res));
r.post("/execute", authenticate, (req, res) => controller.execute(req, res));

export default r;
