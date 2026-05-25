import { NotificationService } from "../../notification/notificatoin.service";
import * as T from "../../notification/email.templates";

class TickPayNotificationService {
  async notify(userId: string, type: string, payload: any) {
    switch (type) {
      case "ACCOUNT_CREATED":
        await NotificationService.notifyUser(userId, {
          subject: "Your TickPay account is ready",
          title: "TickPay Ready",
          message: T.bnplAccountCreated(),
        });
        break;

      case "CARD_ISSUED":
        await NotificationService.notifyUser(userId, {
          subject: "Your TickPay card is ready",
          title: "TickPay Card Issued",
          message: T.bnplCardIssued(),
        });
        break;

      case "PURCHASE_APPROVED":
        await NotificationService.notifyUser(userId, {
          subject: `Purchase Approved — $${payload?.amount}`,
          title: "Purchase Approved",
          message: T.bnplPurchaseApproved(String(payload?.amount ?? ""), payload?.merchant ?? ""),
        });
        break;

      case "PURCHASE_DENIED":
        await NotificationService.notifyUser(userId, {
          subject: `Purchase Not Approved — $${payload?.amount}`,
          title: "Purchase Denied",
          message: T.bnplPurchaseDenied(String(payload?.amount ?? ""), payload?.merchant ?? ""),
        });
        break;

      default:
        await NotificationService.notifyUser(userId, {
          title: "TickPay Update",
          message: `Update: ${type}`,
        });
    }
    return true;
  }
}

export default new TickPayNotificationService();
