export class CryptoApiError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly status: number = 500,
    public readonly details?: unknown,
  ) {
    super(message);
    this.name = "CryptoApiError";
  }
}

export function isCryptoApiError(err: unknown): err is CryptoApiError {
  return err instanceof CryptoApiError;
}
