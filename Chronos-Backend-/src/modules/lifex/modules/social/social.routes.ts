import { Router } from "express";
import { SocialController } from "./social.controller";
import { requireAuth } from "../../../auth/middlewares/auth.middleware";

const router = Router();
const ctrl = new SocialController();

router.get("/followers", requireAuth, ctrl.followers);
router.get("/following", requireAuth, ctrl.following);
router.post("/follow", requireAuth, ctrl.follow);
router.delete("/follow/:userId", requireAuth, ctrl.unfollow);

router.get("/feed", requireAuth, ctrl.feed);
router.get("/posts", requireAuth, ctrl.myPosts);
router.post("/posts", requireAuth, ctrl.createPost);
router.delete("/posts/:postId", requireAuth, ctrl.deletePost);

router.post("/posts/:postId/like", requireAuth, ctrl.likePost);
router.delete("/posts/:postId/like", requireAuth, ctrl.unlikePost);

export default router;
