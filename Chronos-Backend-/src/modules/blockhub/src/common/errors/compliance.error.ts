import { HttpException } from '@nestjs/common';

export class ComplianceError extends HttpException {
  constructor(
    public readonly code: string,
    statusCode: number = 403,
  ) {
    const messages: Record<string, string> = {
      KYC_NOT_VERIFIED: 'Account KYC verification is required before trading',
      ACCOUNT_SUSPENDED: 'Account has been suspended',
      DAILY_LIMIT_EXCEEDED: 'Daily trading limit exceeded',
      ACCOUNT_FLAGGED: 'Account flagged for review — trading suspended',
      WALLET_NOT_FOUND: 'No trading wallet provisioned for this account',
    };
    super({ code, message: messages[code] ?? 'Compliance check failed', statusCode }, statusCode);
  }
}
