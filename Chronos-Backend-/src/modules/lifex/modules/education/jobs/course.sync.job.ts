import { Queue, Worker, QueueScheduler, Job } from "bullmq";
import IORedis from "ioredis";
import { syncAllProviders } from "../services/courses.service";


const connection = new IORedis(process.env.REDIS_URL || "redis://127.0.0.1:6379");
export const courseSyncQueue = new Queue("course-sync", { connection });
new QueueScheduler("course-sync", { connection });


export const enqueueCourseSync = async () => {
await courseSyncQueue.add("sync", {}, { attempts: 3, backoff: { type: "exponential", delay: 2000 } });
};


new Worker("course-sync", async (job: Job) => {
console.log("Running course sync job", job.id);
await syncAllProviders();
}, { connection });