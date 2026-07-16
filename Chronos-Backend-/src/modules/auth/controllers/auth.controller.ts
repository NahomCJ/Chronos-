import { Request, Response, NextFunction } from "express";
import * as authService from "../services/auth.service";
import { LoginInput, RegisterInput } from "../types/auth.types";
import * as bcrypt from "bcrypt";
import { PrismaClient } from "@prisma/client";
import { generateToken, generateRefreshToken } from "../utils/utils";
import { NotificationService } from "../../notification/notificatoin.service";
import * as T from "../../notification/email.templates";

const prisma = new PrismaClient();

export const register = async (data: RegisterInput) => {
  const { email, password, firstName, lastName, role } = data;

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) throw new Error("User already exists");

  const hashedPassword = await bcrypt.hash(password, 10);

  const user = await prisma.user.create({
    data: {
      email,
      password: hashedPassword,
      firstName,
      lastName,
      role: role || "USER"
    },
  });

  const tokenPayload = { userId: user.id, email: user.email, role: user.role };
  const accessToken = generateToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  NotificationService.sendDirectEmail(user.email, "Welcome to Chronos!", T.welcome(user.firstName || "there")).catch(() => {});

  const { password: _pw, ...safeUser } = user;
  return { user: safeUser, accessToken, refreshToken };
};


export const login = async (data: LoginInput) => {
  const user = await prisma.user.findUnique({
    where: { email: data.email }
  });

  if (!user) throw new Error("Invalid credentials");

  const match = await bcrypt.compare(data.password, user.password);
  if (!match) throw new Error("Invalid credentials");

  const tokenPayload = { userId: user.id, email: user.email, role: user.role };
  const accessToken = generateToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  const { password: _pw, ...safeUser } = user;
  return { user: safeUser, accessToken, refreshToken };
};

export const forgotPassword = async (email: string) => {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) return { message: "If that email exists, an OTP has been sent." };

  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

  await prisma.user.update({
    where: { email },
    data: { otpCode: otp, otpExpiresAt: expiresAt },
  });

  NotificationService.sendDirectEmail(email, "Your Chronos reset code", T.otp(otp)).catch(() => {});

  return {
    message: "If that email exists, an OTP has been sent.",
    ...(process.env.NODE_ENV !== "production" && { dev_otp: otp }),
  };
};

export const resetPassword = async (
  email: string,
  otp: string,
  newPassword: string
) => {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user || !user.otpCode || !user.otpExpiresAt) {
    throw new Error("Invalid or expired OTP");
  }
  if (user.otpCode !== otp) throw new Error("Invalid or expired OTP");
  if (user.otpExpiresAt < new Date()) throw new Error("Invalid or expired OTP");

  const hashed = await bcrypt.hash(newPassword, 10);
  await prisma.user.update({
    where: { email },
    data: { password: hashed, otpCode: null, otpExpiresAt: null },
  });

  NotificationService.sendDirectEmail(email, "Your Chronos password was changed", T.passwordChanged()).catch(() => {});

  return { message: "Password reset successful." };
};
