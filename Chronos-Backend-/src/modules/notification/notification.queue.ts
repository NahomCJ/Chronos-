import { sendEmail } from "./email.service";
import { PushProvider } from "./push.provider";

// Inline queue shim — no Redis/bullmq required.
// Swap this for a real bullmq Queue when Redis is provisioned.
export const notificationQueue = {
  async add(_name: string, data: any): Promise<void> {
    const { type, to, subject, message, title } = data;
    try {
      if (type === "email" && to) {
        await sendEmail(to, subject || "Notification from Chronos", `<p>${message}</p>`);
      } else if (type === "push" && to) {
        await PushProvider.sendPush(to, title || "Chronos", message, data.data);
      }
      // SMS: add Twilio/provider when ready
    } catch (err: any) {
      console.error("[Notification queue] failed:", err?.message);
    }
  },
};
