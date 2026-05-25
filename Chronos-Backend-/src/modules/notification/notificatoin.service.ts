import { notificationQueue } from "./notification.queue";
import { sendEmail } from "./email.service";
import prisma from "../../config/prisma";

export class NotificationService {
  static async sendNotification(
    user: any,
    { subject, title, message, data }: { subject?: string; title?: string; message: string; data?: any }
  ) {
    const prefs = user.notification_preferences || { sms: true, email: true, push: true };

    try {
      if (prefs.sms && user.phone) {
        await notificationQueue.add("sms", { type: "sms", to: user.phone, message });
      }

      if (prefs.email && user.email) {
        await notificationQueue.add("email", {
          type: "email",
          to: user.email,
          subject: subject || "Notification from Chronos",
          message,
        });
      }

      if (prefs.push && user.deviceToken) {
        await notificationQueue.add("push", {
          type: "push",
          to: user.deviceToken,
          title: title || "Chronos",
          message,
          data,
        });
      }
    } catch {
      // Queue unavailable (Redis not configured) — fall back to direct email
      if (user.email) {
        await sendEmail(user.email, subject || "Notification from Chronos", `<p>${message}</p>`);
      }
    }
  }

  // Convenience: look up user by ID then notify. Fire-and-forget safe.
  static async notifyUser(
    userId: string,
    options: { subject?: string; title?: string; message: string; data?: any }
  ): Promise<void> {
    try {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { email: true, firstName: true, phone: true, deviceToken: true, notification_preferences: true } as any,
      });
      if (!user) return;
      await NotificationService.sendNotification(user, options);
    } catch {
      // never block caller
    }
  }

  // Direct email — bypasses queue. Use for time-sensitive messages like OTPs.
  static async sendDirectEmail(to: string, subject: string, html: string): Promise<void> {
    await sendEmail(to, subject, html);
  }
}
