import prisma from "../../../../config/prisma";

export class SocialService {
  // ---------------- Connections ----------------
  async follow(userId: string, followingId: string) {
    if (userId === followingId) throw new Error("Cannot follow yourself");
    return prisma.socialConnection.upsert({
      where: { userId_followingId: { userId, followingId } },
      update: {},
      create: { userId, followingId },
    });
  }

  async unfollow(userId: string, followingId: string) {
    return prisma.socialConnection.deleteMany({ where: { userId, followingId } });
  }

  async followers(userId: string) {
    return prisma.socialConnection.findMany({ where: { followingId: userId }, select: { userId: true, createdAt: true } });
  }

  async following(userId: string) {
    return prisma.socialConnection.findMany({ where: { userId }, select: { followingId: true, createdAt: true } });
  }

  // ---------------- Posts ----------------
  async createPost(userId: string, content: string, type: string, metadata?: any) {
    return prisma.socialPost.create({ data: { userId, content, type, metadata } });
  }

  async listPosts(userId: string) {
    const followingList = await prisma.socialConnection.findMany({ where: { userId }, select: { followingId: true } });
    const ids = [userId, ...followingList.map((f) => f.followingId)];
    return prisma.socialPost.findMany({
      where: { userId: { in: ids } },
      orderBy: { createdAt: "desc" },
      take: 50,
    });
  }

  async myPosts(userId: string) {
    return prisma.socialPost.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
  }

  async deletePost(postId: string, userId: string) {
    return prisma.socialPost.deleteMany({ where: { id: postId, userId } });
  }

  // ---------------- Likes ----------------
  async likePost(postId: string, userId: string) {
    await prisma.postLike.upsert({
      where: { postId_userId: { postId, userId } },
      update: {},
      create: { postId, userId },
    });
    return prisma.socialPost.update({ where: { id: postId }, data: { likes: { increment: 1 } } });
  }

  async unlikePost(postId: string, userId: string) {
    const deleted = await prisma.postLike.deleteMany({ where: { postId, userId } });
    if (deleted.count > 0) {
      await prisma.socialPost.update({ where: { id: postId }, data: { likes: { decrement: 1 } } });
    }
    return { success: true };
  }
}
