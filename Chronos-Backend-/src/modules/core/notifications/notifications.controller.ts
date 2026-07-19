import { Request, Response } from "express";
import {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
} from "./notifications.service";

export async function list(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  const unreadOnly = req.query.unread === "true";
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 20);
  try {
    const result = await getNotifications(userId, unreadOnly, page, limit);
    res.status(200).json(result);
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to fetch notifications";
    res.status(500).json({ error: msg });
  }
}

export async function read(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  try {
    const notification = await markAsRead(req.params["id"] as string, userId);
    res.status(200).json({ notification });
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to mark as read";
    res.status(404).json({ error: msg });
  }
}

export async function readAll(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  try {
    const result = await markAllAsRead(userId);
    res.status(200).json(result);
  } catch (err) {
    res.status(500).json({ error: "Failed to mark all as read" });
  }
}

export async function remove(req: Request, res: Response): Promise<void> {
  const userId = (req as any).user?.id as string;
  try {
    await deleteNotification(req.params["id"] as string, userId);
    res.status(200).json({ success: true });
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Failed to delete notification";
    res.status(404).json({ error: msg });
  }
}
