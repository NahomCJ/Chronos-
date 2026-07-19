import { Response } from "express";
import { SocialService } from "./social.service";

const service = new SocialService();

export class SocialController {
  follow = async (req: any, res: Response) => {
    const { userId: followingId } = req.body;
    if (!followingId) { res.status(400).json({ error: "userId is required" }); return; }
    const conn = await service.follow(req.user.id, followingId);
    res.status(201).json(conn);
  };

  unfollow = async (req: any, res: Response) => {
    await service.unfollow(req.user.id, req.params.userId);
    res.json({ success: true });
  };

  followers = async (req: any, res: Response) => {
    const data = await service.followers(req.user.id);
    res.json(data);
  };

  following = async (req: any, res: Response) => {
    const data = await service.following(req.user.id);
    res.json(data);
  };

  createPost = async (req: any, res: Response) => {
    const { content, type = "update", metadata } = req.body;
    if (!content) { res.status(400).json({ error: "content is required" }); return; }
    const post = await service.createPost(req.user.id, content, type, metadata);
    res.status(201).json(post);
  };

  feed = async (req: any, res: Response) => {
    const posts = await service.listPosts(req.user.id);
    res.json(posts);
  };

  myPosts = async (req: any, res: Response) => {
    const posts = await service.myPosts(req.user.id);
    res.json(posts);
  };

  deletePost = async (req: any, res: Response) => {
    await service.deletePost(req.params.postId, req.user.id);
    res.json({ success: true });
  };

  likePost = async (req: any, res: Response) => {
    const post = await service.likePost(req.params.postId, req.user.id);
    res.json(post);
  };

  unlikePost = async (req: any, res: Response) => {
    const result = await service.unlikePost(req.params.postId, req.user.id);
    res.json(result);
  };
}
