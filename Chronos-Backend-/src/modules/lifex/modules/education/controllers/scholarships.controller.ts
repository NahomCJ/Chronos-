import { Request, Response } from "express";
import { searchScholarships } from "../services/scholarships.service";

export const googleSearch = async (req: Request, res: Response) => {
  const query = req.query.q as string;

  if (!query) {
    return res.status(400).json({ message: "Query parameter 'q' is required" });
  }

  const results = await searchScholarships(query);

  res.json({
    query,
    results,
  });
};
