// src/modules/core/kyc/kyc.types.ts

export type RiskLevel = "LOW" | "MEDIUM" | "HIGH";

// Plaid IDV statuses
export type PlaidIdvStatus =
  | "active"
  | "success"
  | "failed"
  | "pending_review"
  | "pending_docv"
  | "expired";

// ── Identity Verification (KYC) ──────────────────────────────────────────────

export interface CreateKycSessionInput {
  email: string;
  firstName: string;
  lastName: string;
  dateOfBirth?: string; // YYYY-MM-DD
  phoneNumber?: string;
}

export interface CompleteKycSessionInput {
  identityVerificationId: string;
}

// ── Plaid Auth (bank account linking) ────────────────────────────────────────

export interface CreateAuthLinkTokenInput {
  email: string;
}

export interface ExchangePublicTokenInput {
  publicToken: string;
  accountId: string; // the Plaid account_id the user selected in Link
}

export interface PlaidAuthDTO {
  accountId: string;
  name: string;
  mask: string;
  itemId: string;
  routingNumber?: string;
  // Account number is sensitive — only return when strictly needed
  accountNumber?: string;
}

// ── Admin ────────────────────────────────────────────────────────────────────

export interface ApproveKycInput {
  riskLevel: RiskLevel;
}

export interface RejectKycInput {
  reason: string;
}

// ── DTOs ─────────────────────────────────────────────────────────────────────

export interface KycSessionDTO {
  linkToken: string;
  expiration: string;
  requestId: string;
}

export interface KycProfileDTO {
  userId: string;
  status: string;
  kycVerified: boolean;
  riskLevel?: RiskLevel;
  frozen: boolean;
  plaidIdvId?: string | null;
  plaidStatus?: string | null;
  bankLinked: boolean;
  kycCompletedAt?: string | null;
  kycDetails?: unknown;
  createdAt: string;
  updatedAt: string;
}

// ── Plaid Webhook ─────────────────────────────────────────────────────────────

export interface PlaidWebhookBody {
  webhook_type: string;
  webhook_code: string;
  identity_verification_id?: string;
  item_id?: string;
  error?: { error_code: string; error_message: string } | null;
  environment: string;
}
