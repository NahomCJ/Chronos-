// Self-contained cache module — no external config dependencies
const REDIS_ENABLED = !!process.env.REDIS_HOST;
const REDIS_URL = process.env.REDIS_URL || `redis://${process.env.REDIS_HOST || "127.0.0.1"}:${process.env.REDIS_PORT || 6379}`;

let redis: any = null;

async function connect() {
  if (!REDIS_ENABLED || redis) return redis;
  const { createClient } = await import("redis");
  redis = createClient({ url: REDIS_URL });
  redis.on("error", (e: any) => console.error("Redis error:", e?.message || e));
  await redis.connect();
  return redis;
}

type Fn<T> = () => Promise<T>;

export async function cached<T>(key: string, ttlSec: number, fn: Fn<T>): Promise<T> {
  try {
    if (REDIS_ENABLED) {
      await connect();
      const hit = await redis.get(key);
      if (hit) return JSON.parse(hit);
      const val = await fn();
      await redis.setEx(key, ttlSec, JSON.stringify(val));
      return val;
    }
    // In-memory fallback (per process)
    const g = global as any;
    g.__cache = g.__cache || new Map<string, { e: number; v: any }>();
    const now = Date.now();
    const rec = g.__cache.get(key);
    if (rec && rec.e > now) return rec.v;
    const val = await fn();
    g.__cache.set(key, { v: val, e: now + ttlSec * 1000 });
    return val;
  } catch {
    return fn(); // never block on cache errors
  }
}
