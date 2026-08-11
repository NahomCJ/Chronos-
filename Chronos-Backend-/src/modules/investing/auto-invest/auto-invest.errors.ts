export class AutoInvestApiError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly status: number = 500,
    public readonly details?: unknown,
  ) {
    super(message);
    this.name = "AutoInvestApiError";
  }
}

export function isAutoInvestApiError(err: unknown): err is AutoInvestApiError {
  return err instanceof AutoInvestApiError;
}
