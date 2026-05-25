import { Request, Response, NextFunction } from "express";
import type { ZodTypeAny } from "zod";

// Lightweight wrapper used across the repo. Exports both named and default
// to satisfy different import styles used in the codebase.
export const validate = (schema: ZodTypeAny) => (req: Request, res: Response, next: NextFunction) => {
  try {
    schema.parse(req.body); // validate req.body directly
    next();
  } catch (err: any) {
    return res.status(400).json({ error: err.errors });
  }
};

export default validate;

