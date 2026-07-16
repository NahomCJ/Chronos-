// src/jobs/tickpay.scheduler.ts
import cron from "node-cron" ;
import TickPayService from "../services/tickpay.service";

async function runTickPayDailyJob() {
  if (TickPayService && typeof (TickPayService as any).runTickPayDailyJob === "function") {
    return await (TickPayService as any).runTickPayDailyJob();
  }
  // fallback no-op if service method is not available
  return;
}

export async function scheduleDailyJob() {
  // run every day at 08:00
  cron.schedule("0 8 * * *", async () => {
    try {
      await runTickPayDailyJob();
    } catch (err) {
      console.error("tickpay daily job failed", err);
    }
  });
}

