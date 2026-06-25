import crypto from "crypto";
import { unitConfig } from "./unit.config";
import prisma from "../../../../config/prisma";
import { UnitWebhookEvent } from "./unit.types";

export function verifyUnitWebhookSignature(
  rawBody: Buffer,
  signature: string
): boolean {
  if (!unitConfig.webhookSecret) return true; // skip verification in dev if not configured
  const hmac = crypto
    .createHmac("sha256", unitConfig.webhookSecret)
    .update(rawBody)
    .digest("hex");
  return crypto.timingSafeEqual(Buffer.from(hmac), Buffer.from(signature));
}

export async function handleUnitWebhookEvent(event: UnitWebhookEvent): Promise<void> {
  const { type, attributes } = event;

  switch (type) {
    case "transaction.created":
    case "transaction.updated": {
      // Update UnitTransfer status in DB if we have a matching record
      const unitTransferId = attributes?.id ?? event.relationships?.transaction?.data?.id;
      if (unitTransferId) {
        await prisma.unitTransfer
          .updateMany({
            where: { unitTransferId },
            data: { status: attributes?.status ?? "COMPLETED" },
          })
          .catch(() => {}); // silently ignore if model doesn't exist yet
      }
      break;
    }

    case "account.closed": {
      const unitAccountId = event.relationships?.account?.data?.id;
      if (unitAccountId) {
        await prisma.unitAccount
          .updateMany({
            where: { unitAccountId },
            data: { status: "closed" },
          })
          .catch(() => {});
      }
      break;
    }

    case "card.activated":
    case "card.statusChanged": {
      const unitCardId = event.relationships?.card?.data?.id;
      const newStatus = attributes?.status;
      if (unitCardId && newStatus) {
        await prisma.unitCard
          .updateMany({
            where: { unitCardId },
            data: { status: newStatus },
          })
          .catch(() => {});
      }
      break;
    }

    case "application.denied":
    case "application.awaitingDocuments": {
      const appId = event.relationships?.application?.data?.id;
      const status = attributes?.status ?? type.replace("application.", "");
      if (appId) {
        await prisma.bankingProfile
          .updateMany({
            where: { unitApplicationId: appId },
            data: { unitApplicationStatus: status },
          })
          .catch(() => {});
      }
      break;
    }

    default:
      // Unknown event — log and ignore
      console.log(`[Unit Webhook] unhandled event type: ${type}`);
  }
}
