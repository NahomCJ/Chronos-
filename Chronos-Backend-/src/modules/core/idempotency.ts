import prisma from "../models/prisma";
import { Request, Response, NextFunction } from "express";

export async function idempotencyMiddleware(req: Request & { user?: any }, res: Response, next: NextFunction) {
  const key = req.header("Idempotency-Key");
  if (!key) return next(); // optional unless you want to enforce

  try {
    const existing = await prisma.idempotencyKey.findUnique({ where: { key } });
    if (existing) {
      // Return cached response
      return res.status(200).json(existing.response);
    }

    // Hijack res.json to save response
    const originalJson = res.json.bind(res);
    (res as any).json = async (body: any) => {
      try {
        await prisma.idempotencyKey.create({
          data: {
            key,
            method: req.method,
            path: req.path,
            userId: req.user?.id || null,
            response: body,
          },
        });
      } catch (e) {
        console.error("idempotency save error:", e);
      }
      return originalJson(body);
    };
    next();
  } catch (e) {
    // do not block
    console.error("idempotency middleware error:", e);
    next();
  }
}
