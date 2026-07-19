import bcrypt from "bcrypt";
import prisma from "../../../config/prisma";
import { RegisterInput, LoginInput } from "../types/auth.types";
import { generateToken, generateRefreshToken } from "../utils/utils";

export const register = async (data: RegisterInput) => {
  const existingUser = await prisma.user.findUnique({
    where: { email: data.email }
  });
  if (existingUser) throw new Error("User already exists");

  const hashedPassword = await bcrypt.hash(data.password, 10);

  const user = await prisma.user.create({
    data: {
      email: data.email,
      password: hashedPassword,
      firstName: data.firstName,
      middleName: data.middleName,
      lastName: data.lastName,
      role: data.role || "USER", // <-- saves role into database
    },
  });

  const tokenPayload = { userId: user.id, email: user.email, role: user.role };
  const accessToken = generateToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  const { password: _pw, ...safeUser } = user;
  return { user: safeUser, accessToken, refreshToken };
};

export const login = async (data: LoginInput) => {
  const user = await prisma.user.findUnique({
    where: { email: data.email }
  });
  if (!user) throw new Error("Invalid credentials");

  const isMatch = await bcrypt.compare(data.password, user.password);
  if (!isMatch) throw new Error("Invalid credentials");

  const tokenPayload = { userId: user.id, email: user.email, role: user.role };
  const accessToken = generateToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  const { password: _pw, ...safeUser } = user;
  return { user: safeUser, accessToken, refreshToken };
};
