import { Queue, Worker, QueueScheduler, Job } from "bullmq";
import IORedis from "ioredis";


const connection = new IORedis(process.env.REDIS_URL || "redis://127.0.0.1:6379");
export const scholarshipSyncQueue = new Queue("scholarship-sync", { connection });
new QueueScheduler("scholarship-sync", { connection });


new Worker("scholarship-sync", async (job: Job) => {
console.log("running scholarship sync job", job.id);
// implement feed fetch & upsert
}, { connection });