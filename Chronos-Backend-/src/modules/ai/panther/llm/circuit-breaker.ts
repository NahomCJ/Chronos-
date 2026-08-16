// Lightweight circuit breaker for outbound LLM provider calls (DeepSeek,
// Claude). No new dependency — every chatbot in this app (Chris's domain
// agents, routing, compliance, the LifeX AI coach) routes through
// llm.client.ts, so a provider that goes slow instead of erroring would
// otherwise hang every one of those requests for the SDK's default timeout
// (10 min) before llm.client.ts's error-based fallback ever engages.
//
// This wraps a provider call with:
// - a hard per-call timeout, so a hung request fails fast instead of
//   blocking a request thread for minutes
// - a breaker that opens after repeated failures/timeouts and fast-fails
//   (skipping the network call entirely) until a cooldown elapses, then
//   allows one trial call (half-open) to check recovery
// - a concurrency cap, so a slow provider can't pile up unbounded in-flight
//   requests against it while everyone waits

type BreakerState = "CLOSED" | "OPEN" | "HALF_OPEN";

export interface CircuitBreakerOptions {
  failureThreshold: number;
  resetTimeoutMs: number;
  callTimeoutMs: number;
  maxConcurrent: number;
}

export class CircuitBreakerOpenError extends Error {
  constructor(name: string) {
    super(`[circuit-breaker:${name}] open — dependency is failing or too slow, fast-failing`);
    this.name = "CircuitBreakerOpenError";
  }
}

export class CircuitBreaker {
  private state: BreakerState = "CLOSED";
  private consecutiveFailures = 0;
  private openedAt = 0;
  private inFlight = 0;

  constructor(private readonly name: string, private readonly opts: CircuitBreakerOptions) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === "OPEN") {
      if (Date.now() - this.openedAt < this.opts.resetTimeoutMs) {
        throw new CircuitBreakerOpenError(this.name);
      }
      this.state = "HALF_OPEN";
    }

    if (this.inFlight >= this.opts.maxConcurrent) {
      throw new Error(
        `[circuit-breaker:${this.name}] at concurrency limit (${this.opts.maxConcurrent}), fast-failing`
      );
    }

    this.inFlight += 1;
    try {
      const result = await this.withTimeout(fn());
      this.onSuccess();
      return result;
    } catch (err) {
      this.onFailure();
      throw err;
    } finally {
      this.inFlight -= 1;
    }
  }

  private withTimeout<T>(promise: Promise<T>): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      const timer = setTimeout(() => {
        reject(new Error(`[circuit-breaker:${this.name}] timed out after ${this.opts.callTimeoutMs}ms`));
      }, this.opts.callTimeoutMs);
      promise.then(
        (value) => {
          clearTimeout(timer);
          resolve(value);
        },
        (err) => {
          clearTimeout(timer);
          reject(err);
        }
      );
    });
  }

  private onSuccess(): void {
    this.consecutiveFailures = 0;
    this.state = "CLOSED";
  }

  private onFailure(): void {
    this.consecutiveFailures += 1;
    if (this.state === "HALF_OPEN" || this.consecutiveFailures >= this.opts.failureThreshold) {
      this.state = "OPEN";
      this.openedAt = Date.now();
    }
  }
}
