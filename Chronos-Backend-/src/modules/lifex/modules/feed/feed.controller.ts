import { Response } from "express";
import { FeedService } from "./feed.service";

const service = new FeedService();

export class FeedController {
  personal = async (req: any, res: Response) => {
    const feed = await service.personalFeed(req.user.id);
    res.json(feed);
  };

  community = async (req: any, res: Response) => {
    const feed = await service.communityFeed(req.user.id);
    res.json(feed);
  };

  summary = async (req: any, res: Response) => {
    const data = await service.summary(req.user.id);
    res.json(data);
  };
}
