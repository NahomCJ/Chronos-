import cron from "node-cron";
import { AIService } from "../ai/ai.service";

const ai = new AIService();

cron.schedule("0 0 * * 0", async () => {
  console.log("Weekly AI analysis started");
});
