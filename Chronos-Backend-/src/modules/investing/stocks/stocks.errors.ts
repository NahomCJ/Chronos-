export class StocksApiError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly status: number = 500,
    public readonly details?: unknown,
  ) {
    super(message);
    this.name = "StocksApiError";
  }
}

export function isStocksApiError(err: unknown): err is StocksApiError {
  return err instanceof StocksApiError;
}
