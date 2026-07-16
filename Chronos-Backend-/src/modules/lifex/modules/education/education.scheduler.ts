import cron from "node-cron";
import { enqueueCourseSync } from "./jobs/course.sync.job";


// Cron schedule: every 6 hours
cron.schedule("0 */6 * * *", async () => {
try {
await enqueueCourseSync();
console.log("Enqueued course sync job");
} catch (e) {
console.error("Failed to enqueue course sync", e);
}
});