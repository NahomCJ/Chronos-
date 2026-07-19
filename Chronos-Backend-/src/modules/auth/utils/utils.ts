import jwt from "jsonwebtoken";
import { JwtPayload } from "../types/auth.types";
import config from "../config/config";

const JWT_SECRET = config.JWT_SECRET;

export const generateToken = (payload: JwtPayload): string => {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: "15m" });
};

export const generateRefreshToken = (payload: JwtPayload): string => {
  return jwt.sign({ ...payload, type: "refresh" }, JWT_SECRET, { expiresIn: "7d" });
};

export const verifyRefreshToken = (token: string): JwtPayload => {
  const decoded = jwt.verify(token, JWT_SECRET) as any;
  if (decoded.type !== "refresh") throw new Error("Invalid token type");
  const { type: _type, iat: _iat, exp: _exp, ...payload } = decoded;
  return payload as JwtPayload;
};
