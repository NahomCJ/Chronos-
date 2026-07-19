import { Router } from "express";
import * as authController from "../controllers/auth.controller";
import { validate } from "../../../middlewares/validate.middleware";
import { registerSchema, loginSchema } from "../schemas/auth.schema";
import { generateToken, verifyRefreshToken } from "../utils/utils";



const router = Router();

router.post("/register", validate(registerSchema), async (req, res) => {
  try {
    const result = await authController.register(req.body);
    res.status(201).json(result);
  } catch (err: any) {
    res.status(400).json({ error: err.message });
  }
});

router.post("/login", validate(loginSchema), async (req, res) => {
  try {
    const result = await authController.login(req.body);
    res.status(200).json(result);
  } catch (err: any) {
    res.status(400).json({ error: err.message });
  }
});

router.post("/refresh", async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(400).json({ error: "refreshToken is required" });
    const payload = verifyRefreshToken(refreshToken);
    const accessToken = generateToken(payload);
    res.status(200).json({ accessToken });
  } catch (err: any) {
    res.status(401).json({ error: "Invalid or expired refresh token" });
  }
});

router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: "Email is required" });
    const result = await authController.forgotPassword(email);
    res.status(200).json(result);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/reset-password", async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;
    if (!email || !otp || !newPassword) {
      return res.status(400).json({ error: "email, otp, and newPassword are required" });
    }
    if (newPassword.length < 8) {
      return res.status(400).json({ error: "Password must be at least 8 characters" });
    }
    const result = await authController.resetPassword(email, otp, newPassword);
    res.status(200).json(result);
  } catch (err: any) {
    res.status(400).json({ error: err.message });
  }
});

export default router;
